# Theia — Documentación / Documentation

## Español

### Panorama general
- App Flutter para adquisición y análisis de morfometría geométrica con 32 landmarks.
- Dos flujos de captura: **Modo Live** (cámara con previsualización y caja en vivo) y **Modo Batch** (imágenes desde la galería).
- Tercera área: **Gestor de Datos** para GPA/PCA y visualizaciones (wireframes, morfoespacio, exportación de análisis).

### Flujo de trabajo recomendado (end-to-end)
1. **Live Mode**: toma foto y genera predicción de landmarks (con revisión/edición en `DetailScreen`).
2. **Eco-Field Mode**: toma foto de campo y la organiza en carpeta de sesión (`Pictures/THEIA/<session>`), guardando telemetría en `eco_field_*.csv`.
3. **Batch Mode**: procesa fotos ya existentes en galería (incluyendo fotos capturadas previamente por Eco-Field) para producir landmarks válidos.
4. **Data Manager + Analysis**: usa archivos `__LM.csv` de Live/Batch como entrada para ejecutar GPA/PCA y exportar `__ANL_Axx.csv` + `__ANL_Axx.json`.

Nota: `Eco-Field` no genera landmarks directamente; su salida principal son imágenes organizadas + metadatos. El paso de landmarks ocurre en Live o Batch.

### Modo Live (cámara)
- Vista previa con detector ligero en tiempo real (solo en Android); muestra caja normalizada y % de confianza.
- Al tomar foto: detiene preview, ejecuta pipeline nativo `runTFLite` y valida resultados en Flutter.
- Flujo de validación: si no hay caja o keypoints -> `rejected`; en otro caso -> `approved`.
- Tras cada captura procesada se abre automáticamente `DetailScreen` para revisar/ajustar landmarks.
- Controles sobre el resultado: **Aceptar** (añade al lote si está aprobado o editado), **Editar** (abre visor de landmarks para mover puntos), **Descartar** o **Repetir**.
- Exportación: botón activo con ≥3 especímenes. Genera CSV `theia_poblacion_<dd-MM-yyyy>_<HH-mm>_<n>-especimenes-live__LM.csv` en el directorio de documentos de la app.

### Modo Batch (galería)
- Permite agregar imágenes o reemplazar la lista; muestra conteo y orden configurable (original, rechazadas primero, editadas primero).
- Procesa en lote con `runTFLite` sobre cada imagen; muestra progreso y permite detener.
- Al tocar una miniatura procesada abre el editor para mover landmarks y marcar `edited`.
- Exportación: CSV `theia_poblacion_<dd-MM-yyyy>_<HH-mm>_<n>-especimenes__LM.csv` con todos los especímenes `approved` o `edited`, en documentos de la app.

### Archivos generados
- **Landmarks (captura):** CSV con cabecera `image_name,kpt1_x,kpt1_y,...,kpt32_x,kpt32_y` y valores normalizados [0,1].
- **Live preview:** solo muestra caja y confianza; no escribe archivo hasta que se exporta lote.
- **Análisis GPA/PCA:** archivos `<datasetRoot>__ANL_Axx.csv` y `<datasetRoot>__ANL_Axx.json` en documentos de la app. El JSON incluye metadatos (`source_file`, `dataset_root`, `analysis_run`) y matrices completas para reproducir el análisis.

### Modelos de IA y parámetros
- **Detector (nano)** `assets/detector_nano_fp32.tflite`
  - Entrada: bitmap letterbox 640×640 RGB, float32 normalizado 0‑1.
  - Salida: 8 400 detecciones, cada una `[cx, cy, w, h, conf]`. Confianza mínima 0.4; se selecciona la mejor.
  - Uso: previsión Live (`runLiveDetector`) y primer paso de `runTFLite`.
- **Pose (medium)** `assets/pose_medium_fp32.tflite`
  - Entrada: recorte de la detección con padding 15%, letterbox 640×640 RGB, float32 0‑1.
  - Salida: 8 400 filas de 101 valores `[cx, cy, w, h, conf, kp1_x, kp1_y, kp1_conf, …, kp32_x, kp32_y, kp32_conf]`.
  - Umbral de landmarks: 0.25; se toma la detección con mayor confianza.
- **Resultado enviado a Flutter (`runTFLite`):** lista `[box, keypoints, confidences]` donde:
  - `box`: `[cx, cy, w, h]` normalizados al tamaño original; en Flutter se convierten a `[left, top, right, bottom]`.
  - `keypoints`: 96 valores (32×3) normalizados; Flutter guarda solo `[x, y]` de cada punto.
  - `confidences`: array con la confianza de la detección.

### Análisis morfométrico (Gestor de Datos)
- Entrada esperada: CSV de landmarks con el formato exportado por Live/Batch (al menos 3 especímenes).
- **GPA (`MorphometricAnalysis.runGPA`):**
  - Centra cada forma en su centroide y escala a tamaño de centroide 1.
  - Alinea iterativamente con rotación de Kabsch (SVD 2×2) hasta convergencia; intercambia X↔Y al final para seguir la convención geomorph.
- **PCA (`MorphometricAnalysis.runPCA`):**
  - Aplana cada forma a vector `[x1,y1,x2,y2,…]`, centra por columna, covarianza `XcᵀXc/(N-1)`.
  - Autovalores/vectores por iteración de potencia con deflación; `k = 5` componentes (configurable en `lib/analysis/analysis_constants.dart`).
  - Scores = `Xc * V`; varianza explicada en ratios y porcentajes (% en pantalla y CSV).
- Visualizaciones:
  - Wireframes ±2DE sobre la forma media de cada PC, con inversión de signo opcional.
  - Tabla de scores (PC1…PC5), morfoespacio PC1–PC2 interactivo y visor de especímenes (media vs individuo).
  - Campo de interpretación libre que se guarda junto con los scores en el CSV de análisis.

### Notas adicionales
- La previsualización Live solo está habilitada en Android; en iOS se captura la foto y se procesa offline.
- Todos los archivos se escriben en `getApplicationDocumentsDirectory()` (directorio de documentos propio de la app en cada plataforma).
- No se aplica filtro estructural adicional en Flutter: la corrección fina de landmarks se realiza en `DetailScreen`.

---

## English

### Overview
- Flutter app for geometric morphometrics with 32 landmarks.
- Two acquisition paths: **Live Mode** (camera with live box overlay) and **Batch Mode** (gallery images).
- A **Data Manager** area runs GPA/PCA and shows wireframes, morphospace, and exports.

### Recommended End-to-End Workflow
1. **Live Mode**: capture a photo and generate landmark predictions (with review/editing in `DetailScreen`).
2. **Eco-Field Mode**: capture field photos and organize them by session (`Pictures/THEIA/<session>`), storing telemetry in `eco_field_*.csv`.
3. **Batch Mode**: process pre-existing gallery photos (including images previously captured in Eco-Field) to produce valid landmark outputs.
4. **Data Manager + Analysis**: use `__LM.csv` files from Live/Batch as input for GPA/PCA, then export `__ANL_Axx.csv` + `__ANL_Axx.json`.

Note: `Eco-Field` does not generate landmarks directly; it produces organized images + metadata. Landmark generation happens in Live or Batch.

### Live Mode (camera)
- Live preview uses a lightweight detector (Android only) to draw the bounding box and confidence.
- When you take a photo the preview pauses, the native `runTFLite` pipeline runs, and Flutter validates the output.
- Validation: missing box/keypoints => `rejected`; otherwise `approved`.
- After every processed capture, `DetailScreen` opens automatically for landmark review/editing.
- Result actions: **Accept** (adds to batch when approved/edited), **Edit** (move landmarks), **Discard**, **Retake**.
- Export: button enabled with ≥3 specimens. Creates CSV `theia_poblacion_<dd-MM-yyyy>_<HH-mm>_<n>-especimenes-live__LM.csv` in the app documents directory.

### Batch Mode (gallery)
- Add or replace image list; display count and sorting (original, rejected-first, edited-first).
- Runs `runTFLite` on each image with progress and stop control.
- Tapping a processed thumbnail opens the landmark editor and marks the item as `edited`.
- Export: CSV `theia_poblacion_<dd-MM-yyyy>_<HH-mm>_<n>-especimenes__LM.csv` with all `approved` or `edited` specimens, saved to the app documents directory.

### Files produced
- **Landmarks (capture):** CSV header `image_name,kpt1_x,kpt1_y,...,kpt32_x,kpt32_y` with normalized [0,1] coordinates.
- **Live preview:** draws the box/confidence only; no file until batch export.
- **GPA/PCA analysis:** files `<datasetRoot>__ANL_Axx.csv` and `<datasetRoot>__ANL_Axx.json` stored in the app documents directory. The JSON stores full matrices and metadata (`source_file`, `dataset_root`, `analysis_run`) for reproducibility.

### AI models and I/O
- **Detector (nano)** `assets/detector_nano_fp32.tflite`
  - Input: letterboxed 640×640 RGB, float32 normalized 0–1.
  - Output: 8,400 detections `[cx, cy, w, h, conf]`; best box above 0.4 is kept.
  - Used for Live preview (`runLiveDetector`) and as step 1 of `runTFLite`.
- **Pose (medium)** `assets/pose_medium_fp32.tflite`
  - Input: detection crop padded 15%, letterboxed to 640×640 RGB, float32 0–1.
  - Output: 8,400 rows with 101 values `[cx, cy, w, h, conf, kp1_x, kp1_y, kp1_conf, …, kp32_x, kp32_y, kp32_conf]`.
  - Landmark threshold: 0.25; the highest-confidence detection is chosen.
- **Payload returned to Flutter (`runTFLite`):** list `[box, keypoints, confidences]`
  - `box`: `[cx, cy, w, h]` normalized to the original image; Flutter converts to `[left, top, right, bottom]`.
  - `keypoints`: 96 floats (32×3) normalized; Flutter stores `[x, y]` per landmark.
  - `confidences`: array with the detection confidence.

### Morphometric analysis (Data Manager)
- Expected input: landmark CSV exported by Live/Batch (minimum 3 specimens).
- **GPA (`MorphometricAnalysis.runGPA`):**
  - Center at centroid, scale to centroid size 1.
  - Iterative Kabsch rotation (2×2 SVD) until convergence; swap X↔Y at the end to match the geomorph convention.
- **PCA (`MorphometricAnalysis.runPCA`):**
  - Flatten shapes to `[x1,y1,x2,y2,…]`, column-center, covariance `XcᵀXc/(N-1)`.
  - Eigenpairs via power iteration with deflation; `k = 5` components (`lib/analysis/analysis_constants.dart`).
  - Scores = `Xc * V`; variance explained ratios (% shown on screen and in CSV).
- Visuals:
  - ±2 SD deformation wireframes per PC with optional sign flip.
  - Scores table (PC1…PC5), interactive PC1–PC2 morphospace, specimen viewer (mean vs individual).
  - Free-text interpretation stored alongside scores in the analysis CSV.

### Extra notes
- Live preview runs only on Android; on iOS the photo is captured and processed without live boxes.
- All files are written under `getApplicationDocumentsDirectory()` (platform-specific app documents).
- No extra structural filter is applied in Flutter; fine landmark correction is done in `DetailScreen`.
