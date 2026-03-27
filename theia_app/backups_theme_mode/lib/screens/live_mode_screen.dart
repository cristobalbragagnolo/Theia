// lib/screens/live_mode_screen.dart (SIMPLIFICADO)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/widgets/keypoint_painter.dart';
import 'package:theia/screens/detail_screen.dart';

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({super.key});

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.theia/tflite');
  final List<ImageResult> _liveBatch = [];
  
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  
  ImageResult? _lastResult;
  ui.Image? _lastUiImage;
  bool _isProcessing = false;

  final Map<String, dynamic> _statsModel = {};
  
  final Map<int, double> _stdDevTolerances = {16: 5.0, 17: 1.5};
  final double _defaultStdDevTolerance = 3.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadStatsModel();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null || !_controller!.value.isInitialized) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadStatsModel() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/keypoint_stats_model.json');
      final List<dynamic> jsonResult = json.decode(jsonString);
      for (var item in jsonResult) {
        _statsModel[item['keypoint_index'].toString()] = item;
      }
    } catch (e) {
      print('Error al cargar el modelo estadístico: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.high, enableAudio: false);
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }

  Future<void> _takeAndProcessPicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      final dynamic rawResult = await platform.invokeMethod('runTFLite', {'path': image.path});
      
      if (rawResult != null) {
        _validateAndParseResult(image, rawResult);
      } else {
        throw Exception("El resultado nativo fue nulo.");
      }

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error durante el análisis: $e"), backgroundColor: Colors.red),
      );
      setState(() => _isProcessing = false);
    }
  }

  // =======================================================================
  // FUNCIÓN DE VALIDACIÓN SIMPLIFICADA
  // =======================================================================
  void _validateAndParseResult(XFile imageFile, List<dynamic> rawResult) {
    
    final result = ImageResult(imageFile: imageFile);
    
    // Kotlin nos devuelve una lista: [box, keypoints, confidences]
    // Todos los datos ya están NORMALIZADOS (0.0 - 1.0)
    final List<double> boxData = (rawResult[0] as List<dynamic>).cast<double>();
    final List<double> keypointData = (rawResult[1] as List<dynamic>).cast<double>();
    // final List<double> confidences = (rawResult[2] as List<dynamic>).cast<double>(); // No la usamos aquí

    if (boxData.isEmpty || keypointData.isEmpty) {
        result.status = ImageStatus.rejected;
        result.rejectionReason = 'Baja confianza de detección.';
    } else {
      // 1. Extraemos la caja (cx, cy, w, h)
      final boxCx = boxData[0];
      final boxCy = boxData[1];
      final boxW = boxData[2];
      final boxH = boxData[3];
      result.box = [boxCx - boxW / 2, boxCy - boxH / 2, boxCx + boxW / 2, boxCy + boxH / 2];

      // 2. Re-organizamos los keypoints de [x1, y1, x2, y2...] a [[x1, y1], [x2, y2]...]
      List<List<double>> keypoints = [];
      for (int i = 0; i < keypointData.length; i += 2) {
          keypoints.add([keypointData[i], keypointData[i+1]]);
      }
      result.keypoints = keypoints;
      
      List<String> failedPoints = [];
      
      // 3. Filtramos los keypoints (¡ya están normalizados!)
      for (int i = 0; i < keypoints.length; i++) {
          final int pointIndex = i;
          final kpt = keypoints[i];
          final stats = _statsModel[pointIndex.toString()];
          final tolerance = _stdDevTolerances[pointIndex] ?? _defaultStdDevTolerance;
          
          final relativeX = kpt[0] - boxCx;
          final relativeY = kpt[1] - boxCy;

          if (stats != null && (
              (relativeX - stats['mean_x']).abs() > tolerance * stats['std_dev_x'] ||
              (relativeY - stats['mean_y']).abs() > tolerance * stats['std_dev_y']
          )) {
              failedPoints.add(pointIndex.toString());
          }
      }
      
      // 4. Asignamos estado final
      if (failedPoints.isEmpty) {
        result.status = ImageStatus.approved;
        result.rejectionReason = '';
      } else {
        result.status = ImageStatus.rejected;
        result.rejectionReason = "Incoherencia punto(s): ${failedPoints.join(', ')}";
      }
    }

    _loadImage(File(imageFile.path)).then((uiImage) {
      setState(() {
        _lastUiImage = uiImage;
        _lastResult = result;
        _isProcessing = false;
      });
    });
  }
  
  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }

  void _acceptResult() {
    if (_lastResult != null) {
      if (_lastResult!.status == ImageStatus.approved || _lastResult!.status == ImageStatus.edited) {
        setState(() {
          _liveBatch.add(_lastResult!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Espécimen añadido al lote. Total: ${_liveBatch.length}"), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
        );
      } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rechazado: ${_lastResult!.rejectionReason}. No se añadió."), backgroundColor: Colors.orange),
      );
    }
    }
    _clearLastResult();
  }

  void _discardResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resultado descartado."), duration: Duration(seconds: 1)),
    );
    _clearLastResult();
  }
  
  void _clearLastResult(){
     setState(() {
      _lastResult = null;
      _lastUiImage = null;
    });
  }
  
  Future<void> _editResult() async {
    if (_lastResult == null || _controller == null) return;

    try {
      await _controller!.pausePreview();

      final bool? changesMade = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            results: [_lastResult!],
            initialIndex: 0,
          ),
        ),
      );
      
      await _controller!.resumePreview();

      if (changesMade == true && mounted) {
        _acceptResult();
      }
    } catch (e) {
      print("Error al pausar/reanudar la cámara: $e");
      _initializeCamera();
    }
  }

  Future<void> _exportLiveBatch() async {
    if (_liveBatch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay especímenes en el lote para exportar.")),
      );
      return;
    }

    List<List<dynamic>> rows = [];
    List<dynamic> headerRow = ['image_name'];
    for (int i = 1; i <= 32; i++) {
      headerRow.add('kpt${i}_x');
      headerRow.add('kpt${i}_y');
    }
    rows.add(headerRow);

    for (var result in _liveBatch) {
      if(result.keypoints == null) continue;
      List<dynamic> row = [result.imageFile.name];
      for (var kpt in result.keypoints!) {
        row.add(kpt[0]);
        row.add(kpt[1]);
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    
    final int specimenCount = _liveBatch.length;
    final String timestamp = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());
    
    final String fileName = "theia_poblacion_${timestamp}_$specimenCount-especimenes-live.csv";
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Éxito! Se creó '$fileName' con $specimenCount especímenes."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _liveBatch.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al exportar: $e"), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Live'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Lote: ${_liveBatch.length} especímenes',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (_controller != null && _controller!.value.isInitialized) {
                  return CameraPreview(_controller!);
                }
                return const Center(child: Text("Error al cargar la cámara."));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          if (_lastResult != null && _lastUiImage != null)
            _buildResultOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomPanel(),
    );
  }

  Widget _buildResultOverlay() {
    final bool isApproved = _lastResult?.status == ImageStatus.approved;
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Center(
                child: FittedBox(
                  child: SizedBox(
                    width: _lastUiImage!.width.toDouble(),
                    height: _lastUiImage!.height.toDouble(),
                    child: CustomPaint(
                      painter: KeypointPainter(
                        image: _lastUiImage!,
                        keypoints: _lastResult!.keypoints,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            color: isApproved ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isApproved ? Icons.check_circle : Icons.cancel, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isApproved ? 'APROBADO' : 'RECHAZADO: ${_lastResult?.rejectionReason}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_lastResult != null) {
      final bool isApproved = _lastResult!.status == ImageStatus.approved;
      return BottomAppBar(
        color: Colors.black.withOpacity(0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _discardResult,
              icon: const Icon(Icons.close),
              label: const Text('Descartar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            
            if (isApproved)
              ElevatedButton.icon(
                onPressed: _acceptResult,
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              )
            else
              ElevatedButton.icon(
                onPressed: _editResult,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
          ],
        ),
      );
    }
    
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            onPressed: _liveBatch.length >= 3 ? _exportLiveBatch : null,
            icon: const Icon(Icons.download),
            label: const Text('Exportar Lote'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              disabledBackgroundColor: Colors.grey.withOpacity(0.5)
            ),
          ),
          FloatingActionButton(
            onPressed: _takeAndProcessPicture,
            child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 80), 
        ],
      ),
    );
  }
}