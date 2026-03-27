# Registro Técnico Unificado Theia (Actualizado)

Fecha: 2026-03-25  
Estado: vigente  
Reemplaza: `docs/changes_2026-03-16.md`, `docs/changes_2026-03-18.md`, `docs/vitacora_2026-03-18.md`

## 1) Estructura funcional del sistema

Theia está organizado en 5 bloques principales:

1. Captura y predicción en tiempo real (`LiveModeScreen`).
2. Procesamiento por lotes desde galería (`BatchModeScreen`).
3. Captura de campo con telemetría (`EcoFieldModeScreen`, Android).
4. Gestión y selección de archivos de datos (`DataManagerScreen`).
5. Análisis morfométrico y visualización (`AnalysisResultScreen`, `MorphospaceScreen`, `SpecimenViewerScreen`).

Capas técnicas:

- UI Flutter: pantallas, edición manual, visualización de confianza y gráficos.
- Lógica matemática local: GPA/PCA en `lib/analysis/morph_analysis.dart` (sin servidor).
- Integración nativa Android (`MainActivity.kt`): TFLite, sensores, ubicación, guardado en galería y telemetría.

## 2) Modos y recursos usados

### 2.1 Live Mode

Archivo principal: `lib/screens/live_mode_screen.dart`

Recursos:

- Cámara (`camera` package).
- Canal nativo `com.example.theia/tflite`:
  - `runLiveDetector` (preview con caja, Android).
  - `runTFLite` (inferencia completa foto capturada).
- Modelos TFLite (assets):
  - `assets/detector_nano_fp32.tflite`
  - `assets/pose_medium_fp32.tflite`

Funcionamiento:

1. Muestra preview de cámara.
2. En Android, superpone caja/confianza en vivo con `runLiveDetector`.
3. Al disparar, ejecuta `runTFLite`.
4. Si no hay caja o keypoints: `rejected`.
5. Si hay salida válida: `approved`.
6. Tras procesar, abre siempre `DetailScreen` para revisión/edición manual.
7. Si el usuario guarda en `DetailScreen`, el estado pasa a `edited`; puede aceptarse y añadirse al lote live.

Salida de archivo:

- Exportación manual del lote live (mín. 3):  
  `theia_poblacion_<dd-MM-yyyy_HH-mm>_<n>-especimenes-live__LM.csv`  
  Ubicación: `getApplicationDocumentsDirectory()`.

### 2.2 Batch Mode

Archivo principal: `lib/screens/batch_mode_screen.dart`

Recursos:

- Galería (`image_picker`).
- Canal nativo `runTFLite`.
- Misma pareja de modelos TFLite que Live.

Funcionamiento:

1. Carga imágenes desde galería.
2. Ejecuta inferencia por imagen.
3. Si no hay caja/keypoints: `rejected`; si hay salida válida: `approved`.
4. Permite abrir `DetailScreen` por miniatura para corrección manual (`edited`).
5. Orden de lista configurable: original, rechazadas primero, editadas primero.

Salida de archivo:

- Exportación de aprobadas/editadas:  
  `theia_poblacion_<dd-MM-yyyy_HH-mm>_<n>-especimenes__LM.csv`  
  Ubicación: `getApplicationDocumentsDirectory()`.

### 2.3 Eco-Field Mode (Android)

Archivos: `lib/screens/eco_field_mode_screen.dart`, `lib/services/eco_field_platform.dart`, `android/.../MainActivity.kt`

Recursos:

- Cámara Android.
- Sensores de brújula (acelerómetro + magnetómetro).
- Ubicación (fine/coarse, si concedida).
- Canal nativo:
  - `requestLocationPermission`
  - `getEcoTelemetry`
  - `runEcoCrop`
  - `saveImageToGallery`
- Detector TFLite Nano para modo `AI-Crop`.

Funcionamiento:

1. Al iniciar sesión pide:
  - nombre de batch
  - modo de salida: `AI-Crop` o `Full-Frame`
  - filtro blur opcional (solo `AI-Crop`)
2. Captura foto.
3. `AI-Crop`: detecta, recorta y opcionalmente rechaza por blur (varianza Laplaciana).
4. Guarda imagen final en galería Android: `Pictures/THEIA/<sessionFolder>`.
5. Añade fila de telemetría por captura.

Salida de archivos:

- CSV de telemetría:
  `eco_field_<sessionFolder>_<dd-MM-yyyy_HH-mm-ss>.csv`
  columnas:
  `image_name,latitude,longitude,altitude,gps_accuracy,compass_heading,ai_confidence`
  (en `Full-Frame`, `ai_confidence = NA`).
- Imágenes JPEG en galería Android (no en docs dir de la app).

### 2.4 Data Manager

Archivo principal: `lib/screens/data_manager_screen.dart`

Recursos:

- Lectura/escritura local de archivos.
- Parseo CSV (`csv` package).
- Cálculo GPA/PCA local (`ml_linalg` + `MorphometricAnalysis`).
- Compartir archivos (`share_plus`).

Funcionamiento:

1. Clasifica archivos por tipo:
  - landmarks (`__LM.csv` y legacy),
  - análisis CSV (`__ANL_Axx.csv` y legacy),
  - análisis JSON (`__ANL_Axx.json` y legacy),
  - meta, eco telemetry.
2. Excluye `eco_field_*.csv` como input de landmarks.
3. Permite:
  - abrir análisis existente (preferencia JSON),
  - analizar un landmarks CSV,
  - borrar/compartir archivos.

### 2.5 Análisis y visualizaciones

Archivos:

- `lib/screens/analysis_result_screen.dart`
- `lib/screens/morphospace_screen.dart`
- `lib/screens/specimen_viewer_screen.dart`
- `lib/analysis/morph_analysis.dart`
- `lib/analysis/analysis_constants.dart`

Recursos:

- GPA/PCA local (sin backend).
- `fl_chart` para morfoespacio.

Visualizaciones:

1. Wireframes por componente (±2DE) + switch de inversión de signo por PC.
2. Tabla de scores (PC1..PCk, k configurable; actual: 5).
3. Morfoespacio PC1 vs PC2:
  - scatter interactivo
  - selección bidireccional punto/fila
  - navegación a visor de espécimen (media vs espécimen vs superposición).

Salida de archivos de análisis:

- CSV de análisis: `<datasetRoot>__ANL_Axx.csv`
- JSON enriquecido: `<datasetRoot>__ANL_Axx.json`

`datasetRoot` se deriva del landmarks fuente (`__LM` se recorta).  
`Axx` incrementa automáticamente por dataset (`A01`, `A02`, ...).

JSON incluye:

- `meta` (source_file, dataset_root, run, n, p, k, timestamp),
- `gpa` (aligned_shapes, mean_shape),
- `pca` (scores, loadings, eigenvalues, varianzas),
- `raw_landmarks` y centroid sizes cuando están disponibles.

## 3) Flujo de archivos entre módulos

1. `LiveMode` o `BatchMode` generan `__LM.csv`.
2. `DataManager` detecta `__LM.csv` y lo usa como entrada de análisis.
3. `DataManager` ejecuta GPA/PCA y abre `AnalysisResult`.
4. `AnalysisResult` exporta `__ANL_Axx.csv` + `__ANL_Axx.json`.
5. `DataManager` puede reabrir análisis desde JSON/CSV en sesiones futuras.

Flujos paralelos:

- `Eco-Field` genera `eco_field_*.csv` + JPEG en galería, pero esos CSV no entran al flujo morfométrico automáticamente.
- Ajustes globales generan `theia_settings.json` (ecoFieldEnabled, uiScale).

## 4) Personalización y enfoque Human-Centered AI

## 4.1 Personalización

- Tema: `System`, `Light`, `Dark`.
- Idioma: sistema + 11 idiomas:
  `es`, `en`, `pt`, `it`, `fr`, `de`, `el`, `tr`, `ru`, `zh`, `ar`.
- Escala UI:
  - preferencia usuario: `0.85` a `1.35`,
  - combinada con escala del sistema y factor responsivo por ancho.
- Eco-Field: ON/OFF desde ajustes, persistente entre reinicios.

## 4.2 Prácticas HC-AI implementadas

1. Human-in-the-loop:
  - `DetailScreen` permite corregir landmarks manualmente en Live y Batch.
2. Transparencia de confianza:
  - grid de 32 puntos con porcentaje por landmark.
  - color semántico por umbrales de confianza.
3. Reversibilidad/Control:
  - aceptar, editar, descartar, repetir.
4. Trazabilidad:
  - naming estructurado `__LM`, `__ANL_Axx`.
  - JSON de análisis reproducible.
5. Inspección visual:
  - wireframes de deformación ±2DE,
  - tabla numérica y morfoespacio interactivo,
  - visor de espécimen contra media.

## 6) Conclusión operativa

Theia funciona actualmente como pipeline local y trazable:

- Captura/predicción en Live y Batch con revisión manual integrada.
- Captura Eco-Field con telemetría y almacenamiento en galería.
- Análisis GPA/PCA reproducible con export CSV+JSON.
- Visualización multicapas (wireframes, tabla, morfoespacio, espécimen).

Este documento pasa a ser el registro único de referencia técnica vigente.
