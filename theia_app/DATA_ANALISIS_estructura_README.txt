DATA_ANALISIS (formato JSON) – estructura y notas
==================================================

Ruta de guardado
- Se genera en la carpeta de documentos de la app (getApplicationDocumentsDirectory).
- Nombre: DATOS_ANALISIS_theia_<base>.json (si existe, se usa sufijo _2_, _3_, ...).

Estructura principal
{
  "meta": {
    "version": 1,               // para compatibilidad futura
    "created_at": "ISO8601",
    "source_file": "<csv_origen>",
    "n": <num_especimenes>,
    "p": <num_landmarks>,
    "k": <num_componentes_PCA>
  },
  "specimens": ["img1.jpg", "img2.jpg", ...],
  "interpretation": "texto libre",
  "gpa": {
    "aligned_shapes": [ [[x,y], [x,y], ...], ... ],  // lista de matrices p×2 centradas y escaladas (CS=1)
    "mean_shape": [[x,y], [x,y], ...]               // matriz p×2
  },
  "pca": {
    "scores": [[pc1, pc2, ...], ...],               // matriz n×k
    "loadings": [[...], ...],                       // matriz (2p)×k, vectorizado intercalado [x1,y1,x2,y2,...]
    "eigenvalues": [...],                           // longitud k
    "variance_explained": [...],                    // igual que eigenvalues (crudo)
    "variance_explained_ratio": [...]               // proporciones (suma ≈ 1.0)
  },
  "raw_landmarks": [ [[x,y], ...], ... ],           // opcional: formas originales p×2 por espécimen
  "centroid_sizes": [cs1, cs2, ...]                 // opcional: centroid size por espécimen
}

Notas de uso
- Todos los números van en double (JSON). Los puntos (x,y) están ya alineados en GPA; los crudos van en raw_landmarks.
- Para reconstruir un specimen vectorizado usa el orden intercalado: [x1,y1,x2,y2,...].
- Este archivo permite re-visualizar y comparar con pipelines externos (R/geomorph) sin recalcular GPA/PCA.

Compatibilidad futura
- Si se incrementa "version", validar la presencia de campos antes de usarlos.
