import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/services/eco_field_platform.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/theme/theia_input_decoration.dart';
import 'package:theia/widgets/theia_toolbar_action.dart';

enum EcoOutputMode { aiCrop, fullFrame }

class _EcoSessionConfig {
  const _EcoSessionConfig({
    required this.batchName,
    required this.outputMode,
    required this.blurFilterEnabled,
  });

  final String batchName;
  final EcoOutputMode outputMode;
  final bool blurFilterEnabled;
}

class EcoFieldModeScreen extends StatefulWidget {
  const EcoFieldModeScreen({super.key});

  @override
  State<EcoFieldModeScreen> createState() => _EcoFieldModeScreenState();
}

class _EcoFieldModeScreenState extends State<EcoFieldModeScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  bool _isProcessing = false;
  bool _isSessionReady = false;
  int _savedCount = 0;

  String? _batchName;
  String? _sessionFolder;
  String? _telemetryCsvPath;
  EcoOutputMode _outputMode = EcoOutputMode.aiCrop;
  bool _blurFilterEnabled = false;
  bool _sessionPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startSessionFlow(closeScreenOnCancel: true));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    if (state == AppLifecycleState.resumed &&
        (_controller == null || !_controller!.value.isInitialized)) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (mounted) setState(() {});
      });
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing Eco camera: $e');
      }
    }
  }

  Future<void> _startSessionFlow({required bool closeScreenOnCancel}) async {
    if (_sessionPromptShown) return;
    _sessionPromptShown = true;
    final l = AppLocalizations.of(context)!;
    final config = await _promptSessionConfig();
    _sessionPromptShown = false;

    if (config == null) {
      if (closeScreenOnCancel && mounted) {
        Navigator.of(context).maybePop();
      }
      return;
    }

    final now = DateTime.now();
    final dateTag = DateFormat('dd-MM-yyyy').format(now);
    final batchSanitized = _sanitizeBatch(config.batchName);
    final sessionFolder = 'THEIA_${batchSanitized}_$dateTag';
    final csvPath = await _createTelemetryCsv(sessionFolder);

    if (!mounted) return;
    setState(() {
      _batchName = config.batchName.trim();
      _sessionFolder = sessionFolder;
      _outputMode = config.outputMode;
      _blurFilterEnabled = config.blurFilterEnabled;
      _telemetryCsvPath = csvPath;
      _savedCount = 0;
      _isSessionReady = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.ecoFieldSessionReady(sessionFolder)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Future<_EcoSessionConfig?> _promptSessionConfig() async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    EcoOutputMode mode = EcoOutputMode.aiCrop;
    bool blurFilter = false;
    String? errorText;

    final result = await showDialog<_EcoSessionConfig>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(l.ecoFieldSessionPromptTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: TheiaInputDecoration.outlined(
                        labelText: l.ecoFieldBatchLabel,
                        hintText: l.ecoFieldBatchHint,
                        errorText: errorText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.ecoFieldOutputModeLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    RadioListTile<EcoOutputMode>(
                      contentPadding: EdgeInsets.zero,
                      value: EcoOutputMode.aiCrop,
                      groupValue: mode,
                      onChanged: (value) {
                        if (value == null) return;
                        setLocalState(() => mode = value);
                      },
                      title: Text(l.ecoFieldOutputModeAiCrop),
                    ),
                    RadioListTile<EcoOutputMode>(
                      contentPadding: EdgeInsets.zero,
                      value: EcoOutputMode.fullFrame,
                      groupValue: mode,
                      onChanged: (value) {
                        if (value == null) return;
                        setLocalState(() => mode = value);
                      },
                      title: Text(l.ecoFieldOutputModeFullFrame),
                    ),
                    if (mode == EcoOutputMode.aiCrop)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: blurFilter,
                        onChanged: (value) =>
                            setLocalState(() => blurFilter = value),
                        title: Text(l.ecoFieldBlurFilterLabel),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l.ecoFieldCancelSession),
                ),
                FilledButton(
                  onPressed: () {
                    final batch = controller.text.trim();
                    if (batch.isEmpty) {
                      setLocalState(
                        () => errorText = l.ecoFieldBatchRequired,
                      );
                      return;
                    }
                    Navigator.of(dialogContext).pop(
                      _EcoSessionConfig(
                        batchName: batch,
                        outputMode: mode,
                        blurFilterEnabled: blurFilter,
                      ),
                    );
                  },
                  child: Text(l.ecoFieldStartSession),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<String> _createTelemetryCsv(String sessionFolder) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
    final path = '${dir.path}/eco_field_${sessionFolder}_$timestamp.csv';
    final file = File(path);
    const header = <dynamic>[
      'image_name',
      'latitude',
      'longitude',
      'altitude',
      'gps_accuracy',
      'compass_heading',
      'ai_confidence',
    ];
    final csvHeader = const ListToCsvConverter().convert([header]);
    await file.writeAsString('$csvHeader\n', flush: true);
    return path;
  }

  String _sanitizeBatch(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '')
        .toLowerCase();
    return sanitized.isEmpty ? 'batch' : sanitized;
  }

  String _buildImageName() {
    final session = _sessionFolder ?? 'THEIA_batch';
    final stamp = DateFormat('HHmmss_SSS').format(DateTime.now());
    return '${session}_$stamp.jpg';
  }

  Future<void> _captureAndSave() async {
    if (_isProcessing || !_isSessionReady) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final l = AppLocalizations.of(context)!;

    setState(() => _isProcessing = true);

    String? tempProcessedPath;
    XFile? rawCapture;
    try {
      rawCapture = await controller.takePicture();
      String sourcePath = rawCapture.path;
      String aiConfidenceValue = l.ecoFieldAiConfidenceNA;
      double? aiConfidenceNumeric;

      if (_outputMode == EcoOutputMode.aiCrop) {
        final cropResult = await EcoFieldPlatform.runEcoCrop(
          path: rawCapture.path,
          blurFilterEnabled: _blurFilterEnabled,
        );

        if (!cropResult.ok || cropResult.cropPath == null) {
          if (!mounted) return;
          final reason = _reasonFromCropResult(cropResult, l);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(reason),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }

        sourcePath = cropResult.cropPath!;
        tempProcessedPath = sourcePath;
        aiConfidenceNumeric = cropResult.confidence;
        aiConfidenceValue = aiConfidenceNumeric == null
            ? ''
            : aiConfidenceNumeric.toStringAsFixed(4);
      }

      final imageName = _buildImageName();
      final saveResult = await EcoFieldPlatform.saveImageToGallery(
        sourcePath: sourcePath,
        sessionFolder: _sessionFolder!,
        displayName: imageName,
      );
      final finalName =
          saveResult.displayName.isEmpty ? imageName : saveResult.displayName;

      final telemetry = await EcoFieldPlatform.getTelemetry();
      await _appendTelemetry(
        imageName: finalName,
        telemetry: telemetry,
        aiConfidence: _outputMode == EcoOutputMode.fullFrame
            ? l.ecoFieldAiConfidenceNA
            : aiConfidenceValue,
      );

      if (!mounted) return;
      setState(() {
        _savedCount += 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.ecoFieldCaptureSaved(finalName)),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.ecoFieldCaptureSaveError('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (tempProcessedPath != null) {
        final tempFile = File(tempProcessedPath);
        if (await tempFile.exists()) {
          unawaited(tempFile.delete());
        }
      }
      if (rawCapture != null) {
        final rawFile = File(rawCapture.path);
        if (await rawFile.exists()) {
          unawaited(rawFile.delete());
        }
      }
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _reasonFromCropResult(EcoCropResult result, AppLocalizations l) {
    switch (result.reason) {
      case 'NO_DETECTION':
        return l.ecoFieldCaptureRejectedNoDetection;
      case 'BLUR':
        return l.ecoFieldCaptureRejectedBlur;
      case 'CROP_INVALID':
      case 'DECODE_FAILED':
        return l.ecoFieldCaptureRejectedCrop;
      default:
        return l.ecoFieldCaptureRejectedNoDetection;
    }
  }

  Future<void> _appendTelemetry({
    required String imageName,
    required EcoTelemetry telemetry,
    required String aiConfidence,
  }) async {
    final csvPath = _telemetryCsvPath;
    if (csvPath == null || csvPath.isEmpty) return;
    final file = File(csvPath);
    final row = <dynamic>[
      imageName,
      telemetry.latitude?.toStringAsFixed(7) ?? '',
      telemetry.longitude?.toStringAsFixed(7) ?? '',
      telemetry.altitude?.toStringAsFixed(2) ?? '',
      telemetry.accuracy?.toStringAsFixed(2) ?? '',
      telemetry.heading?.toStringAsFixed(2) ?? '',
      aiConfidence,
    ];
    final csvLine = const ListToCsvConverter().convert([row]);
    await file.writeAsString('$csvLine\n', mode: FileMode.append, flush: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final panelColor = scheme.scrim.withValues(alpha: 0.55);
    final panelTextColor =
        ThemeData.estimateBrightnessForColor(panelColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final modeLabel = _outputMode == EcoOutputMode.aiCrop
        ? l.ecoFieldOutputModeAiCrop
        : l.ecoFieldOutputModeFullFrame;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.ecoFieldTitle),
        actions: [
          TheiaToolbarAction(
            tooltip: l.ecoFieldStartSession,
            icon: Icons.playlist_add,
            onPressed: _isProcessing
                ? null
                : () => _startSessionFlow(closeScreenOnCancel: false),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing || !_isSessionReady ? null : _captureAndSave,
        child: _isProcessing
            ? CircularProgressIndicator(
                strokeWidth: 2.6,
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : const Icon(Icons.camera_alt),
      ),
      body: Stack(
        children: [
          _buildCameraPreview(l),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  88,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.ecoFieldBatchLabel}: ${_batchName ?? '-'}',
                      style: TextStyle(color: panelTextColor),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${l.ecoFieldOutputModeLabel}: $modeLabel',
                      style: TextStyle(color: panelTextColor),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.liveBatchCount(_savedCount),
                      style: TextStyle(color: panelTextColor),
                    ),
                    if (_outputMode == EcoOutputMode.aiCrop) ...[
                      const SizedBox(height: AppSpacing.sm - 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.ecoFieldBlurFilterLabel,
                              style: TextStyle(color: panelTextColor),
                            ),
                          ),
                          Switch.adaptive(
                            value: _blurFilterEnabled,
                            onChanged: _isProcessing
                                ? null
                                : (value) {
                                    setState(() => _blurFilterEnabled = value);
                                  },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(AppLocalizations l) {
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
                if (previewRatio == 0) previewRatio = 1;
                final isPortrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;
                final previewIsPortrait = previewRatio < 1;
                if (previewIsPortrait != isPortrait) {
                  previewRatio = 1 / previewRatio;
                }
                var scale = previewRatio / deviceRatio;
                if (scale < 1) scale = 1 / scale;
                return Container(
                  color: Colors.black,
                  child: Transform.scale(
                    scale: scale,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: previewRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text(l.cameraLoadError));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
