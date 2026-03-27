

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:theia/data_repository.dart';
import 'package:theia/widgets/keypoint_painter.dart';

class DetailScreen extends StatefulWidget {
  final List<ImageResult> results;
  final int initialIndex;

  const DetailScreen({
    super.key,
    required this.results,
    required this.initialIndex,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _currentIndex;
  List<List<double>> _editedKeypoints = [];
  int _selectedKeypointIndex = -1;
  bool _hasChanges = false;
  ui.Image? _loadedImage;

  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadImageAndSetup();
  }

  void _loadImageAndSetup() async {
    final image = await _loadImage(File(widget.results[_currentIndex].imageFile.path));
    if (!mounted) return;

    setState(() {
      _loadedImage = image;
      _editedKeypoints = widget.results[_currentIndex].keypoints?.map((p) => List<double>.from(p)).toList() ?? [];

      if (_editedKeypoints.isNotEmpty) {
        _selectedKeypointIndex = 0;
      }
    });
  }

  void _saveChanges() {
    final currentResult = widget.results[_currentIndex];
    currentResult.keypoints = _editedKeypoints;
    currentResult.status = ImageStatus.edited;
    _hasChanges = true;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cambios guardados."), backgroundColor: Colors.green),
    );
    Navigator.pop(context, _hasChanges);
  }

  void _selectNextKeypoint() {
    if (_editedKeypoints.isEmpty) return;
    setState(() {
      _selectedKeypointIndex = (_selectedKeypointIndex + 1) % _editedKeypoints.length;
    });
  }

  void _selectPreviousKeypoint() {
    if (_editedKeypoints.isEmpty) return;
    setState(() {
      _selectedKeypointIndex = (_selectedKeypointIndex - 1 + _editedKeypoints.length) % _editedKeypoints.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _selectedKeypointIndex != -1
        ? 'Moviendo Punto ${_selectedKeypointIndex + 1}'
        : 'Editor';
    
    // Obtenemos el resultado actual para acceder a sus propiedades
    final currentResult = widget.results[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges, tooltip: 'Guardar Cambios')
          ],
        ),
        body: Column(
          children: [
            // NUEVO: Banner informativo que solo aparece si la imagen fue rechazada
            if (currentResult.status == ImageStatus.rejected && currentResult.rejectionReason.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade900,
                child: Text(
                  'Rechazado: ${currentResult.rejectionReason}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: _loadedImage == null
                  ? const Center(child: CircularProgressIndicator())
                  : InteractiveViewer(
                      transformationController: _transformationController,
                      maxScale: 16.0,
                      minScale: 0.1,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _loadedImage!.width.toDouble(),
                          height: _loadedImage!.height.toDouble(),
                          child: GestureDetector(
                            onTapUp: (details) {
                              if (_selectedKeypointIndex == -1) return;
                              
                              final Offset imagePoint = details.localPosition;

                              setState(() {
                                _editedKeypoints[_selectedKeypointIndex][0] = (imagePoint.dx / _loadedImage!.width).clamp(0.0, 1.0);
                                _editedKeypoints[_selectedKeypointIndex][1] = (imagePoint.dy / _loadedImage!.height).clamp(0.0, 1.0);
                              });
                            },
                            child: CustomPaint(
                              painter: KeypointPainter(
                                image: _loadedImage!,
                                keypoints: _editedKeypoints,
                                selectedKeypointIndex: _selectedKeypointIndex,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            
            Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(8.0).copyWith(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectPreviousKeypoint,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Punto Anterior"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectNextKeypoint,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Punto Siguiente"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    return await decodeImageFromList(data);
  }
}