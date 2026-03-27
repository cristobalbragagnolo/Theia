// lib/screens/batch_mode_screen.dart (MODIFICADO timer final)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/screens/detail_screen.dart';

enum BatchSortMode { original, rejectedFirst, editedFirst }

class BatchModeScreen extends StatefulWidget {
  const BatchModeScreen({super.key});

  @override
  State<BatchModeScreen> createState() => _BatchModeScreenState();
}

class _BatchModeScreenState extends State<BatchModeScreen> {
  final DataRepository _dataRepository = DataRepository();
  static const platform = MethodChannel('com.example.theia/tflite');
  final ImagePicker _picker = ImagePicker();

  final Map<String, dynamic> _statsModel = {};
  bool _isProcessing = false;
  bool _isButtonPressed = false;
  BatchSortMode _sortMode = BatchSortMode.original;

  bool _isCancelled = false;
  int _processedCount = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiUpdateTimer;
  String _elapsedTime = "00:00";
// tolerancia especial para puntos con mucha variacion. Lo he quitado porque el nuevo modelo es muy potente y estaba corrigiendo mal. NOTA: va desde el 0 al 31.
  final Map<int, double> _stdDevTolerances = {};
  final double _defaultStdDevTolerance = 3.0;

  // ELIMINADO: 'MODEL_INPUT_SIZE' ya no es necesario aquí

  int get _exportableCount => _dataRepository.imageResults
      .where((res) => (res.status == ImageStatus.approved || res.status == ImageStatus.edited))
      .length;

  @override
  void initState() {
    super.initState();
    _loadStatsModel();
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStatsModel() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/keypoint_stats_model.json');
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

  Future<void> _pickImages({bool append = false}) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        if (!append) {
          _dataRepository.clear();
        }
        _dataRepository.addAllResults(
            images.map((file) => ImageResult(imageFile: file)).toList());
      });
    }
  }

  void _clearImages() {
    if (_dataRepository.imageResults.isEmpty) return;
    setState(() {
      _dataRepository.clear();
    });
  }

  void _stopProcessing() {
    setState(() {
      _isCancelled = true;
    });
  }

  Future<void> _processImages() async {
    if (_dataRepository.imageResults.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isCancelled = false;
      _processedCount = 0;
      _elapsedTime = "00:00";
    });

    _stopwatch.reset();
    _stopwatch.start();

    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isProcessing) {
        timer.cancel();
        return;
      }
      final duration = _stopwatch.elapsed;
      final minutes =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      setState(() {
        _elapsedTime = "$minutes:$seconds";
      });
    });

    try {
      for (int i = 0; i < _dataRepository.imageResults.length; i++) {
        if (_isCancelled) {
          if (kDebugMode) {
            debugPrint("Procesamiento cancelado por el usuario.");
          }
          break;
        }

        setState(() {
          _processedCount = i + 1;
        });

        try {
          final List<dynamic>? result = await platform.invokeMethod(
            'runTFLite',
            {
              'path': _dataRepository.imageResults[i].imageFile.path,
            },
          );
          if (result != null) {
            _validateAndParseResult(i, result);
          }
        } on PlatformException catch (e) {
          setState(() {
            _dataRepository.imageResults[i].status = ImageStatus.rejected;
            _dataRepository.imageResults[i].rejectionReason =
                'Error nativo: ${e.message}';
          });
        }
      }
    } finally {
      _stopwatch.stop();
      _uiUpdateTimer?.cancel();

      // --- INICIO DE MODIFICACIÓN ---

      // 1. Calcular el tiempo final exacto del stopwatch
      final duration = _stopwatch.elapsed;
      final minutes =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      final finalElapsedTime = "$minutes:$seconds";

      // 2. Capturar el conteo final
      final int finalProcessedCount = _processedCount;

      setState(() {
        _isProcessing = false;
        _elapsedTime = finalElapsedTime; // Actualiza el estado con el tiempo final
      });

      // 3. Mostrar el SnackBar con el resultado final
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Proceso completado en $finalElapsedTime. Se procesaron $finalProcessedCount imágenes."),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
      // --- FIN DE MODIFICACIÓN ---
    }
  }

  // =======================================================================
  // FUNCIÓN DE VALIDACIÓN SIMPLIFICADA
  // =======================================================================
  void _validateAndParseResult(int imageIndex, List<dynamic> rawResult) {
    
    final result = _dataRepository.imageResults[imageIndex];

    // Kotlin nos devuelve una lista: [box, keypoints, confidences]
    // Todos los datos ya están NORMALIZADOS (0.0 - 1.0)
    final List<double> boxData = (rawResult[0] as List<dynamic>).cast<double>();
    final List<double> keypointData = (rawResult[1] as List<dynamic>).cast<double>();

    if (boxData.isEmpty || keypointData.isEmpty) {
      setState(() {
        result.status = ImageStatus.rejected;
        result.rejectionReason = 'Baja confianza de detección.';
      });
      return;
    }

    // 1. Extraemos la caja (cx, cy, w, h)
    final boxCx = boxData[0];
    final boxCy = boxData[1];
    final boxW = boxData[2];
    final boxH = boxData[3];
    
    final finalBox = [
      boxCx - boxW / 2,
      boxCy - boxH / 2,
      boxCx + boxW / 2,
      boxCy + boxH / 2
    ];

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
    setState(() {
      if (failedPoints.isEmpty) {
        result.status = ImageStatus.approved;
        result.rejectionReason = '';
      } else {
        result.status = ImageStatus.rejected;
        result.rejectionReason = "Incoherencia punto(s): ${failedPoints.join(', ')}";
      }
      result.box = finalBox;
    });
  }

  void _navigateToDetail(int index) async {
    final List<ImageResult> processedResults = _dataRepository.imageResults
        .where((res) => res.status != ImageStatus.pending)
        .toList();
    final currentImage = _dataRepository.imageResults[index];
    final int newIndex =
        processedResults.indexWhere((r) => r.imageFile.path == currentImage.imageFile.path);

    if (newIndex != -1) {
      final bool? result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            results: processedResults,
            initialIndex: newIndex,
          ),
        ),
      );

      if (result == true && mounted) {
        setState(() {
          // El estado ya se actualizó en DetailScreen, solo redibujamos aquí.
        });
      }
    }
  }

  Future<void> _exportResults() async {
    final List<ImageResult> exportableResults = _dataRepository.imageResults
        .where((res) => (res.status == ImageStatus.approved || res.status == ImageStatus.edited) && res.keypoints != null)
        .toList();

    if (exportableResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay resultados aprobados o editados para exportar.")),
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

    for (var result in exportableResults) {
      List<dynamic> row = [];
      row.add(result.imageFile.name);
      for (var kpt in result.keypoints!) {
        row.add(kpt[0]);
        row.add(kpt[1]);
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final int specimenCount = exportableResults.length;
    final String timestamp =
        DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());
    final String fileName =
        "theia_poblacion_${timestamp}_$specimenCount-especimenes.csv";

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final file = File(path);
    await file.writeAsString(csv);

    if (kDebugMode) {
      debugPrint("Resultados exportados a: $path");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("¡Éxito! Se creó '$fileName' con $specimenCount especímenes."),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // =======================================================================
    // OBTENEMOS EL RATIO DE PÍXELES DEL DISPOSITIVO
    // =======================================================================
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Calculamos un tamaño de caché en píxeles físicos.
    // 120 * 3.0 = 360px (ejemplo en un teléfono 3x)
    final cacheSize = (64 * pixelRatio).round();
    
    final scheme = Theme.of(context).colorScheme;
    final shadowColor = Theme.of(context).shadowColor;
    final sortedEntries = _buildSortedEntries();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Batch'),
        actions: [
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Text(
                      "$_elapsedTime | $_processedCount/${_dataRepository.imageResults.length}"),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.stop_circle, color: scheme.error),
                    onPressed: _stopProcessing,
                    tooltip: 'Detener Proceso',
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTapDown: (_) => setState(() => _isButtonPressed = true),
              onTapUp: (_) => setState(() => _isButtonPressed = false),
              onTapCancel: () => setState(() => _isButtonPressed = false),
              onTap: _processImages,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isButtonPressed
                        ? [
                            scheme.primary,
                            scheme.primary.withValues(alpha: 0.85),
                          ]
                        : [
                            scheme.primaryContainer,
                            scheme.primary,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: scheme.onPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Aplicar IA',
                      style: TextStyle(
                          color: scheme.onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Agregar de la Galería'),
                        onPressed: _isProcessing ? null : () => _pickImages(append: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Reemplazar Lista'),
                        onPressed: _isProcessing ? null : () => _pickImages(append: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Imágenes cargadas: ${_dataRepository.imageResults.length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isProcessing || _dataRepository.imageResults.isEmpty ? null : _clearImages,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Vaciar Lista'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Ordenar por:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<BatchSortMode>(
                    value: _sortMode,
                    isExpanded: true,
                    onChanged: _isProcessing
                        ? null
                        : (mode) {
                            if (mode == null) return;
                            setState(() {
                              _sortMode = mode;
                            });
                          },
                    items: BatchSortMode.values
                        .map(
                          (mode) => DropdownMenuItem(
                            value: mode,
                            child: Text(_sortModeLabel(mode)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                final result = entry.value;
                
                Color overlayColor = Colors.transparent;
                Color? overlayIconColor;
                IconData? overlayIcon;
                
                switch(result.status) {
                  case ImageStatus.approved:
                    overlayColor = scheme.primary.withValues(alpha: 0.5);
                    overlayIcon = Icons.check_circle;
                    overlayIconColor = scheme.onPrimary;
                    break;
                  case ImageStatus.rejected:
                    overlayColor = scheme.error.withValues(alpha: 0.5);
                    overlayIcon = Icons.cancel;
                    overlayIconColor = scheme.onError;
                    break;
                  case ImageStatus.edited:
                    overlayColor = scheme.secondary.withValues(alpha: 0.5);
                    overlayIcon = Icons.edit;
                    overlayIconColor = scheme.onSecondary;
                    break;
                  case ImageStatus.pending:
                    break;
                }

                return GestureDetector(
                  onTap: () {
                    if (result.status != ImageStatus.pending) {
                       _navigateToDetail(entry.key);
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(result.imageFile.path),
                        fit: BoxFit.cover,
                        cacheWidth: cacheSize,
                        cacheHeight: cacheSize,
                        filterQuality: FilterQuality.low,
                      ),
                      if (result.status != ImageStatus.pending)
                        Container(decoration: BoxDecoration(color: overlayColor)),
                      if (overlayIcon != null)
                        Tooltip(
                          message: result.status == ImageStatus.rejected ? result.rejectionReason : result.status.name,
                          child: Center(child: Icon(
                            overlayIcon,
                            color: overlayIconColor ?? scheme.onSurface,
                            size: 40,
                          )),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: Text('Exportar ($_exportableCount) Resultados'),
              onPressed: _isProcessing ? null : _exportResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
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

  List<MapEntry<int, ImageResult>> _buildSortedEntries() {
    final entries = _dataRepository.imageResults.asMap().entries.toList();
    switch (_sortMode) {
      case BatchSortMode.original:
        return entries;
      case BatchSortMode.rejectedFirst:
      case BatchSortMode.editedFirst:
        entries.sort((a, b) {
          final weightA = _statusWeight(a.value.status);
          final weightB = _statusWeight(b.value.status);
          if (weightA == weightB) {
            return a.key.compareTo(b.key);
          }
          return weightA.compareTo(weightB);
        });
        return entries;
    }
  }

  int _statusWeight(ImageStatus status) {
    switch (_sortMode) {
      case BatchSortMode.original:
        return 0;
      case BatchSortMode.rejectedFirst:
        return status == ImageStatus.rejected ? 0 : 1;
      case BatchSortMode.editedFirst:
        return status == ImageStatus.edited ? 0 : 1;
    }
  }

  String _sortModeLabel(BatchSortMode mode) {
    switch (mode) {
      case BatchSortMode.original:
        return 'Orden original';
      case BatchSortMode.rejectedFirst:
        return 'Rechazadas primero';
      case BatchSortMode.editedFirst:
        return 'Editadas primero';
    }
  }
}
