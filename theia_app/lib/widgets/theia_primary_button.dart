import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';

class TheiaPrimaryButton extends StatelessWidget {
  const TheiaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.minHeight = AppSizes.buttonHeight,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final double minHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final uiScale = AppAdaptive.uiScale(context);
    final scaledMinHeight = (minHeight * uiScale).clamp(44.0, 120.0);
    final style = ElevatedButton.styleFrom(
      minimumSize: Size.fromHeight(scaledMinHeight),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconSize: (20 * uiScale).clamp(18.0, 34.0),
    );

    final button = icon == null
        ? ElevatedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon),
            label: Text(label),
          );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
