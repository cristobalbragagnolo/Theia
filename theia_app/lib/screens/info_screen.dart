import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/theme/app_tokens.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static final Uri _sourceUri =
      Uri.parse('https://github.com/cristobalbragagnolo/Theia');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.infoPageTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          _ExpandableSectionCard(
            title: l.infoModelSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pipeline Architecture: Cascaded Dual-Stage Inference',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Stage 1: Nano Detector',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const _MetadataBullet(
                  label: 'Model Name',
                  value: 'YOLOv8-Nano (Object Detection)',
                ),
                const _MetadataBullet(
                  label: 'Architecture',
                  value: 'Convolutional Neural Network (Ultralytics)',
                ),
                const _MetadataBullet(
                  label: 'Precision',
                  value: 'FP32 (Full Precision TFLite)',
                ),
                const _MetadataBullet(
                  label: 'Training Dataset',
                  value: 'Erysimum Morphometric Dataset v1.0 (N=1,190)',
                ),
                const _MetadataBullet(
                  label: 'Methodological Goal',
                  value: 'Calyx Detection & ROI Cropping (Top-down validation)',
                ),
                const _MetadataBullet(
                  label: 'Licence',
                  value: 'MIT Open Source',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Stage 2: Medium Pose',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const _MetadataBullet(
                  label: 'Model Name',
                  value: 'YOLOv8-Medium Pose',
                ),
                const _MetadataBullet(
                  label: 'Architecture',
                  value: 'Convolutional Neural Network (Ultralytics)',
                ),
                const _MetadataBullet(
                  label: 'Precision',
                  value: 'FP32 (Full Precision TFLite)',
                ),
                const _MetadataBullet(
                  label: 'Training Dataset',
                  value: 'Erysimum Morphometric Dataset v1.0 (N=1,190)',
                ),
                const _MetadataBullet(
                  label: 'Methodological Goal',
                  value: 'K=32 Botanical Landmarks (2D Orthogonal)',
                ),
                const _MetadataBullet(
                  label: 'Licence',
                  value: 'MIT Open Source',
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                  onTap: () => _openSource(context),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Text(
                      'https://github.com/cristobalbragagnolo/Theia',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExpandableSectionCard(
            title: l.infoThanksSection,
            child: Text(
              'The deep learning algorithms in this app, much like science in general, are built upon the work of those who came before us. For this reason, I would like to thank Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares, and Andrés Ferreira Rodríguez for their annotation work and incredible support.\n\nThis app was created with love, curiosity, and a lot of hard work. Therefore, I want to express my gratitude to my parents and family for teaching me these values.\n\nI hope this tool proves useful for scientific research and helps those who come after us to discover and invent even better things.\n\nCristobal Bragagnolo',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context) async {
    final ok = await launchUrl(
      _sourceUri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open GitHub repository URL.'),
        ),
      );
    }
  }
}

class _ExpandableSectionCard extends StatelessWidget {
  const _ExpandableSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _MetadataBullet extends StatelessWidget {
  const _MetadataBullet({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '•',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label: ',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
