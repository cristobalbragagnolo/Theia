import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';

class TheiaSectionCard extends StatelessWidget {
  const TheiaSectionCard({
    super.key,
    required this.child,
    this.title,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = title == null
        ? child
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title!, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          );

    return Card(
      margin: margin,
      child: Padding(
        padding: padding,
        child: content,
      ),
    );
  }
}
