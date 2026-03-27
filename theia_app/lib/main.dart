// lib/main.dart (CORREGIDO)
// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/screens/batch_mode_screen.dart';
import 'package:theia/screens/data_manager_screen.dart';
import 'package:theia/screens/eco_field_mode_screen.dart';
import 'package:theia/screens/live_mode_screen.dart';
import 'package:theia/screens/splash_screen.dart';
import 'package:theia/screens/info_screen.dart';
import 'package:theia/services/eco_field_platform.dart';
import 'package:theia/theme/app_theme.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/widgets/theia_primary_button.dart';

const String _settingsFileName = 'theia_settings.json';

void main() {
  runApp(const TheiaApp());
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
    required this.currentMode,
    required this.currentLocale,
    required this.ecoFieldEnabled,
    required this.currentUiScale,
    this.onThemeSelected,
    this.onLocaleSelected,
    this.onUiScaleSelected,
    this.onEcoFieldToggle,
  });

  final ThemeMode currentMode;
  final Locale? currentLocale;
  final bool ecoFieldEnabled;
  final double currentUiScale;
  final ValueChanged<ThemeMode>? onThemeSelected;
  final ValueChanged<Locale?>? onLocaleSelected;
  final ValueChanged<double>? onUiScaleSelected;
  final Future<bool> Function(bool enabled)? onEcoFieldToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final drawerBrandStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: 'Serif',
              fontWeight: FontWeight.w800,
            );
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(l.appTitle, style: drawerBrandStyle),
                const SizedBox(height: AppSpacing.xs),
                Text(l.appTagline,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_medium),
            title: Text(l.themeLabel),
            subtitle: Text(_themeModeLabel(l, currentMode)),
            onTap: () => _showThemeSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.languageLabel),
            subtitle: Text(_localeLabel(l, currentLocale)),
            onTap: () => _showLanguageSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: Text(_uiScaleTitle(context)),
            subtitle: Text(_uiScaleSubtitle(context, currentUiScale)),
            onTap: () => _showUiScaleSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.eco),
            title: Text(l.ecoFieldSettingsTitle),
            subtitle: Text(ecoFieldEnabled ? 'ON' : 'OFF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEcoFieldSheet(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.drawerInfo),
            subtitle: Text(l.drawerInfoSubtitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InfoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              value: mode,
              groupValue: currentMode,
              title: Text(_themeModeLabel(l, mode)),
              onChanged: (value) {
                if (value != null) onThemeSelected?.call(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final options = <Locale?>[
      null,
      const Locale('es'),
      const Locale('en'),
      const Locale('pt'),
      const Locale('it'),
      const Locale('fr'),
      const Locale('de'),
      const Locale('el'),
      const Locale('tr'),
      const Locale('ru'),
      const Locale('zh'),
      const Locale('ar'),
    ];
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((loc) {
              final label = switch (loc?.languageCode) {
                'es' => 'Español',
                'en' => 'English',
                'pt' => 'Português',
                'it' => 'Italiano',
                'fr' => 'Français',
                'de' => 'Deutsch',
                'el' => 'Ελληνικά',
                'tr' => 'Türkçe',
                'ru' => 'Русский',
                'zh' => '中文',
                'ar' => 'العربية',
                _ => l.languageSystem,
              };
              return RadioListTile<Locale?>(
                value: loc,
                groupValue: currentLocale,
                title: Text(label),
                onChanged: (value) {
                  onLocaleSelected?.call(value);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showUiScaleSheet(BuildContext context) {
    const minScale = 0.85;
    const maxScale = 1.35;
    var draftScale = currentUiScale.clamp(minScale, maxScale).toDouble();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _uiScaleTitle(context),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _uiScaleSubtitle(context, draftScale),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Slider(
                  value: draftScale,
                  min: minScale,
                  max: maxScale,
                  divisions: 10,
                  label: '${(draftScale * 100).round()}%',
                  onChanged: (value) {
                    setSheetState(() {
                      draftScale = value;
                    });
                  },
                  onChangeEnd: (value) => onUiScaleSelected?.call(value),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setSheetState(() => draftScale = 1.0);
                        onUiScaleSelected?.call(1.0);
                      },
                      child: Text(_uiScaleResetLabel(context)),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(_uiScaleCloseLabel(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEcoFieldSheet(BuildContext parentContext) {
    final l = AppLocalizations.of(parentContext)!;
    showModalBottomSheet(
      context: parentContext,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: true,
              groupValue: ecoFieldEnabled,
              title: const Text('ON'),
              subtitle: Text(l.ecoFieldSettingsSubtitleEnabled),
              onChanged: (value) async {
                if (value == null) return;
                Navigator.pop(sheetContext);
                final handler = onEcoFieldToggle;
                if (handler == null) return;
                final locationGranted = await handler(value);
                if (!parentContext.mounted) return;
                if (value && !locationGranted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(
                      content: Text(l.ecoFieldLocationDeniedNotice),
                      backgroundColor:
                          Theme.of(parentContext).colorScheme.tertiary,
                    ),
                  );
                }
              },
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: ecoFieldEnabled,
              title: const Text('OFF'),
              subtitle: Text(l.ecoFieldSettingsSubtitleDisabled),
              onChanged: (value) async {
                if (value == null) return;
                Navigator.pop(sheetContext);
                final handler = onEcoFieldToggle;
                if (handler == null) return;
                await handler(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(AppLocalizations l, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l.themeSystem;
      case ThemeMode.light:
        return l.themeLight;
      case ThemeMode.dark:
        return l.themeDark;
    }
  }

  String _localeLabel(AppLocalizations l, Locale? locale) {
    switch (locale?.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'el':
        return 'Ελληνικά';
      case 'tr':
        return 'Türkçe';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      default:
        return l.languageSystem;
    }
  }

  String _uiScaleTitle(BuildContext context) {
    return AppLocalizations.of(context)!.uiScaleTitle;
  }

  String _uiScaleSubtitle(BuildContext context, double scale) {
    final l = AppLocalizations.of(context)!;
    return l.uiScaleSubtitle((scale * 100).round(), l.uiScaleHint);
  }

  String _uiScaleResetLabel(BuildContext context) {
    return AppLocalizations.of(context)!.uiScaleReset;
  }

  String _uiScaleCloseLabel(BuildContext context) {
    return AppLocalizations.of(context)!.uiScaleClose;
  }
}

class TheiaApp extends StatefulWidget {
  const TheiaApp({super.key});

  static _TheiaAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_TheiaAppState>();

  @override
  State<TheiaApp> createState() => _TheiaAppState();
}

class _TheiaAppState extends State<TheiaApp> {
  static const double _minUiScalePreference = 0.85;
  static const double _maxUiScalePreference = 1.35;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _ecoFieldEnabled = false;
  double _uiScale = 1.0;
  final ValueNotifier<bool> _ecoFieldEnabledNotifier = ValueNotifier<bool>(
    false,
  );

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get ecoFieldEnabled => _ecoFieldEnabled;
  double get uiScale => _uiScale;
  ValueNotifier<bool> get ecoFieldEnabledListenable => _ecoFieldEnabledNotifier;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void updateThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    setState(() {
      _themeMode = mode;
    });
  }

  void updateLocale(Locale? locale) {
    if (_locale == locale) return;
    setState(() {
      _locale = locale;
    });
  }

  Future<bool> updateEcoFieldMode(bool enabled) async {
    if (_ecoFieldEnabled != enabled) {
      setState(() {
        _ecoFieldEnabled = enabled;
      });
      _ecoFieldEnabledNotifier.value = enabled;
      await _persistSettings();
    }

    bool locationGranted = true;
    if (enabled && Platform.isAndroid) {
      try {
        locationGranted = await EcoFieldPlatform.requestLocationPermission();
      } catch (_) {
        locationGranted = false;
      }
    }
    return locationGranted;
  }

  void updateUiScale(double scale) {
    final clamped =
        scale.clamp(_minUiScalePreference, _maxUiScalePreference).toDouble();
    if ((_uiScale - clamped).abs() < 0.001) return;
    setState(() {
      _uiScale = clamped;
    });
    _persistSettings();
  }

  double _responsiveScaleForWidth(double width) {
    if (width < 360) return 0.94;
    if (width < 420) return 1.0;
    if (width < 520) return 1.06;
    return 1.12;
  }

  double _effectiveTextScale(MediaQueryData mediaQuery) {
    final systemScale = mediaQuery.textScaler.scale(1);
    final responsiveScale = _responsiveScaleForWidth(mediaQuery.size.width);
    final effective = systemScale * _uiScale * responsiveScale;
    return effective.clamp(0.8, 2.0).toDouble();
  }

  Future<File> _settingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_settingsFileName');
  }

  Future<void> _loadSettings() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return;
      final ecoEnabled = map['ecoFieldEnabled'] == true;
      final savedUiScale = (map['uiScale'] as num?)?.toDouble();
      if (!mounted) return;
      setState(() {
        _ecoFieldEnabled = ecoEnabled;
        _uiScale = (savedUiScale ?? 1.0)
            .clamp(_minUiScalePreference, _maxUiScalePreference)
            .toDouble();
      });
      _ecoFieldEnabledNotifier.value = ecoEnabled;
    } catch (_) {}
  }

  Future<void> _persistSettings() async {
    try {
      final file = await _settingsFile();
      final payload = jsonEncode({
        'ecoFieldEnabled': _ecoFieldEnabled,
        'uiScale': _uiScale,
      });
      await file.writeAsString(payload, flush: true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ecoFieldEnabledNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Theia',
      locale: _locale,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final effectiveScale = _effectiveTextScale(mediaQuery);
        return MediaQuery(
          data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(effectiveScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = TheiaApp.of(context);
    final currentMode = themeController?.themeMode ?? ThemeMode.system;
    final currentLocale = themeController?.locale;
    final currentUiScale = themeController?.uiScale ?? 1.0;
    final l = AppLocalizations.of(context)!;
    final appBarTitleStyle = Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge;
    final brandStyle = appBarTitleStyle?.copyWith(
      fontFamily: 'Serif',
      fontWeight: FontWeight.w800,
    );
    final scheme = Theme.of(context).colorScheme;
    final ecoFieldListenable = themeController?.ecoFieldEnabledListenable;

    Widget buildScaffold(bool ecoFieldEnabled) {
      return Scaffold(
        drawer: SettingsDrawer(
          currentMode: currentMode,
          currentLocale: currentLocale,
          ecoFieldEnabled: ecoFieldEnabled,
          currentUiScale: currentUiScale,
          onThemeSelected: themeController?.updateThemeMode,
          onLocaleSelected: themeController?.updateLocale,
          onUiScaleSelected: themeController?.updateUiScale,
          onEcoFieldToggle: themeController?.updateEcoFieldMode,
        ),
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l.appTitle, style: brandStyle),
                  TextSpan(
                      text: ' - ${l.appTaglineShort}', style: appBarTitleStyle),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TheiaPrimaryButton(
                  icon: Icons.camera_alt,
                  label: l.homeLiveButton,
                  minHeight: AppSizes.buttonHeight,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LiveModeScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TheiaPrimaryButton(
                  icon: Icons.photo_library,
                  label: l.homeBatchButton,
                  minHeight: AppSizes.buttonHeight,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BatchModeScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TheiaPrimaryButton(
                  icon: Icons.storage,
                  label: l.homeDataManagerButton,
                  minHeight: AppSizes.buttonHeight,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataManagerScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                TheiaPrimaryButton(
                  icon: ecoFieldEnabled ? Icons.eco : Icons.lock,
                  label: l.homeEcoFieldButton,
                  minHeight: AppSizes.buttonHeight,
                  backgroundColor: ecoFieldEnabled
                      ? scheme.tertiaryContainer
                      : scheme.surfaceContainerHighest,
                  foregroundColor: ecoFieldEnabled
                      ? scheme.onTertiaryContainer
                      : scheme.onSurfaceVariant,
                  onPressed: () {
                    if (!ecoFieldEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.homeEcoFieldLockedMessage)),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EcoFieldModeScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (ecoFieldListenable == null) {
      return buildScaffold(false);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: ecoFieldListenable,
      builder: (context, ecoFieldEnabled, _) => buildScaffold(ecoFieldEnabled),
    );
  }
}
