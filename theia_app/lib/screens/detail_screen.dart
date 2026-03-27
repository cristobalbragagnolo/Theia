import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/theme/theia_status_palette.dart';
import 'package:theia/utils/status_visuals.dart';
import 'package:theia/widgets/keypoint_painter.dart';
import 'package:theia/widgets/theia_outlined_button.dart';
import 'package:theia/widgets/theia_primary_button.dart';
import 'package:theia/widgets/theia_toolbar_action.dart';

class DetailScreen extends StatefulWidget {
  final List<ImageResult> results;
  final int initialIndex;

  const DetailScreen({
    super.key,
    required this.results,
    required this.initialIndex,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _currentIndex;
  List<List<double>> _editedKeypoints = [];
  int _selectedKeypointIndex = -1;
  bool _hasChanges = false;
  ui.Image? _loadedImage;
  Color _confidenceColor(double conf) =>
      TheiaStatusPalette.confidenceColor(conf, theme: Theme.of(context));

  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadImageAndSetup();
  }

  void _loadImageAndSetup() async {
    final image =
        await _loadImage(File(widget.results[_currentIndex].imageFile.path));
    if (!mounted) return;

    setState(() {
      _loadedImage = image;
      _editedKeypoints = widget.results[_currentIndex].keypoints
              ?.map((p) => List<double>.from(p))
              .toList() ??
          [];
      _selectedKeypointIndex = _editedKeypoints.isNotEmpty ? 0 : -1;
      _transformationController.value = Matrix4.identity();
    });
  }

  void _goToImage(int delta) {
    if (widget.results.isEmpty) return;

    final int newIndex =
        (_currentIndex + delta).clamp(0, widget.results.length - 1);
    if (newIndex == _currentIndex) return;

    setState(() {
      _currentIndex = newIndex;
      _loadedImage = null;
    });

    _loadImageAndSetup();
  }

  void _saveChanges() {
    final currentResult = widget.results[_currentIndex];
    currentResult.keypoints = _editedKeypoints;
    currentResult.status = ImageStatus.edited;
    _hasChanges = true;

    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.detailSaveSuccess),
        backgroundColor: scheme.secondary,
      ),
    );
    Navigator.pop(context, _hasChanges);
  }

  void _selectNextKeypoint() {
    if (_editedKeypoints.isEmpty) return;
    setState(() {
      _selectedKeypointIndex =
          (_selectedKeypointIndex + 1) % _editedKeypoints.length;
    });
  }

  void _selectPreviousKeypoint() {
    if (_editedKeypoints.isEmpty) return;
    setState(() {
      _selectedKeypointIndex =
          (_selectedKeypointIndex - 1 + _editedKeypoints.length) %
              _editedKeypoints.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    String appBarTitle = _selectedKeypointIndex != -1
        ? l.detailMovingPoint(_selectedKeypointIndex + 1)
        : l.detailEditor;

    // Obtenemos el resultado actual para acceder a sus propiedades
    final currentResult = widget.results[_currentIndex];
    final String fileName = currentResult.imageFile.name;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final Color? boxColor =
        statusColor(currentResult.status, scheme, theme: theme);
    final String? statusBadgeLabel = statusLabel(context, currentResult.status);
    final List<double> confidences = currentResult.confidences ?? const [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          actions: [
            TheiaToolbarAction(
              icon: Icons.save,
              onPressed: _saveChanges,
              tooltip: l.detailSaveTooltip,
            )
          ],
        ),
        body: Column(
          children: [
            // NUEVO: Banner informativo que solo aparece si la imagen fue rechazada
            if (currentResult.status == ImageStatus.rejected &&
                currentResult.rejectionReason.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                color: scheme.errorContainer,
                child: Text(
                  l.detailRejectedBanner(currentResult.rejectionReason),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md - 2,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      fileName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.results.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: scheme.secondary),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 32,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: AppSpacing.sm - 2,
                    crossAxisSpacing: AppSpacing.sm - 2,
                    // Al duplicar columnas, bajamos el aspect ratio para mantener altura similar.
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final bool hasValue = index < confidences.length;
                    final double? conf =
                        hasValue ? confidences[index].clamp(0.0, 1.0) : null;
                    final Color color = hasValue
                        ? _confidenceColor(conf!)
                        : scheme.outlineVariant;
                    final bool isSelected = _selectedKeypointIndex == index;
                    return InkWell(
                      onTap: () {
                        if (_editedKeypoints.isNotEmpty &&
                            index < _editedKeypoints.length) {
                          setState(() {
                            _selectedKeypointIndex = index;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isSelected
                              ? color.withValues(alpha: 0.28)
                              : color.withValues(
                                  alpha: hasValue ? 0.18 : 0.08)),
                          borderRadius: BorderRadius.circular(AppRadii.xs),
                          border: Border.all(
                              color: isSelected ? scheme.primary : color),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'P${index + 1}',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: isSelected ? scheme.primary : color,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                height: 1.1,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Text(
                              hasValue
                                  ? '${(conf! * 100).toStringAsFixed(1)}%'
                                  : '--',
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: isSelected ? scheme.primary : color,
                                fontSize: 10,
                                height: 1.1,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _loadedImage == null
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveViewer(
                      transformationController: _transformationController,
                      maxScale: 16.0,
                      minScale: 0.1,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _loadedImage!.width.toDouble(),
                            height: _loadedImage!.height.toDouble(),
                            child: GestureDetector(
                              onTapUp: (details) {
                                if (_selectedKeypointIndex == -1) return;

                                final Offset imagePoint = details.localPosition;

                                setState(() {
                                  _editedKeypoints[_selectedKeypointIndex][0] =
                                      (imagePoint.dx / _loadedImage!.width)
                                          .clamp(0.0, 1.0);
                                  _editedKeypoints[_selectedKeypointIndex][1] =
                                      (imagePoint.dy / _loadedImage!.height)
                                          .clamp(0.0, 1.0);
                                });
                              },
                              child: CustomPaint(
                                painter: KeypointPainter(
                                  image: _loadedImage!,
                                  keypoints: _editedKeypoints,
                                  confidences: currentResult.confidences,
                                  selectedKeypointIndex: _selectedKeypointIndex,
                                  box: currentResult.box,
                                  boxColor: boxColor,
                                  boxLabel: statusBadgeLabel,
                                  semanticTheme: Theme.of(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),

            Container(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
              padding: const EdgeInsets.all(AppSpacing.sm)
                  .copyWith(bottom: AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TheiaPrimaryButton(
                          onPressed: _selectPreviousKeypoint,
                          icon: Icons.arrow_back,
                          label: l.detailPrevPoint,
                          minHeight: AppSizes.compactButtonHeight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TheiaPrimaryButton(
                          onPressed: _selectNextKeypoint,
                          icon: Icons.arrow_forward,
                          label: l.detailNextPoint,
                          minHeight: AppSizes.compactButtonHeight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md - 2),
                  Row(
                    children: [
                      Expanded(
                        child: TheiaOutlinedButton(
                          onPressed:
                              _currentIndex > 0 ? () => _goToImage(-1) : null,
                          icon: Icons.skip_previous,
                          label: l.detailPrevImage,
                          minHeight: AppSizes.compactButtonHeight,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TheiaOutlinedButton(
                          onPressed: _currentIndex < widget.results.length - 1
                              ? () => _goToImage(1)
                              : null,
                          icon: Icons.skip_next,
                          label: l.detailNextImage,
                          minHeight: AppSizes.compactButtonHeight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }
}
