    import 'dart:async';
    import 'package:flutter/material.dart';
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        });
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.green.shade700, // Un verde oscuro y elegante
          body: const Center(
            child: Text(
              'Theia',
              style: TextStyle(
                fontFamily: 'Serif', // Una fuente con más personalidad
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
        );
      }
    }