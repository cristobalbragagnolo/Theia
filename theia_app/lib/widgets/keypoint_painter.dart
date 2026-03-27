import 'dart:ui' as ui;
import 'package:flutter/material.dart'; // <--- IMPORTACIÓN CLAVE QUE FALTABA
import 'package:theia/theme/theia_status_palette.dart';

class KeypointPainter extends CustomPainter {
  final ui.Image image;
  final List<List<double>>? keypoints;
  final int? selectedKeypointIndex;
  final List<double>? confidences;
  final List<Color> colors;
  final List<double>? box;
  final Color? boxColor;
  final String? boxLabel;
  final ThemeData? semanticTheme;

  KeypointPainter({
    required this.image,
    this.keypoints,
    this.selectedKeypointIndex,
    this.confidences,
    this.box,
    this.boxColor,
    this.boxLabel,
    this.semanticTheme,
  }) : colors = List.generate(
            32,
            (index) =>
                HSLColor.fromAHSL(1.0, (index * 360 / 32) % 360, 1.0, 0.5)
                    .toColor());

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.width, size.height),
        image: image);

    if (box != null && box!.length == 4) {
      final normalizedLeft = box![0].clamp(0.0, 1.0);
      final normalizedTop = box![1].clamp(0.0, 1.0);
      final normalizedRight = box![2].clamp(0.0, 1.0);
      final normalizedBottom = box![3].clamp(0.0, 1.0);

      final rect = Rect.fromLTRB(
        normalizedLeft * size.width,
        normalizedTop * size.height,
        normalizedRight * size.width,
        normalizedBottom * size.height,
      );

      final paintBox = Paint()
        ..color = boxColor ?? Colors.white
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawRect(rect, paintBox);

      if (boxLabel != null && boxLabel!.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: boxLabel,
            style: TextStyle(
              color: _labelTextColor(boxColor),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        const double labelPaddingH = 8;
        const double labelPaddingV = 4;
        final double backgroundWidth = textPainter.width + labelPaddingH * 2;
        final double backgroundHeight = textPainter.height + labelPaddingV * 2;

        final double bgLeft = (rect.left + 8).clamp(
          0.0,
          size.width - backgroundWidth,
        );
        final double bgTop = (rect.top + 8).clamp(
          0.0,
          size.height - backgroundHeight,
        );

        final RRect backgroundRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(bgLeft, bgTop, backgroundWidth, backgroundHeight),
          const Radius.circular(8),
        );

        final Paint backgroundPaint = Paint()
          ..color = (boxColor ?? Colors.white).withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(backgroundRect, backgroundPaint);

        textPainter.paint(
          canvas,
          Offset(bgLeft + labelPaddingH, bgTop + labelPaddingV),
        );
      }
    }

    if (keypoints == null) return;

    for (int i = 0; i < keypoints!.length; i++) {
      final kpt = keypoints![i];
      final paintKeypoint = Paint()..color = _colorForIndexOrConfidence(i);
      final offset = Offset(kpt[0] * size.width, kpt[1] * size.height);

      if (i == selectedKeypointIndex) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(offset, 12, paintKeypoint);
        canvas.drawCircle(offset, 12, borderPaint);
      } else {
        canvas.drawCircle(offset, 8, paintKeypoint);
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: (i + 1).toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: paintKeypoint.color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx + 8, offset.dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _labelTextColor(Color? background) {
    if (background == null) return Colors.black;
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color _colorForIndexOrConfidence(int index) {
    if (confidences != null && index < confidences!.length) {
      return TheiaStatusPalette.confidenceColor(
        confidences![index],
        theme: semanticTheme,
      );
    }
    return colors[index % colors.length];
  }
}
