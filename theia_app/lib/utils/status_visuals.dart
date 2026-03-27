import 'package:flutter/material.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/theme/theia_status_palette.dart';

Color? statusColor(
  ImageStatus status,
  ColorScheme scheme, {
  ThemeData? theme,
}) {
  return TheiaStatusPalette.statusColor(status, scheme, theme: theme);
}

String? statusLabel(BuildContext? context, ImageStatus status) {
  final l = context != null ? AppLocalizations.of(context) : null;
  switch (status) {
    case ImageStatus.approved:
      return l?.statusApproved ?? 'Approved';
    case ImageStatus.rejected:
      return l?.statusRejected ?? 'Rejected';
    case ImageStatus.edited:
      return l?.statusEdited ?? 'Edited';
    case ImageStatus.pending:
      return null;
  }
}
