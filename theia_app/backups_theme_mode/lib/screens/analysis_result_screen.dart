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
import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart' hide Axis;
import 'package:path_provider/path_provider.dart';

import '../analysis/morph_analysis.dart';
import 'morphospace_screen.dart';

class AnalysisResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pcaScores; // nombres/PC previos (para XY y tabla)
  final List<Matrix> alignedShapes;           // GPA result (p x 2) por espécimen
  final Matrix meanShape;                     // legado (no imprescindible)
  final Vector pc1Eigenvector;                // legado
  final Vector pc2Eigenvector;                // legado
  final String selectedFileName;              // nombre del CSV fuente
  final Map<String, String> plotUrls;         // sin uso
  final String serverUrl;                     // sin uso

  const AnalysisResultScreen({
    super.key,
    required this.pcaScores,
    required this.alignedShapes,
    required this.meanShape,
    required this.pc1Eigenvector,
    required this.pc2Eigenvector,
    required this.selectedFileName,
    required this.plotUrls,
    required this.serverUrl,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  Map<String, dynamic>? _pca; // scores, pcs, eigenvalues, varianceExplainedRatio
  final _interpCtrl = TextEditingController();

  // Toggles de signo para deformaciones ±2DE
  bool _invertPC1 = false;
  bool _invertPC2 = false;
  bool _invertPC3 = false;

  // Navegación interna
  final _scrollCtl = ScrollController();
  final _wireframesKey = GlobalKey();
  final _tableKey = GlobalKey();
  final _interpretKey = GlobalKey();

  // Estilo
  static const double _wfPanelHeight = 130;

  @override
  void initState() {
    super.initState();
    // Recalcula PCA localmente para no depender de claves “legacy”
    try {
      _pca = MorphometricAnalysis.runPCA(widget.alignedShapes, k: 3);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular PCA: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pca == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // === Extrae objetos del PCA (consistentes con morph_analysis.dart)
    final Matrix scores = _pca!['scores'] as Matrix;                         // (N x 3)
    final Matrix pcs    = _pca!['pcs'] as Matrix;                            // (2p x 3)
    final Vector evals  = _pca!['eigenvalues'] as Vector;                    // (3)
    final List<double> explainedPct =
        (_pca!['varianceExplainedRatio'] as Vector).toList().map((v) => v * 100.0).toList();

    // Cargas por columna (Vector 2p). Las deformaciones se arman con ±2*sqrt(lambda)
    Vector l1 = pcs.getColumn(0);
    Vector l2 = pcs.getColumn(1);
    Vector l3 = pcs.getColumn(2);
    if (_invertPC1) l1 = l1 * -1.0;
    if (_invertPC2) l2 = l2 * -1.0;
    if (_invertPC3) l3 = l3 * -1.0;

    // t = 2*DE = 2*sqrt(lambda)
    final double t1 = 2.0 * math.sqrt(evals[0]);
    final double t2 = 2.0 * (evals.length > 1 ? math.sqrt(evals[1]) : 0.0);
    final double t3 = 2.0 * (evals.length > 2 ? math.sqrt(evals[2]) : 0.0);

    // Forma media desde alignedShapes (coherente con los wireframes)
    final Matrix meanShape = _meanOf(widget.alignedShapes);

    // Deformaciones (sólo para dibujar)
    final Matrix pc1minus = _deform(meanShape, l1, -t1);
    final Matrix pc1plus  = _deform(meanShape, l1,  t1);
    final Matrix pc2minus = _deform(meanShape, l2, -t2);
    final Matrix pc2plus  = _deform(meanShape, l2,  t2);
    final Matrix pc3minus = _deform(meanShape, l3, -t3);
    final Matrix pc3plus  = _deform(meanShape, l3,  t3);

    final imageNames = widget.pcaScores.map((m) => m['image_name']?.toString() ?? '').toList();

    final Color defColor = Theme.of(context).colorScheme.secondary;
    final Color meanColor = Colors.white.withOpacity(0.9);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados del Análisis')),
      bottomNavigationBar: BottomAppBar(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              _NavBtn(icon: Icons.show_chart, label: 'WF', onTap: () => _jumpTo(_wireframesKey)),
              _NavBtn(icon: Icons.table_chart, label: 'Tabla', onTap: () => _jumpTo(_tableKey)),
              _NavBtn(
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
              _NavBtn(icon: Icons.save_alt, label: 'Guardar', onTap: () => _jumpTo(_interpretKey)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: _sectionTitle('Wireframes de deformación (±2DE alrededor de la media)', key: _wireframesKey),
            ),

            _wireframeRow(
              context: context,
              title: 'PC1 (${explainedPct[0].toStringAsFixed(1)}%)',
              mean: meanShape, minus: pc1minus, plus: pc1plus,
              defColor: defColor, meanColor: meanColor,
            ),
            _wireframeRow(
              context: context,
              title: 'PC2 (${explainedPct[1].toStringAsFixed(1)}%)',
              mean: meanShape, minus: pc2minus, plus: pc2plus,
              defColor: defColor, meanColor: meanColor,
            ),
            _wireframeRow(
              context: context,
              title: 'PC3 (${explainedPct[2].toStringAsFixed(1)}%)',
              mean: meanShape, minus: pc3minus, plus: pc3plus,
              defColor: defColor, meanColor: meanColor,
            ),

            // Toggles de signo (afectan ±)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  _MiniSwitch(label: 'PC1', value: _invertPC1, onChanged: (v) => setState(() => _invertPC1 = v)),
                  const SizedBox(width: 8),
                  _MiniSwitch(label: 'PC2', value: _invertPC2, onChanged: (v) => setState(() => _invertPC2 = v)),
                  const SizedBox(width: 8),
                  _MiniSwitch(label: 'PC3', value: _invertPC3, onChanged: (v) => setState(() => _invertPC3 = v)),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // ===== Tabla de scores (ancho completo) =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _sectionTitle('Tabla de Scores', key: _tableKey),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: _buildScoresTable(imageNames, scores, explainedPct),
            ),
            const SizedBox(height: 16),

            // ===== Interpretación / Guardado =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _sectionTitle('Interpretación y guardado', key: _interpretKey),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: TextField(
                controller: _interpCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ej.: PC1: apertura corolar; PC2: curvatura; PC3: variación basal...',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Guardar con interpretación'),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: _HcaiNote(),
            ),
            const SizedBox(height: 12),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildScoresTable(List<String> names, Matrix scores, List<double> explainedPct) {
    final hdrTop = Theme.of(context).textTheme.titleSmall;
    final hdrPct = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
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
    final minW = MediaQuery.of(context).size.width - 24; // padding lateral 12+12

    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minW),
          child: DataTable(
            horizontalMargin: 6,
            columnSpacing: 18,
            headingRowHeight: 54,
            dataRowMinHeight: 48,
            columns: [
              DataColumn(label: twoLineHeader('Imagen', '')),
              DataColumn(label: twoLineHeader('PC1', '${explainedPct[0].toStringAsFixed(1)}%')),
              DataColumn(label: twoLineHeader('PC2', '${explainedPct[1].toStringAsFixed(1)}%')),
              DataColumn(label: twoLineHeader('PC3', '${explainedPct[2].toStringAsFixed(1)}%')),
            ],
            rows: List<DataRow>.generate(names.length, (i) {
              final Vector row = i < scores.rowCount ? scores.getRow(i) : Vector.fromList([0, 0, 0]);
              return DataRow(cells: [
                DataCell(Text(names[i], style: cellStyle)),
                DataCell(Text(row[0].toStringAsFixed(4), style: cellStyle)),
                DataCell(Text(row[1].toStringAsFixed(4), style: cellStyle)),
                DataCell(Text(row[2].toStringAsFixed(4), style: cellStyle)),
              ]);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: _wfPanelHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _WireframeCard(meanShape: mean, deformed: minus, drawMean: false, drawDef: true, defColor: defColor, meanColor: meanColor)),
              Expanded(child: _WireframeCard(meanShape: mean, deformed: mean,  drawMean: true,  drawDef: false, defColor: defColor, meanColor: meanColor)),
              Expanded(child: _WireframeCard(meanShape: mean, deformed: plus,  drawMean: false, drawDef: true, defColor: defColor, meanColor: meanColor)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(child: Center(child: Text('−2DE'))),
              Expanded(child: Center(child: Text('Media'))),
              Expanded(child: Center(child: Text('+2DE'))),
            ],
          ),
        ),
      ],
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
      out.add(row[0]); out.add(row[1]);
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
  Future<void> _exportCsv() async {
    final dir = await getApplicationDocumentsDirectory();

    // El nombre que llega ya es base (desde DataManager), asegura .csv
    final baseName = widget.selectedFileName.toLowerCase().endsWith('.csv')
        ? widget.selectedFileName
        : '${widget.selectedFileName}.csv';

    // Primer intento
    String outName = 'ANALISIS_$baseName';
    String outPath = '${dir.path}/$outName';
    var file = File(outPath);

    // Si existe, usa ANALISIS_2_, ANALISIS_3_, ...
    int k = 2;
    while (await file.exists()) {
      outName = 'ANALISIS_${k}_$baseName';
      outPath = '${dir.path}/$outName';
      file = File(outPath);
      k++;
    }

    final Matrix scores = _pca!['scores'] as Matrix;
    final List<double> explainedPct =
        (_pca!['varianceExplainedRatio'] as Vector).toList().map((v) => v * 100.0).toList();
    final interp = _interpCtrl.text.trim().isEmpty ? 'Sin interpretación' : _interpCtrl.text.trim();
    final names = widget.pcaScores.map((m) => m['image_name']?.toString() ?? '').toList();

    final rows = <List<dynamic>>[];
    rows.add([
      'Imagen',
      'PC1 (${explainedPct[0].toStringAsFixed(1)}%)',
      'PC2 (${explainedPct[1].toStringAsFixed(1)}%)',
      'PC3 (${explainedPct[2].toStringAsFixed(1)}%)',
      'Interpretación'
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

    final csv = rows.map((r) => r.map((c) => c.toString()).join(',')).join('\n');
    await file.writeAsString(csv);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportado: $outName')));
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
  static const bool _flipY  = true;

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
    final defPts  = _toOffsets(def);
    if (!drawMean && !drawDef) return;

    final used = <Offset>[];
    if (drawMean) used.addAll(meanPts);
    if (drawDef)  used.addAll(defPts);
    if (used.isEmpty) return;

    final bounds = _bounds(used);
    final scale = _scale(bounds, size);
    final shift = _shift(bounds, size, scale);

    List<Offset> t(List<Offset> src) =>
        src.map((p) => Offset(p.dx * scale + shift.dx, p.dy * scale + shift.dy)).toList();

    final tMean = t(meanPts);
    final tDef  = t(defPts);

    final paintMean = Paint()
      ..color = meanColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    final paintDef = Paint()
      ..color = defColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    if (drawMean) {
      _polyline(canvas, tMean, paintMean);
      final dotMean = Paint()..color = meanColor.withOpacity(0.9);
      for (final p in tMean) {
        canvas.drawCircle(p, 2.6, dotMean);
      }
    }
    if (drawDef) {
      _polyline(canvas, tDef, paintDef);
      final dotDef  = Paint()..color = defColor;
      for (final p in tDef) {
        canvas.drawCircle(p, 2.6, dotDef);
      }
    }
  }

  List<Offset> _toOffsets(Matrix m) {
    final out = <Offset>[];
    for (var i = 0; i < m.rowCount; i++) {
      final row = m.getRow(i);
      double x = row[0], y = row[1];
      if (_swapXY) {
        final tmp = x; x = y; y = tmp;
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
    if (maxX - minX < 1e-9) { minX -= 0.5; maxX += 0.5; }
    if (maxY - minY < 1e-9) { minY -= 0.5; maxY += 0.5; }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _scale(Rect bounds, Size size) {
    final w = bounds.width == 0 ? 1.0 : bounds.width;
    final h = bounds.height == 0 ? 1.0 : bounds.height;
    final sx = (size.width  - 12) / w;
    final sy = (size.height - 12) / h;
    return math.min(sx, sy);
  }

  Offset _shift(Rect bounds, Size size, double scale) {
    final cx = (bounds.left + bounds.right) / 2;
    final cy = (bounds.top  + bounds.bottom) / 2;
    final vx = size.width  / 2;
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
  const _MiniSwitch({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(value: value, onChanged: onChanged, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        Text(label),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.secondary;
    return Expanded(
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: c,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _HcaiNote extends StatelessWidget {
  const _HcaiNote();
  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 0,
      color: Color(0xFFF5F5F5),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text(
          '🧠 Nota HCDAI:\n'
          'Los wireframes muestran deformaciones hipotéticas ±2DE sobre la forma media.\n'
          'Interprétalas biológicamente (apertura, curvatura, simetría) comparando con especímenes reales.',
          style: TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.3),
        ),
      ),
    );
  }
}