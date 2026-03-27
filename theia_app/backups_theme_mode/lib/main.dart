// lib/main.dart (CORREGIDO) //CORREGIR EL FILTRO ESTRUCTURAL EN PUNTO 17

import 'package:flutter/material.dart';
import 'package:theia/screens/batch_mode_screen.dart';
import 'package:theia/screens/data_manager_screen.dart';
import 'package:theia/screens/live_mode_screen.dart';
import 'package:theia/screens/splash_screen.dart';

void main() {
  runApp(const TheiaApp());
}

class TheiaApp extends StatelessWidget {
  const TheiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theia - Asistente de Morfometría'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Modo Live (Cámara)'),
              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 18), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveModeScreen())),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Modo Batch (Galería)'),
               style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 18), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BatchModeScreen())),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.storage),
              label: const Text('Gestor de Datos y Análisis'),
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Theme.of(context).colorScheme.onTertiary,
              ),
              // CORRECCIÓN: Ya no se le pasa el serverUrl
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DataManagerScreen())),
            ),
          ],
        ),
      ),
    );
  }
}