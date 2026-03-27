import 'dart:async';
import 'package:flutter/material.dart';
import 'package:theia/l10n/app_localizations.dart';
import 'package:theia/main.dart'; // Importamos HomePage desde main.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navega a la página principal después de 3 segundos
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Text(
          l.splashTitle,
          style: TextStyle(
            fontFamily: 'Serif', // Una fuente con más personalidad
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
