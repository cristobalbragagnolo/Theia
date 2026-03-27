import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';

class TheiaInputDecoration {
  TheiaInputDecoration._();

  static const EdgeInsets _contentPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  static OutlineInputBorder get _outlineBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
      );

  static InputDecoration outlined({
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding = _contentPadding,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: _outlineBorder,
      enabledBorder: _outlineBorder,
      focusedBorder: _outlineBorder,
      contentPadding: contentPadding,
    );
  }
}
