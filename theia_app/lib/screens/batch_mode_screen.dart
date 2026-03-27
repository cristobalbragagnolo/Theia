// lib/screens/batch_mode_screen.dart (MODIFICADO timer final)

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/screens/detail_screen.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/theme/theia_input_decoration.dart';
import 'package:theia/theme/theia_status_palette.dart';
import 'package:theia/utils/status_visuals.dart';
import 'package:theia/widgets/theia_outlined_button.dart';
import 'package:theia/widgets/theia_primary_button.dart';
import 'package:theia/widgets/theia_toolbar_action.dart';

enum BatchSortMode { original, rejectedFirst, editedFirst }

class BatchModeScreen extends StatefulWidget {
  const BatchModeScreen({super.key});

  @override
  State<BatchModeScreen> createState() => _BatchModeScreenState();
}

class _BatchModeScreenState extends State<BatchModeScreen> {
  final DataRepository _dataRepository = DataRepository();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const platform = MethodChannel('com.example.theia/tflite');
  final ImagePicker _picker = ImagePicker();

  bool _isProcessing = false;
  BatchSortMode _sortMode = BatchSortMode.original;

  bool _isCancelled = false;
  int _processedCount = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _uiUpdateTimer;
  String _elapsedTime = "00:00"; // queda para uso futuro/depuración

  // ELIMINADO: 'MODEL_INPUT_SIZE' ya no es necesario aquí

  int get _exportableCount => _dataRepository.imageResults
      .where((res) => (res.status == ImageStatus.approved ||
          res.status == ImageStatus.edited))
      .length;

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
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
    final l = AppLocalizations.of(context)!;

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
        _elapsedTime =
            finalElapsedTime; // Actualiza el estado con el tiempo final
      });

      // 3. Mostrar el SnackBar con el resultado final
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                l.processingComplete(finalElapsedTime, finalProcessedCount)),
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
    final l = AppLocalizations.of(context)!;

    // Kotlin nos devuelve una lista: [box, keypoints, confidences]
    // Todos los datos ya están NORMALIZADOS (0.0 - 1.0)
    final List<double> boxData = (rawResult[0] as List<dynamic>).cast<double>();
    final List<double> keypointData =
        (rawResult[1] as List<dynamic>).cast<double>();
    final List<double> confidences = rawResult.length > 2
        ? (rawResult[2] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList()
        : const [];

    if (boxData.isEmpty || keypointData.isEmpty) {
      setState(() {
        result.status = ImageStatus.rejected;
        result.rejectionReason = l.detectionLowConfidence;
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
    result.confidences = confidences;
    if (kDebugMode) {
      debugPrint(
          'Batch result -> kpts: ${keypoints.length}, confs: ${confidences.length}, sample: ${confidences.take(5).toList()}');
    }

    setState(() {
      result.status = ImageStatus.approved;
      result.rejectionReason = '';
      result.box = finalBox;
    });
  }

  void _navigateToDetail(int index) async {
    final List<ImageResult> processedResults = _dataRepository.imageResults
        .where((res) => res.status != ImageStatus.pending)
        .toList();
    final currentImage = _dataRepository.imageResults[index];
    final int newIndex = processedResults
        .indexWhere((r) => r.imageFile.path == currentImage.imageFile.path);

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
    final l = AppLocalizations.of(context)!;
    final List<ImageResult> exportableResults = _dataRepository.imageResults
        .where((res) =>
            (res.status == ImageStatus.approved ||
                res.status == ImageStatus.edited) &&
            res.keypoints != null)
        .toList();

    if (exportableResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.noExportable)),
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
    final String datasetRoot =
        "theia_poblacion_${timestamp}_$specimenCount-especimenes";
    final String fileName = "${datasetRoot}__LM.csv";

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final file = File(path);
    await file.writeAsString(csv);

    if (kDebugMode) {
      debugPrint("Resultados exportados a: $path");
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.exportSuccess(fileName, specimenCount)),
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
    final l = AppLocalizations.of(context)!;
    final sortedEntries = _buildSortedEntries();
    final totalImages = _dataRepository.imageResults.length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: TheiaToolbarAction(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l.batchTitle),
        actions: [
          TheiaToolbarAction(
            icon: Icons.tune,
            tooltip: l.sortBy,
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isProcessing
          ? FloatingActionButton.extended(
              onPressed: _stopProcessing,
              icon: const Icon(Icons.stop_circle),
              label: Text(l.stopProcess),
              backgroundColor: scheme.error,
            )
          : FloatingActionButton.extended(
              onPressed: _processImages,
              icon: const Icon(Icons.auto_awesome),
              label: Text(l.btnApplyAi),
            ),
      endDrawer: _buildToolsDrawer(context, l, scheme),
      bottomNavigationBar: _buildBottomBar(context, l),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.imagesLoaded(totalImages),
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _elapsedTime,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${_processedCount.clamp(0, totalImages)}/$totalImages',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
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
                final tooltipText = result.status == ImageStatus.rejected
                    ? result.rejectionReason
                    : (statusLabel(context, result.status) ??
                        result.status.name);

                final overlayColor = TheiaStatusPalette.statusOverlayColor(
                  result.status,
                  scheme,
                  theme: Theme.of(context),
                );
                final overlayIcon =
                    TheiaStatusPalette.statusIcon(result.status);
                final overlayIconColor = TheiaStatusPalette.statusOnColor(
                    result.status, scheme,
                    theme: Theme.of(context));

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
                        Container(
                            decoration: BoxDecoration(color: overlayColor)),
                      if (overlayIcon != null)
                        Tooltip(
                          message: tooltipText,
                          child: Center(
                              child: Icon(
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

  String _sortModeLabel(AppLocalizations l, BatchSortMode mode) {
    switch (mode) {
      case BatchSortMode.original:
        return l.sortOriginal;
      case BatchSortMode.rejectedFirst:
        return l.sortRejectedFirst;
      case BatchSortMode.editedFirst:
        return l.sortEditedFirst;
    }
  }

  Widget _buildToolsDrawer(
      BuildContext context, AppLocalizations l, ColorScheme scheme) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TheiaPrimaryButton(
                onPressed: _isProcessing ? null : _exportResults,
                icon: Icons.download,
                label: l.exportResults(_exportableCount),
                minHeight: AppSizes.compactButtonHeight,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.sortBy, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<BatchSortMode>(
                    decoration: TheiaInputDecoration.outlined(),
                    value: _sortMode,
                    onChanged: _isProcessing
                        ? null
                        : (mode) => setState(() => _sortMode = mode!),
                    items: BatchSortMode.values
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(_sortModeLabel(l, mode)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TheiaOutlinedButton(
                icon: Icons.delete_sweep,
                label: l.btnClearList,
                minHeight: AppSizes.compactButtonHeight,
                onPressed: _isProcessing || _dataRepository.imageResults.isEmpty
                    ? null
                    : _clearImages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TheiaPrimaryButton(
                icon: Icons.add_photo_alternate,
                label: l.btnAddGallery,
                minHeight: AppSizes.compactButtonHeight,
                onPressed:
                    _isProcessing ? null : () => _pickImages(append: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      height: 64,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.sm),
              const Spacer(),
              TheiaToolbarAction(
                icon: Icons.tune,
                tooltip: l.sortBy,
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
