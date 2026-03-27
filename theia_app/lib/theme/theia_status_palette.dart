import 'package:flutter/material.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/theme/theia_semantic_colors.dart';

class TheiaStatusPalette {
  TheiaStatusPalette._();

  static TheiaSemanticColors? _semantic(ThemeData? theme) {
    return theme?.extension<TheiaSemanticColors>();
  }

  static const double confidenceLowThreshold = 0.85;
  static const double confidenceMidThreshold = 0.92;

  // Mantiene la semántica visual original de confianza solicitada:
  // bajo=rojo, medio=verde, alto=azul.
  static Color confidenceColor(double confidence, {ThemeData? theme}) {
    final semantic = _semantic(theme);
    final conf = confidence.clamp(0.0, 1.0);
    if (conf < confidenceLowThreshold) {
      return semantic?.confidenceLow ?? Colors.red;
    }
    if (conf < confidenceMidThreshold) {
      return semantic?.confidenceMedium ?? Colors.green;
    }
    return semantic?.confidenceHigh ?? Colors.blue;
  }

  static Color? statusColor(
    ImageStatus status,
    ColorScheme scheme, {
    ThemeData? theme,
  }) {
    final semantic = _semantic(theme);
    switch (status) {
      case ImageStatus.approved:
        return semantic?.statusApproved ?? scheme.primary;
      case ImageStatus.rejected:
        return semantic?.statusRejected ?? scheme.error;
      case ImageStatus.edited:
        return semantic?.statusEdited ?? scheme.secondary;
      case ImageStatus.pending:
        return null;
    }
  }

  static Color statusOverlayColor(
    ImageStatus status,
    ColorScheme scheme, {
    double alpha = 0.5,
    ThemeData? theme,
  }) {
    final base = statusColor(status, scheme, theme: theme);
    return base?.withValues(alpha: alpha) ?? Colors.transparent;
  }

  static IconData? statusIcon(ImageStatus status) {
    switch (status) {
      case ImageStatus.approved:
        return Icons.check_circle;
      case ImageStatus.rejected:
        return Icons.cancel;
      case ImageStatus.edited:
        return Icons.edit;
      case ImageStatus.pending:
        return null;
    }
  }

  static Color? statusOnColor(
    ImageStatus status,
    ColorScheme scheme, {
    ThemeData? theme,
  }) {
    final semantic = _semantic(theme);
    switch (status) {
      case ImageStatus.approved:
        return semantic?.onStatusApproved ?? scheme.onPrimary;
      case ImageStatus.rejected:
        return semantic?.onStatusRejected ?? scheme.onError;
      case ImageStatus.edited:
        return semantic?.onStatusEdited ?? scheme.onSecondary;
      case ImageStatus.pending:
        return null;
    }
  }
}
