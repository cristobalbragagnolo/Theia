import 'package:image_picker/image_picker.dart';

// PASO 1: Definir los estados posibles con un enum.
// Esto evita errores de tipeo (ej. "aproved" en lugar de "approved")
// y hace el código más legible.
enum ImageStatus {
  pending,  // Aún no procesada
  approved, // Aprobada por la IA
  rejected, // Rechazada por la IA
  edited,   // Aprobada manualmente por el usuario
}

// ÚNICA DEFINICIÓN de la clase ImageResult.
// Todos los demás archivos la importarán desde aquí.
class ImageResult {
  final XFile imageFile;
  // PASO 2: Cambiar el tipo de 'status' de String a nuestro nuevo enum.
  ImageStatus status;
  String rejectionReason;
  List<double>? box;
  List<List<double>>? keypoints;
  bool isSelected;

  ImageResult({
    required this.imageFile,
    // PASO 3: El estado inicial por defecto ahora es el valor del enum.
    this.status = ImageStatus.pending,
    this.rejectionReason = '',
    this.box,
    this.keypoints,
    this.isSelected = true,
  });
}

// El resto de la clase DataRepository no necesita cambios,
// ya que su lógica es manejar la lista de objetos 'ImageResult',
// sin importar los detalles internos de la clase.
class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() {
    return _instance;
  }
  DataRepository._internal();

  final List<ImageResult> imageResults = [];

  void addResult(ImageResult result) {
    if (!imageResults.any((r) => r.imageFile.path == result.imageFile.path)) {
      imageResults.add(result);
    }
  }

  void addAllResults(List<ImageResult> results) {
    for (var result in results) {
      addResult(result);
    }
  }

  void clear() {
    imageResults.clear();
  }
}