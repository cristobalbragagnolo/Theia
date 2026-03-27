import 'package:flutter/material.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/widgets/theia_page_layout.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.infoPageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TheiaPageSection(
            padding: EdgeInsets.zero,
            title: l.infoModelSection,
            child: Text(
              l.infoPlaceholder,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TheiaPageSection(
            padding: EdgeInsets.zero,
            title: l.infoThanksSection,
            child: Text(
              l.infoAcknowledgementsBody,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
