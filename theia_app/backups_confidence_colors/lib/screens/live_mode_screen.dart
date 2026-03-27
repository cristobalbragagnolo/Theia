// lib/screens/live_mode_screen.dart (SIMPLIFICADO)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/utils/status_visuals.dart';
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
  bool _isPreviewPaused = false;
  bool _isLiveFrameProcessing = false;
  int _lastLiveDetectMs = 0;
  bool _isStreamingImages = false;
  List<double>? _livePreviewBox;
  double? _livePreviewConfidence;

  final Map<String, dynamic> _statsModel = {};
  
  final Map<int, double> _stdDevTolerances = {16: 5.0, 17: 1.5};
  final double _defaultStdDevTolerance = 3.0;
  static const int _liveDetectThrottleMs = 350;

  bool get _supportsLiveDetector => Platform.isAndroid;

  bool get _shouldRunLiveDetector {
    if (!_supportsLiveDetector || _isPreviewPaused || _isProcessing || _lastResult != null) {
      return false;
    }
    final controller = _controller;
    if (controller == null) return false;
    return controller.value.isInitialized;
  }

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
      unawaited(_stopLiveImageStream(clearBox: true));
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null || !_controller!.value.isInitialized) {
        _initializeCamera();
      }
    }
  }

  Future<void> _pausePreview() async {
    if (_controller == null || _isPreviewPaused) return;
    try {
      await _stopLiveImageStream(clearBox: true);
      await _controller!.pausePreview();
      _isPreviewPaused = true;
    } catch (_) {}
  }

  Future<void> _resumePreview() async {
    if (_controller == null || !_isPreviewPaused) return;
    try {
      await _controller!.resumePreview();
      _isPreviewPaused = false;
      await _refreshLiveDetectionState();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopLiveImageStream(clearBox: true));
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
      if (kDebugMode) {
        debugPrint('Error al cargar el modelo estadístico: $e');
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {});
          _refreshLiveDetectionState();
        }
      });
      if (mounted) setState(() {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error al inicializar la cámara: $e");
      }
    }
  }

  Future<void> _takeAndProcessPicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing || _lastResult != null) return;
    setState(() => _isProcessing = true);

    try {
      await _stopLiveImageStream();
      final image = await _controller!.takePicture();
      await _pausePreview();
      final dynamic rawResult = await platform.invokeMethod(
        'runTFLite',
        {
          'path': image.path,
        },
      );
      if (rawResult != null) {
        _validateAndParseResult(image, rawResult);
      } else {
        throw Exception("El resultado nativo fue nulo.");
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
      await _resumePreview();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error durante el análisis: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() => _isProcessing = false);
      unawaited(_refreshLiveDetectionState());
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

      final keypoints = _extractKeypoints(keypointData);
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
              failedPoints.add((pointIndex + 1).toString());
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
          SnackBar(
            content: Text("Espécimen añadido al lote. Total: ${_liveBatch.length}"),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rechazado: ${_lastResult!.rejectionReason}. No se añadió."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
    _resumePreview();
  }

  void _retakePhoto() {
    if (_lastResult == null) return;
    _clearLastResult();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Listo para una nueva captura."), duration: Duration(seconds: 1)),
    );
  }
  
  Future<void> _editResult() async {
    if (_lastResult == null || _controller == null) return;

    try {
      await _pausePreview();
      if (!mounted) return;
      final bool? changesMade = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            results: [_lastResult!],
            initialIndex: 0,
          ),
        ),
      );

      if (changesMade == true && mounted) {
        _acceptResult();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error al pausar/reanudar la cámara: $e");
      }
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Éxito! Se creó '$fileName' con $specimenCount especímenes."),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      setState(() {
        _liveBatch.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al exportar: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


  Future<void> _refreshLiveDetectionState() async {
    if (!_supportsLiveDetector) return;
    if (_shouldRunLiveDetector) {
      await _startLiveImageStream();
    } else {
      await _stopLiveImageStream(clearBox: true);
    }
  }

  Future<void> _startLiveImageStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_isStreamingImages || controller.value.isStreamingImages) {
      _isStreamingImages = controller.value.isStreamingImages;
      return;
    }
    try {
      await controller.startImageStream(_handleLiveCameraImage);
      _isStreamingImages = true;
    } catch (e) {
      _isStreamingImages = false;
      if (kDebugMode) {
        debugPrint('No se pudo iniciar el stream de previsualización: $e');
      }
    }
  }

  Future<void> _stopLiveImageStream({bool clearBox = false}) async {
    final controller = _controller;
    if (controller == null) {
      _isStreamingImages = false;
      if (clearBox) _setLivePreviewBox(null, null);
      return;
    }
    final value = controller.value;
    if (!value.isInitialized || !value.isStreamingImages) {
      _isStreamingImages = false;
      if (clearBox) _setLivePreviewBox(null, null);
      return;
    }
    try {
      await controller.stopImageStream();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('No se pudo detener el stream de previsualización: $e');
      }
    } finally {
      _isStreamingImages = false;
      if (clearBox) _setLivePreviewBox(null, null);
    }
  }

  Future<void> _handleLiveCameraImage(CameraImage image) async {
    if (!_supportsLiveDetector) return;
    if (_isLiveFrameProcessing || !_shouldRunLiveDetector) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastLiveDetectMs < _liveDetectThrottleMs) return;
    _isLiveFrameProcessing = true;
    _lastLiveDetectMs = now;
    try {
      final nv21 = _cameraImageToNv21(image);
      if (nv21.isEmpty) {
        _isLiveFrameProcessing = false;
        return;
      }
      final controller = _controller;
      if (controller == null) {
        _isLiveFrameProcessing = false;
        return;
      }
      final rotation = controller.description.sensorOrientation;
      final Map<dynamic, dynamic>? response =
          await platform.invokeMethod<Map<dynamic, dynamic>>(
        'runLiveDetector',
        {
          'bytes': nv21,
          'width': image.width,
          'height': image.height,
          'rotation': rotation,
        },
      );
      if (!mounted) return;
      if (response == null) {
        _setLivePreviewBox(null, null);
        return;
      }
      final dynamic rawBox = response['box'];
      if (rawBox is List && rawBox.length == 4) {
        final List<double> box = rawBox.map((e) => (e as num).toDouble()).toList();
        final double? conf = (response['confidence'] as num?)?.toDouble();
        _setLivePreviewBox(box, conf);
      } else {
        _setLivePreviewBox(null, null);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error durante la detección en vivo: $e');
      }
    } finally {
      _isLiveFrameProcessing = false;
    }
  }

  Uint8List _cameraImageToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    if (image.planes.length < 3) {
      return Uint8List(0);
    }
    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    final int yRowStride = planeY.bytesPerRow;
    final int yPixelStride = planeY.bytesPerPixel ?? 1;
    final int uvRowStride = planeU.bytesPerRow;
    final int uvPixelStride = planeU.bytesPerPixel ?? 1;

    final Uint8List nv21 = Uint8List(width * height * 3 ~/ 2);
    int offset = 0;

    final bytesY = planeY.bytes;
    for (int y = 0; y < height; y++) {
      final int rowOffset = y * yRowStride;
      for (int x = 0; x < width; x++) {
        nv21[offset++] = bytesY[rowOffset + x * yPixelStride];
      }
    }

    final bytesU = planeU.bytes;
    final bytesV = planeV.bytes;
    final halfHeight = height ~/ 2;
    final halfWidth = width ~/ 2;
    for (int y = 0; y < halfHeight; y++) {
      final int rowOffset = y * uvRowStride;
      for (int x = 0; x < halfWidth; x++) {
        final int colOffset = rowOffset + x * uvPixelStride;
        nv21[offset++] = bytesV[colOffset];
        nv21[offset++] = bytesU[colOffset];
      }
    }

    return nv21;
  }

  void _setLivePreviewBox(List<double>? box, double? confidence) {
    if (!mounted) return;
    final bool sameBox = _livePreviewBox != null &&
        box != null &&
        listEquals(_livePreviewBox, box) &&
        _livePreviewConfidence == confidence;
    if (sameBox) return;
    setState(() {
      _livePreviewBox = box;
      _livePreviewConfidence = confidence;
    });
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
          _buildCameraPreview(),
          if (_lastResult != null && _lastUiImage != null)
            _buildResultOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomPanel(),
    );
  }

  Widget _buildResultOverlay() {
    final scheme = Theme.of(context).colorScheme;
    final ImageStatus currentStatus = _lastResult!.status;
    final Color backgroundColor =
        statusColor(currentStatus, scheme) ?? scheme.primary;
    final Color statusOnColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final bool isRejected = currentStatus == ImageStatus.rejected;
    final String bannerText = isRejected
        ? 'RECHAZADO: ${_lastResult?.rejectionReason ?? ''}'
        : (statusLabel(currentStatus)?.toUpperCase() ?? 'RESULTADO');
    return Container(
      color: scheme.scrim.withValues(alpha: 0.6),
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
                          box: _lastResult!.box,
                          boxColor: statusColor(currentStatus, scheme),
                          boxLabel: statusLabel(currentStatus),
                        ),
                      ),
                    ),
                  ),
            ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            color: backgroundColor.withValues(alpha: 0.85),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRejected ? Icons.cancel : Icons.check_circle,
                  color: statusOnColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    bannerText,
                    style: TextStyle(color: statusOnColor, fontWeight: FontWeight.bold),
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

  List<List<double>> _extractKeypoints(List<double> keypointData) {
    if (keypointData.isEmpty) return [];
    const totalPoints = 32;
    final componentsPerPoint = keypointData.length ~/ totalPoints;
    if (componentsPerPoint < 2) return [];
    final stride = componentsPerPoint >= 3 ? 3 : 2;
    var points = keypointData.length ~/ stride;
    if (points > totalPoints) points = totalPoints;

    final List<List<double>> keypoints = [];
    for (int i = 0; i < points; i++) {
      final base = i * stride;
      if (base + 1 >= keypointData.length) break;
      keypoints.add([keypointData[base], keypointData[base + 1]]);
    }
    return keypoints;
  }

  Widget _buildBottomPanel() {
    final scheme = Theme.of(context).colorScheme;
    final disabledColor = Theme.of(context).disabledColor;

    if (_lastResult != null) {
      final bool isApproved = _lastResult!.status == ImageStatus.approved;
      return BottomAppBar(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _discardResult,
                  icon: const Icon(Icons.close),
                  label: const Text('Descartar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isApproved ? _acceptResult : _editResult,
                  icon: Icon(isApproved ? Icons.check : Icons.edit),
                  label: Text(isApproved ? 'Aceptar' : 'Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApproved ? scheme.primary : scheme.tertiary,
                    foregroundColor: isApproved ? scheme.onPrimary : scheme.onTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.camera_front),
                  label: const Text('Repetir'),
                ),
              ),
            ],
          ),
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
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
              disabledBackgroundColor: disabledColor,
            ),
          ),
          FloatingActionButton(
            onPressed: (_isProcessing || _lastResult != null) ? null : _takeAndProcessPicture,
            child: _isProcessing 
              ? CircularProgressIndicator(color: scheme.onPrimary)
              : const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 80), 
        ],
      ),
    );
  }
  
  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_controller != null && _controller!.value.isInitialized) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final deviceRatio =
                    constraints.maxWidth / constraints.maxHeight;
                double previewRatio = _controller!.value.aspectRatio;
                if (previewRatio == 0) {
                  previewRatio = 1;
                }
                final bool isPortrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;
                final bool previewIsPortrait = previewRatio < 1.0;
                if (previewIsPortrait != isPortrait) {
                  // CameraController reports landscape ratio for portrait previews; align it.
                  previewRatio = 1 / previewRatio;
                }
                var scale = previewRatio / deviceRatio;
                if (scale < 1) {
                  scale = 1 / scale;
                }
                final overlayColor = Theme.of(context).colorScheme.tertiary;
                return Container(
                  color: Colors.black,
                  child: Transform.scale(
                    scale: scale,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: previewRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(_controller!),
                            if (_livePreviewBox != null &&
                                _supportsLiveDetector &&
                                _lastResult == null)
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: _LiveBoundingBoxPainter(
                                    box: _livePreviewBox!,
                                    color: overlayColor,
                                    confidence: _livePreviewConfidence,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Error al cargar la cámara."));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _LiveBoundingBoxPainter extends CustomPainter {
  const _LiveBoundingBoxPainter({
    required this.box,
    required this.color,
    this.confidence,
  });

  final List<double> box;
  final Color color;
  final double? confidence;

  @override
  void paint(Canvas canvas, Size size) {
    if (box.length < 4) return;
    final rect = Rect.fromLTRB(
      (box[0].clamp(0.0, 1.0)) * size.width,
      (box[1].clamp(0.0, 1.0)) * size.height,
      (box[2].clamp(0.0, 1.0)) * size.width,
      (box[3].clamp(0.0, 1.0)) * size.height,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color;
    canvas.drawRect(rect, paint);

    if (confidence != null) {
      final labelText = 'LIVE ${(confidence!.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      const double padding = 6;
      final double labelWidth = textPainter.width + padding * 2;
      final double labelHeight = textPainter.height + padding;
      final double dx = rect.left.clamp(0.0, size.width - labelWidth);
      final double dy = (rect.top - labelHeight - 4).clamp(0.0, size.height - labelHeight);
      final labelRect = Rect.fromLTWH(dx, dy, labelWidth, labelHeight);
      final bgPaint = Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(6)),
        bgPaint,
      );
      textPainter.paint(canvas, Offset(dx + padding, dy + padding / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LiveBoundingBoxPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.confidence != confidence ||
        !listEquals(oldDelegate.box, box);
  }
}
