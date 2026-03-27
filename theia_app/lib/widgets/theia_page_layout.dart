import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';

class TheiaPagePadding extends StatelessWidget {
  const TheiaPagePadding({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class TheiaPageSection extends StatelessWidget {
  const TheiaPageSection({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      0,
    ),
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = title == null
        ? child
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          );

    return Padding(
      padding: padding,
      child: content,
    );
  }
}
