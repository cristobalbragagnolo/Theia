import 'package:flutter/material.dart';
import 'package:theia/theme/app_tokens.dart';
import 'package:theia/theme/theia_semantic_colors.dart';

class AppTheme {
  static const Color botanicalGreen = Color(0xFF2E7D32);
  static const Color aiTeal = Color(0xFF00BFA5);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final seedScheme = ColorScheme.fromSeed(
      seedColor: botanicalGreen,
      brightness: brightness,
    );
    final tertiarySeedScheme = ColorScheme.fromSeed(
      seedColor: aiTeal,
      brightness: brightness,
    );

    final scheme = seedScheme.copyWith(
      tertiary: aiTeal,
      onTertiary: tertiarySeedScheme.onTertiary,
      tertiaryContainer: tertiarySeedScheme.tertiaryContainer,
      onTertiaryContainer: tertiarySeedScheme.onTertiaryContainer,
    );

    final baseTheme = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: brightness,
    );
    final textTheme = baseTheme.textTheme.copyWith(
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
        height: 1.35,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        height: 1.35,
      ),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );

    return baseTheme.copyWith(
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        TheiaSemanticColors.fromScheme(scheme),
      ],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 72,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
    );
  }
}
