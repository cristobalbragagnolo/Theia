import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';

class TheiaOutlinedButton extends StatelessWidget {
  const TheiaOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.minHeight = AppSizes.compactButtonHeight,
    this.foregroundColor,
    this.sideColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final double minHeight;
  final Color? foregroundColor;
  final Color? sideColor;

  @override
  Widget build(BuildContext context) {
    final uiScale = AppAdaptive.uiScale(context);
    final scaledMinHeight = (minHeight * uiScale).clamp(40.0, 108.0);
    final style = OutlinedButton.styleFrom(
      minimumSize: Size.fromHeight(scaledMinHeight),
      foregroundColor: foregroundColor,
      side: sideColor == null ? null : BorderSide(color: sideColor!),
      iconSize: (20 * uiScale).clamp(18.0, 32.0),
    );

    final button = icon == null
        ? OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon),
            label: Text(label),
          );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
