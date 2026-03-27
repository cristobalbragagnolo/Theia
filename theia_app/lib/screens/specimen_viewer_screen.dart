// lib/screens/specimen_viewer_screen.dart
//
// Tres gráficos en columna: Media, Especímen, Superpuestos.
// Orientación correcta: SOLO invertimos Y para Canvas (sin swap X↔Y).
// Media al 50% si hay superposición.
// Puntos grandes + línea fina conectando.
// Escala y centrado compartidos.
// FIX: el canvas ahora ocupa todo el ancho (width: double.infinity).

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:theia/theme/app_tokens.dart';

class SpecimenViewerScreen extends StatelessWidget {
  final Matrix meanShape; // (p x 2)
  final Matrix specimenShape; // (p x 2)
  final String specimenName;

  const SpecimenViewerScreen({
    super.key,
    required this.meanShape,
    required this.specimenShape,
    required this.specimenName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cardColor = scheme.surfaceContainerLow;
    final borderColor = scheme.outline.withValues(alpha: 0.4);
    final meanColor = scheme.onSurface;
    final specimenColor = scheme.tertiary;

    Widget card(String title, Widget painter) => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md - 2,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm - 2),
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 240,
                  width: double.infinity, // <<<<<< CLAVE
                  child: painter,
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(specimenName)),
      body: ListView(
        children: [
          // Media
          card(
            'Media',
            CustomPaint(
              painter: _ShapePainter(
                mean: meanShape,
                specimen: null,
                showMean: true,
                showSpecimen: false,
                meanColor: meanColor,
                specimenColor: specimenColor,
              ),
            ),
          ),
          // Especímen
          card(
            'Espécimen',
            CustomPaint(
              painter: _ShapePainter(
                mean: meanShape,
                specimen: specimenShape,
                showMean: false,
                showSpecimen: true,
                meanColor: meanColor,
                specimenColor: specimenColor,
              ),
            ),
          ),
          // Superpuestos
          card(
            'Superpuestos',
            CustomPaint(
              painter: _ShapePainter(
                mean: meanShape,
                specimen: specimenShape,
                showMean: true,
                showSpecimen: true,
                meanColor: meanColor,
                specimenColor: specimenColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md + 2),
        ],
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Matrix mean;
  final Matrix? specimen;
  final bool showMean;
  final bool showSpecimen;
  final Color meanColor;
  final Color specimenColor;
  static const bool _swapXY = true;
  static const bool _flipY = true;

  _ShapePainter({
    required this.mean,
    required this.specimen,
    required this.showMean,
    required this.showSpecimen,
    required this.meanColor,
    required this.specimenColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Puntos con misma convención que analysis_result_screen:
    //    X igual, Y invertida para Canvas. ¡No hacer swap X↔Y!
    final ptsMean = _toOffsets(mean);
    final ptsSpec = specimen != null ? _toOffsets(specimen!) : <Offset>[];

    // 2) Bounds conjuntos para una escala idéntica
    final used = <Offset>[...ptsMean, ...ptsSpec];
    if (used.isEmpty) return;

    final bounds = _bounds(used);
    final scale = _scale(bounds, size);
    final shift = _shift(bounds, size, scale);

    List<Offset> t(List<Offset> src) => src
        .map((p) => Offset(p.dx * scale + shift.dx, p.dy * scale + shift.dy))
        .toList();

    final meanT = t(ptsMean);
    final specT = t(ptsSpec);

    // Estilos: línea fina + puntos grandes
    final meanStroke = Paint()
      ..color = meanColor.withValues(
          alpha: showSpecimen ? 0.50 : 0.95) // 50% si hay superposición
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final meanDot = Paint()
      ..color = meanColor.withValues(alpha: showSpecimen ? 0.50 : 0.95);

    final specStroke = Paint()
      ..color = specimenColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final specDot = Paint()..color = specimenColor;

    if (showMean) {
      _polyline(canvas, meanT, meanStroke);
      for (final p in meanT) {
        canvas.drawCircle(p, 4.0, meanDot);
      }
    }
    if (showSpecimen && specT.isNotEmpty) {
      _polyline(canvas, specT, specStroke);
      for (final p in specT) {
        canvas.drawCircle(p, 4.6, specDot);
      }
    }
  }

  // Misma orientación que en _WireframePainter: (x, -y)
  List<Offset> _toOffsets(Matrix m) {
    final out = <Offset>[];
    for (var i = 0; i < m.rowCount; i++) {
      final row = m.getRow(i);
      final xRaw = _swapXY ? row[1] : row[0];
      final yRaw = _swapXY ? row[0] : row[1];
      final y = _flipY ? -yRaw : yRaw;
      out.add(Offset(xRaw, y));
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
    // Evita degenerar si rango ~0
    if ((maxX - minX).abs() < 1e-9) {
      minX -= 0.5;
      maxX += 0.5;
    }
    if ((maxY - minY).abs() < 1e-9) {
      minY -= 0.5;
      maxY += 0.5;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _scale(Rect b, Size s) {
    final w = (b.width == 0) ? 1.0 : b.width;
    final h = (b.height == 0) ? 1.0 : b.height;
    final sx = (s.width - 16) / w;
    final sy = (s.height - 16) / h;
    return (sx < sy ? sx : sy) * 0.94; // margen leve
  }

  Offset _shift(Rect b, Size s, double scale) {
    final cx = (b.left + b.right) / 2;
    final cy = (b.top + b.bottom) / 2;
    final vx = s.width / 2;
    final vy = s.height / 2;
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
  bool shouldRepaint(covariant _ShapePainter old) =>
      old.mean != mean ||
      old.specimen != specimen ||
      old.showMean != showMean ||
      old.showSpecimen != showSpecimen ||
      old.meanColor != meanColor ||
      old.specimenColor != specimenColor;
}
