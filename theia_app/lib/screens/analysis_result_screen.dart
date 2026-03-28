// lib/screens/analysis_result_screen.dart
//
// Resultados GPA+PCA con:
// - Wireframes ±2DE SIEMPRE con vista correcta (aplico X<->Y + flip Y en el pintor)
// - Toggles de signo por PC (PC1/PC2/PC3) para las deformaciones
// - Tabla de scores a ancho completo
// - Sección de interpretación + guardado CSV (sin dependencia de 'path')
// - Recalcula PCA internamente a partir de alignedShapes (runPCA)

import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart' hide Axis;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/theme/theia_input_decoration.dart';
import 'package:theia/widgets/theia_nav_text_button.dart';
import 'package:theia/widgets/theia_page_layout.dart';
import 'package:theia/widgets/theia_primary_button.dart';
import 'package:theia/widgets/theia_section_card.dart';

import '../analysis/analysis_constants.dart';
import '../analysis/morph_analysis.dart';
import 'morphospace_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>>
      pcaScores; // nombres/PC previos (para XY y tabla)
  final List<Matrix> alignedShapes; // GPA result (p x 2) por espécimen
  final List<Matrix>? rawShapes; // Landmarks originales (p x 2), opcional
  final Matrix meanShape; // legado (no imprescindible)
  final Vector pc1Eigenvector; // legado
  final Vector pc2Eigenvector; // legado
  final String selectedFileName; // nombre del CSV fuente
  final String? workingDatasetRoot; // dataset activo para export de análisis
  final String? workingRunTag; // run activo (Axx) para sobrescritura
  final Map<String, String> plotUrls; // sin uso
  final String serverUrl; // sin uso

  const AnalysisResultScreen({
    super.key,
    required this.pcaScores,
    required this.alignedShapes,
    this.rawShapes,
    required this.meanShape,
    required this.pc1Eigenvector,
    required this.pc2Eigenvector,
    required this.selectedFileName,
    this.workingDatasetRoot,
    this.workingRunTag,
    required this.plotUrls,
    required this.serverUrl,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  Map<String, dynamic>?
      _pca; // scores, pcs, eigenvalues, varianceExplainedRatio
  final _interpCtrl = TextEditingController();

  late final List<bool> _invertPcs;

  // Navegación interna
  final _scrollCtl = ScrollController();
  final _wireframesKey = GlobalKey();
  final _tableKey = GlobalKey();
  final _interpretKey = GlobalKey();

  // Estilo
  static const double _wfPanelHeight = 110;

  @override
  void initState() {
    super.initState();
    _invertPcs = List<bool>.filled(analysisPrincipalComponents, false);
    // Recalcula PCA localmente para no depender de claves “legacy”
    try {
      _pca = MorphometricAnalysis.runPCA(
        widget.alignedShapes,
        k: analysisPrincipalComponents,
      );
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.analysisPcaError('$e'))),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_pca == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // === Extrae objetos del PCA (consistentes con morph_analysis.dart)
    final Matrix scores = _pca!['scores'] as Matrix;
    final Matrix pcs = _pca!['pcs'] as Matrix;
    final Vector evals = _pca!['eigenvalues'] as Vector;
    final List<double> explainedPct =
        (_pca!['varianceExplainedRatio'] as Vector)
            .toList()
            .map((v) => v * 100.0)
            .toList();

    final int componentCount =
        math.min(analysisPrincipalComponents, pcs.columnCount);
    final Matrix meanShape = _meanOf(widget.alignedShapes);

    final List<_PcWireframeData> wireframes = [];
    for (var idx = 0; idx < componentCount; idx++) {
      var loading = pcs.getColumn(idx);
      if (_invertPcs[idx]) {
        loading = loading * -1.0;
      }
      final double lambda = idx < evals.length ? evals[idx] : 0.0;
      final double t = lambda > 0 ? 2.0 * math.sqrt(lambda) : 0.0;
      wireframes.add(
        _PcWireframeData(
          index: idx,
          title:
              'PC${idx + 1} (${idx < explainedPct.length ? explainedPct[idx].toStringAsFixed(1) : '0.0'}%)',
          minus: _deform(meanShape, loading, -t),
          plus: _deform(meanShape, loading, t),
        ),
      );
    }

    final imageNames =
        widget.pcaScores.map((m) => m['image_name']?.toString() ?? '').toList();

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color defColor = scheme.tertiary;
    final Color meanColor = scheme.primary.withValues(alpha: 0.95);

    return Scaffold(
      appBar: AppBar(title: Text(l.analysisTitle)),
      bottomNavigationBar: BottomAppBar(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              TheiaNavTextButton(
                  icon: Icons.show_chart,
                  label: 'WF',
                  onTap: () => _jumpTo(_wireframesKey)),
              TheiaNavTextButton(
                  icon: Icons.table_chart,
                  label: l.analysisNavTable,
                  onTap: () => _jumpTo(_tableKey)),
              TheiaNavTextButton(
                icon: Icons.scatter_plot,
                label: 'XY',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MorphospaceScreen(
                        pcaScores: widget.pcaScores,
                        alignedShapes: widget.alignedShapes,
                        meanShape: meanShape,
                      ),
                    ),
                  );
                },
              ),
              TheiaNavTextButton(
                  icon: Icons.save_alt,
                  label: l.analysisNavSave,
                  onTap: () => _jumpTo(_interpretKey)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollCtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Wireframes =====
            TheiaPagePadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: _sectionTitle(l.analysisWireframesSection,
                  key: _wireframesKey),
            ),

            if (wireframes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(l.analysisNoComponents),
              )
            else ...[
              for (final wf in wireframes)
                _wireframeRow(
                  context: context,
                  title: wf.title,
                  mean: meanShape,
                  minus: wf.minus,
                  plus: wf.plus,
                  defColor: defColor,
                  meanColor: meanColor,
                ),
              TheiaPagePadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm - 2,
                  AppSpacing.md,
                  0,
                ),
                child: Row(
                  children: List.generate(
                    wireframes.length,
                    (idx) => Expanded(
                      child: _MiniSwitch(
                        label: 'PC${idx + 1}',
                        value: _invertPcs[idx],
                        onChanged: (v) => setState(() => _invertPcs[idx] = v),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),
            const Divider(),

            // ===== Tabla de scores (ancho completo) =====
            TheiaPagePadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: _sectionTitle(l.analysisScoresSection, key: _tableKey),
            ),
            TheiaPagePadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm - 2,
                AppSpacing.md,
                0,
              ),
              child: _buildScoresTable(
                names: imageNames,
                scores: scores,
                explainedPct: explainedPct,
                componentCount: componentCount,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ===== Interpretación / Guardado =====
            TheiaPagePadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _sectionTitle(l.analysisInterpretationSection,
                  key: _interpretKey),
            ),
            TheiaPagePadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm - 2,
                AppSpacing.md,
                0,
              ),
              child: TextField(
                controller: _interpCtrl,
                maxLines: 5,
                decoration: TheiaInputDecoration.outlined(
                  hintText: l.analysisInterpretationHint,
                ),
              ),
            ),
            TheiaPagePadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TheiaPrimaryButton(
                        onPressed: () {
                          _exportCsv();
                        },
                        minHeight: AppSizes.buttonHeight,
                        icon: Icons.save_alt,
                        label: l.analysisSaveWithInterpretation,
                      ),
                      const SizedBox(height: AppSpacing.md - 2),
                      TheiaPrimaryButton(
                        onPressed: () {
                          _shareExportFiles();
                        },
                        minHeight: AppSizes.buttonHeight,
                        icon: Icons.share,
                        label: l.shareExport,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const TheiaPagePadding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: _HcaiNote(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers de UI ----------
  Widget _sectionTitle(String text, {Key? key}) {
    return Container(
      key: key,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  void _jumpTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      alignment: 0.0,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildScoresTable({
    required List<String> names,
    required Matrix scores,
    required List<double> explainedPct,
    required int componentCount,
  }) {
    final l = AppLocalizations.of(context)!;
    final hdrTop = Theme.of(context).textTheme.titleSmall;
    final hdrPct = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.85),
          fontWeight: FontWeight.w700,
        );
    final cellStyle = Theme.of(context).textTheme.bodyLarge;

    Widget twoLineHeader(String top, String pct) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(top, style: hdrTop),
            Text(pct, style: hdrPct),
          ],
        );

    // Fuerza ancho mínimo = ancho de pantalla para evitar hueco a la derecha
    final minW =
        MediaQuery.of(context).size.width - 24; // padding lateral 12+12
    final columns = <DataColumn>[
      DataColumn(label: twoLineHeader(l.analysisCsvHeaderImage, '')),
    ];
    for (var idx = 0; idx < componentCount; idx++) {
      final pctLabel = idx < explainedPct.length
          ? '${explainedPct[idx].toStringAsFixed(1)}%'
          : '—';
      columns.add(
        DataColumn(label: twoLineHeader('PC${idx + 1}', pctLabel)),
      );
    }

    return TheiaSectionCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minW),
          child: DataTable(
            horizontalMargin: 6,
            columnSpacing: 18,
            headingRowHeight: 54,
            dataRowMinHeight: 48,
            columns: columns,
            rows: List<DataRow>.generate(names.length, (i) {
              final Vector row = i < scores.rowCount
                  ? scores.getRow(i)
                  : Vector.fromList(List<double>.filled(componentCount, 0.0));
              final cells = <DataCell>[
                DataCell(Text(names[i], style: cellStyle)),
              ];
              for (var idx = 0; idx < componentCount; idx++) {
                final value = row.length > idx ? row[idx] : 0.0;
                cells.add(
                    DataCell(Text(value.toStringAsFixed(4), style: cellStyle)));
              }
              return DataRow(cells: cells);
            }),
          ),
        ),
      ),
    );
  }

  Widget _wireframeRow({
    required BuildContext context,
    required String title,
    required Matrix mean,
    required Matrix minus,
    required Matrix plus,
    required Color defColor,
    required Color meanColor,
  }) {
    final l = AppLocalizations.of(context)!;
    final captionStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          SizedBox(
            height: _wfPanelHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _WireframeCard(
                    meanShape: mean,
                    deformed: minus,
                    drawMean: false,
                    drawDef: true,
                    defColor: defColor,
                    meanColor: meanColor,
                  ),
                ),
                Expanded(
                  child: _WireframeCard(
                    meanShape: mean,
                    deformed: mean,
                    drawMean: true,
                    drawDef: false,
                    defColor: defColor,
                    meanColor: meanColor,
                  ),
                ),
                Expanded(
                  child: _WireframeCard(
                    meanShape: mean,
                    deformed: plus,
                    drawMean: false,
                    drawDef: true,
                    defColor: defColor,
                    meanColor: meanColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(child: Center(child: Text('−2DE', style: captionStyle))),
              Expanded(
                child: Center(
                  child: Text(l.analysisWireframeMeanLabel(title),
                      style: captionStyle),
                ),
              ),
              Expanded(child: Center(child: Text('+2DE', style: captionStyle))),
            ],
          ),
        ],
      ),
    );
  }

  // ======== Geometría de deformación ========
  Matrix _deform(Matrix meanShape, Vector loading, double t) {
    final Vector meanFlat = _shapeToVector(meanShape);
    final Vector def = meanFlat + loading * t;
    return _vectorToShape(def);
  }

  Matrix _meanOf(List<Matrix> shapes) {
    final p = shapes.first.rowCount;
    final acc = List.generate(p, (_) => List<double>.filled(2, 0.0));
    for (final s in shapes) {
      for (var i = 0; i < p; i++) {
        acc[i][0] += s[i][0];
        acc[i][1] += s[i][1];
      }
    }
    final n = shapes.length.toDouble();
    final rows = <Vector>[];
    for (var i = 0; i < p; i++) {
      rows.add(Vector.fromList([acc[i][0] / n, acc[i][1] / n]));
    }
    return Matrix.fromRows(rows);
  }

  Vector _shapeToVector(Matrix m) {
    final out = <double>[];
    for (var r = 0; r < m.rowCount; r++) {
      final row = m.getRow(r);
      out.add(row[0]);
      out.add(row[1]);
    }
    return Vector.fromList(out);
  }

  Matrix _vectorToShape(Vector v) {
    final p = v.length ~/ 2;
    final rows = <Vector>[];
    for (var i = 0; i < p; i++) {
      rows.add(Vector.fromList([v[2 * i], v[2 * i + 1]]));
    }
    return Matrix.fromRows(rows);
  }

  // ---------- Guardar CSV ----------
  Future<List<String>> _exportCsv({bool showSnack = true}) async {
    final l = AppLocalizations.of(context)!;
    final dir = await getApplicationDocumentsDirectory();

    final sourceFileName = widget.selectedFileName.contains('.')
        ? widget.selectedFileName
        : '${widget.selectedFileName}.csv';
    final datasetRoot =
        widget.workingDatasetRoot ?? _datasetRootFromSource(sourceFileName);
    final runTag = widget.workingRunTag ?? _runTagFromSource(sourceFileName);

    final outName = '${datasetRoot}__ANL_$runTag.csv';
    final outPath = '${dir.path}/$outName';
    final file = File(outPath);

    final Matrix scores = _pca!['scores'] as Matrix;
    final List<double> explainedPct =
        (_pca!['varianceExplainedRatio'] as Vector)
            .toList()
            .map((v) => v * 100.0)
            .toList();
    final interp = _interpCtrl.text.trim().isEmpty
        ? l.analysisNoInterpretation
        : _interpCtrl.text.trim();
    final names =
        widget.pcaScores.map((m) => m['image_name']?.toString() ?? '').toList();

    final rows = <List<dynamic>>[];
    rows.add([
      l.analysisCsvHeaderImage,
      'PC1 (${explainedPct[0].toStringAsFixed(1)}%)',
      'PC2 (${explainedPct[1].toStringAsFixed(1)}%)',
      'PC3 (${explainedPct[2].toStringAsFixed(1)}%)',
      l.analysisCsvHeaderInterpretation
    ]);

    for (var i = 0; i < names.length && i < scores.rowCount; i++) {
      final r = scores.getRow(i);
      rows.add([
        names[i],
        r[0].toStringAsFixed(6),
        r[1].toStringAsFixed(6),
        r[2].toStringAsFixed(6),
        interp
      ]);
    }

    final csv =
        rows.map((r) => r.map((c) => c.toString()).join(',')).join('\n');
    await file.writeAsString(csv);

    // Guarda también el archivo enriquecido con el mismo runTag
    final jsonPath = await _exportFullAnalysisJson(
      dir: dir,
      sourceFileName: sourceFileName,
      datasetRoot: datasetRoot,
      runTag: runTag,
      interp: interp,
    );

    if (mounted && showSnack) {
      final msg = jsonPath != null
          ? l.analysisExportedBoth(outName, jsonPath.split('/').last)
          : l.analysisExportedSingle(outName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return [
      outPath,
      if (jsonPath != null) jsonPath,
    ];
  }

  // Guarda todas las matrices necesarias para reproducir el análisis (JSON)
  Future<String?> _exportFullAnalysisJson({
    required Directory dir,
    required String sourceFileName,
    required String datasetRoot,
    required String runTag,
    required String interp,
  }) async {
    if (_pca == null) return null;

    final names =
        widget.pcaScores.map((m) => m['image_name']?.toString() ?? '').toList();
    final Matrix scores = _pca!['scores'] as Matrix;
    final Matrix pcs = _pca!['pcs'] as Matrix;
    final Vector evals = _pca!['eigenvalues'] as Vector;
    final Vector ev = _pca!['varianceExplained'] as Vector;
    final Vector evr = _pca!['varianceExplainedRatio'] as Vector;

    final outName = '${datasetRoot}__ANL_$runTag.json';
    final outPath = '${dir.path}/$outName';
    final file = File(outPath);

    Map<String, dynamic> map = {
      'meta': {
        'version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'source_file': sourceFileName,
        'dataset_root': datasetRoot,
        'analysis_run': runTag,
        'n': widget.alignedShapes.length,
        'p': widget.alignedShapes.first.rowCount,
        'k': scores.columnCount,
      },
      'specimens': names,
      'interpretation': interp,
      'gpa': {
        'aligned_shapes': widget.alignedShapes.map(_matrixToList).toList(),
        'mean_shape': _matrixToList(_meanOf(widget.alignedShapes)),
      },
      'pca': {
        'scores': _matrixToList(scores),
        'loadings': _matrixToList(pcs),
        'eigenvalues': evals.toList(),
        'variance_explained': ev.toList(),
        'variance_explained_ratio': evr.toList(),
      },
    };

    if (widget.rawShapes != null) {
      map['raw_landmarks'] = widget.rawShapes!.map(_matrixToList).toList();
      map['centroid_sizes'] =
          widget.rawShapes!.map(MorphometricAnalysis.centroidSize).toList();
    }

    await file.writeAsString(jsonEncode(map));
    return outPath;
  }

  String _datasetRootFromSource(String sourceFileName) {
    final lower = sourceFileName.toLowerCase();
    final noExt = lower.endsWith('.csv') || lower.endsWith('.json')
        ? sourceFileName.substring(0, sourceFileName.lastIndexOf('.'))
        : sourceFileName;
    if (noExt.toLowerCase().endsWith('__lm')) {
      return noExt.substring(0, noExt.length - 4);
    }
    final anlMatch =
        RegExp(r'^(.*)__ANL_A\d{2}$', caseSensitive: false).firstMatch(noExt);
    if (anlMatch != null) {
      return anlMatch.group(1)!;
    }
    return noExt;
  }

  String _runTagFromSource(String sourceFileName) {
    final noExt = sourceFileName.contains('.')
        ? sourceFileName.substring(0, sourceFileName.lastIndexOf('.'))
        : sourceFileName;
    final match =
        RegExp(r'__ANL_(A\d{2})$', caseSensitive: false).firstMatch(noExt);
    if (match != null) {
      return match.group(1)!.toUpperCase();
    }
    return 'A01';
  }

  Future<void> _shareExportFiles() async {
    final l = AppLocalizations.of(context)!;
    try {
      final paths = await _exportCsv(showSnack: false);
      if (paths.isEmpty) return;
      final files = paths.map((p) => XFile(p)).toList();
      await Share.shareXFiles(
        files,
        subject: l.analysisShareSubject,
        text: l.analysisShareText,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.analysisShareError('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // ----- Serialización simple de Matrix -> List<List<double>> -----
  List<List<double>> _matrixToList(Matrix m) {
    final out = <List<double>>[];
    for (var r = 0; r < m.rowCount; r++) {
      final row = m.getRow(r);
      out.add(row.toList().map((e) => e.toDouble()).toList());
    }
    return out;
  }
}

// =====================
// Widgets auxiliares
// =====================
class _WireframeCard extends StatelessWidget {
  final Matrix meanShape;
  final Matrix deformed;
  final bool drawMean;
  final bool drawDef;
  final Color defColor;
  final Color meanColor;

  const _WireframeCard({
    required this.meanShape,
    required this.deformed,
    required this.drawMean,
    required this.drawDef,
    required this.defColor,
    required this.meanColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CustomPaint(
        painter: _WireframePainter(
          mean: meanShape,
          def: deformed,
          drawMean: drawMean,
          drawDef: drawDef,
          defColor: defColor,
          meanColor: meanColor,
        ),
      ),
    );
  }
}

class _WireframePainter extends CustomPainter {
  final Matrix mean;
  final Matrix def;
  final bool drawMean;
  final bool drawDef;
  final Color defColor;
  final Color meanColor;

  // Vista fija "correcta": intercambiar X<->Y y voltear Y para Canvas
  static const bool _swapXY = true;
  static const bool _flipY = true;

  _WireframePainter({
    required this.mean,
    required this.def,
    required this.drawMean,
    required this.drawDef,
    required this.defColor,
    required this.meanColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final meanPts = _toOffsets(mean);
    final defPts = _toOffsets(def);
    if (!drawMean && !drawDef) return;

    final used = <Offset>[];
    if (drawMean) used.addAll(meanPts);
    if (drawDef) used.addAll(defPts);
    if (used.isEmpty) return;

    final bounds = _bounds(used);
    final scale = _scale(bounds, size);
    final shift = _shift(bounds, size, scale);

    List<Offset> t(List<Offset> src) => src
        .map((p) => Offset(p.dx * scale + shift.dx, p.dy * scale + shift.dy))
        .toList();

    final tMean = t(meanPts);
    final tDef = t(defPts);

    final paintMean = Paint()
      ..color = meanColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final paintDef = Paint()
      ..color = defColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    if (drawMean) {
      _polyline(canvas, tMean, paintMean);
      final dotMean = Paint()..color = meanColor.withValues(alpha: 0.9);
      for (final p in tMean) {
        canvas.drawCircle(p, 2.2, dotMean);
      }
    }
    if (drawDef) {
      _polyline(canvas, tDef, paintDef);
      final dotDef = Paint()..color = defColor;
      for (final p in tDef) {
        canvas.drawCircle(p, 2.2, dotDef);
      }
    }
  }

  List<Offset> _toOffsets(Matrix m) {
    final out = <Offset>[];
    for (var i = 0; i < m.rowCount; i++) {
      final row = m.getRow(i);
      double x = row[0], y = row[1];
      if (_swapXY) {
        final tmp = x;
        x = y;
        y = tmp;
      }
      if (_flipY) y = -y;
      out.add(Offset(x, y));
    }
    return out;
  }

  Rect _bounds(List<Offset> pts) {
    double minX = pts.first.dx, maxX = pts.first.dx;
    double minY = pts.first.dy, maxY = pts.first.dy;
    for (final p in pts) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    if (maxX - minX < 1e-9) {
      minX -= 0.5;
      maxX += 0.5;
    }
    if (maxY - minY < 1e-9) {
      minY -= 0.5;
      maxY += 0.5;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _scale(Rect bounds, Size size) {
    final w = bounds.width == 0 ? 1.0 : bounds.width;
    final h = bounds.height == 0 ? 1.0 : bounds.height;
    final sx = (size.width - 12) / w;
    final sy = (size.height - 12) / h;
    return math.min(sx, sy);
  }

  Offset _shift(Rect bounds, Size size, double scale) {
    final cx = (bounds.left + bounds.right) / 2;
    final cy = (bounds.top + bounds.bottom) / 2;
    final vx = size.width / 2;
    final vy = size.height / 2;
    return Offset(vx - cx * scale, vy - cy * scale);
  }

  void _polyline(Canvas canvas, List<Offset> pts, Paint p) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.lineTo(pts.first.dx, pts.first.dy); // cerrar
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _WireframePainter old) =>
      old.mean != mean ||
      old.def != def ||
      old.drawMean != drawMean ||
      old.drawDef != drawDef ||
      old.defColor != defColor ||
      old.meanColor != meanColor;
}

class _MiniSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _MiniSwitch(
      {required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: AppSpacing.xs - 2),
        Text(label, style: textStyle, textAlign: TextAlign.center),
      ],
    );
  }
}

class _HcaiNote extends StatelessWidget {
  const _HcaiNote();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return TheiaSectionCard(
      child: Text(
        l.analysisHcdaiNote,
        style: TextStyle(
            fontSize: 13.5, color: scheme.onSurfaceVariant, height: 1.3),
      ),
    );
  }
}

class _PcWireframeData {
  final int index;
  final String title;
  final Matrix minus;
  final Matrix plus;

  const _PcWireframeData({
    required this.index,
    required this.title,
    required this.minus,
    required this.plus,
  });
}
