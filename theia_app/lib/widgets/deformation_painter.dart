// lib/widgets/deformation_painter.dart

import 'package:flutter/material.dart';
import 'package:ml_linalg/linalg.dart';

class DeformationPainter extends CustomPainter {
  final Matrix meanShape; // Forma media (32x2)
  final Vector eigenvector; // Vector de deformación (1x64)
  final double deformationFactor; // Qué tan exagerado (-3 a +3)

  DeformationPainter({
    required this.meanShape,
    required this.eigenvector,
    this.deformationFactor = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Convertir la forma media (Matrix 32x2) a una lista de Offsets
    final List<Offset> meanPoints = _matrixToOffsets(meanShape);

    // 2. Calcular la forma deformada
    // meanShape (32x2) + (eigenvector (64x1) * factor)
    final deformedShape =
        _calculateDeformedShape(meanShape, eigenvector, deformationFactor);
    final List<Offset> deformedPoints = _matrixToOffsets(deformedShape);

    // 3. Encontrar los límites para centrar y escalar el dibujo
    final allPoints = [...meanPoints, ...deformedPoints];
    final bounds = _getBounds(allPoints);
    final scale = _calculateScale(bounds, size);
    final offset = _calculateOffset(bounds, size, scale);

    // 4. Dibujar las formas
    _drawShape(canvas, meanPoints, scale, offset,
        Colors.grey.withValues(alpha: 0.8), 2.0);
    _drawShape(canvas, deformedPoints, scale, offset, Colors.cyan, 3.0);
  }

  /// Convierte una Matriz (32x2) en una Lista de Offsets (puntos x,y)
  List<Offset> _matrixToOffsets(Matrix shape) {
    return shape.rows.map((row) => Offset(row[0], row[1])).toList();
  }

  /// Calcula la forma deformada
  Matrix _calculateDeformedShape(Matrix mean, Vector eigen, double factor) {
    // 1. "Desaplanar" el eigenvector (1x64) a una matriz de deformación (32x2)
    final xDeforms = eigen.subvector(0, 32);
    final yDeforms = eigen.subvector(32, 64);
    final deformMatrix = Matrix.fromColumns([xDeforms, yDeforms]);

    // 2. Aplicar el factor de deformación
    final scaledDeforms = deformMatrix * factor;

    // 3. Sumar la deformación a la forma media
    return mean + scaledDeforms;
  }

  /// Dibuja una forma (lista de puntos) en el canvas
  void _drawShape(Canvas canvas, List<Offset> points, double scale,
      Offset offset, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Mover al primer punto
    final firstPoint = (points[0] * scale) + offset;
    path.moveTo(firstPoint.dx, firstPoint.dy);

    // Dibujar líneas al resto de los puntos
    for (int i = 0; i < points.length; i++) {
      final p = (points[i] * scale) + offset;

      // Dibujar la línea (opcional, pero útil)
      // if (i > 0) {
      //   path.lineTo(p.dx, p.dy);
      // }

      // Dibujar cada punto como un círculo
      canvas.drawCircle(p, strokeWidth, paint);
    }

    // Descomentar si quieres dibujar líneas conectadas
    // canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  // --- Funciones de centrado y escalado ---

  Rect _getBounds(List<Offset> points) {
    final double minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final double minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final double maxX = points.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final double maxY = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _calculateScale(Rect bounds, Size size) {
    final double scaleX = size.width / bounds.width;
    final double scaleY = size.height / bounds.height;
    return (scaleX < scaleY ? scaleX : scaleY) * 0.9; // 90% de zoom
  }

  Offset _calculateOffset(Rect bounds, Size size, double scale) {
    final double dx =
        (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final double dy =
        (size.height - bounds.height * scale) / 2 - bounds.top * scale;
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant DeformationPainter oldDelegate) {
    // Redibuja si el factor de deformación cambia
    return oldDelegate.deformationFactor != deformationFactor;
  }
}
