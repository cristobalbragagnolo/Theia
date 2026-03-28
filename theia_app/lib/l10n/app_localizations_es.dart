// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nFlujo fenotípico de IA móvil. Análisis sin conexión, en el dispositivo y accesible.';

  @override
  String get themeMenuTooltip => 'Seleccionar tema';

  @override
  String get themeSystem => 'Seguir sistema';

  @override
  String get themeLight => 'Modo claro';

  @override
  String get themeDark => 'Modo oscuro';

  @override
  String get themeLabel => 'Tema';

  @override
  String get languageMenuTooltip => 'Seleccionar idioma';

  @override
  String get languageSystem => 'Usar idioma del sistema';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get uiScaleTitle => 'Tamaño de interfaz';

  @override
  String get uiScaleHint => 'texto y botones';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Restablecer';

  @override
  String get uiScaleClose => 'Cerrar';

  @override
  String get homeLiveButton => 'Modo Live (Cámara)';

  @override
  String get homeBatchButton => 'Modo Batch (Galería)';

  @override
  String get homeDataManagerButton => 'Gestor de Datos y Análisis';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Modo Batch';

  @override
  String get btnApplyAi => 'Aplicar IA';

  @override
  String get btnAddGallery => 'Agregar de la Galería';

  @override
  String get btnReplaceList => 'Reemplazar Lista';

  @override
  String imagesLoaded(int count) {
    return 'Imágenes cargadas: $count';
  }

  @override
  String get btnClearList => 'Vaciar Lista';

  @override
  String get sortBy => 'Ordenar por:';

  @override
  String get sortOriginal => 'Orden original';

  @override
  String get sortRejectedFirst => 'Rechazadas primero';

  @override
  String get sortEditedFirst => 'Editadas primero';

  @override
  String exportResults(int count) {
    return 'Exportar ($count) Resultados';
  }

  @override
  String get noExportable =>
      'No hay resultados aprobados o editados para exportar.';

  @override
  String exportSuccess(Object fileName, int count) {
    return '¡Éxito! Se creó \'$fileName\' con $count especímenes.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Proceso completado en $time. Se procesaron $count imágenes.';
  }

  @override
  String get stopProcess => 'Detener Proceso';

  @override
  String get filterStructural => 'Filtro estructural';

  @override
  String get filterStructuralOn => 'Activado (valida posiciones)';

  @override
  String get filterStructuralOff => 'Apagado (todas las predicciones pasan)';

  @override
  String get detectionLowConfidence => 'Baja confianza de detección.';

  @override
  String rejectionPoints(Object points) {
    return 'Incoherencia punto(s): $points';
  }

  @override
  String get liveTitle => 'Modo Live';

  @override
  String liveBatchCount(int count) {
    return 'Lote: $count especímenes';
  }

  @override
  String snackAddBatch(int count) {
    return 'Espécimen añadido al lote. Total: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Rechazado: $reason. No se añadió.';
  }

  @override
  String get snackDiscarded => 'Resultado descartado.';

  @override
  String get readyNewCapture => 'Listo para una nueva captura.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Error durante el análisis: $error';
  }

  @override
  String get noSpecimensToExport =>
      'No hay especímenes en el lote para exportar.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return '¡Éxito! Se creó \'$fileName\' con $count especímenes.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Error al exportar: $error';
  }

  @override
  String get btnDiscard => 'Descartar';

  @override
  String get btnAccept => 'Aceptar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnRetake => 'Repetir';

  @override
  String get btnExportBatch => 'Exportar Lote';

  @override
  String get resultRejectedPrefix => 'RECHAZADO:';

  @override
  String get resultLabel => 'Resultado';

  @override
  String get statusApproved => 'Aprobada';

  @override
  String get statusRejected => 'Rechazada';

  @override
  String get statusEdited => 'Editada';

  @override
  String detailMovingPoint(int index) {
    return 'Moviendo Punto $index';
  }

  @override
  String get detailEditor => 'Editor';

  @override
  String get detailSaveTooltip => 'Guardar Cambios';

  @override
  String get detailSaveSuccess => 'Cambios guardados.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Rechazado: $reason';
  }

  @override
  String get detailPrevPoint => 'Punto Anterior';

  @override
  String get detailNextPoint => 'Punto Siguiente';

  @override
  String get detailPrevImage => 'Imagen anterior';

  @override
  String get detailNextImage => 'Siguiente imagen';

  @override
  String get dmTitle => 'Gestor de Datos';

  @override
  String get dmLandmarkFiles => 'Archivos de Landmarks (Entrada)';

  @override
  String get dmAnalysisFiles => 'Archivos de Análisis (Resultados)';

  @override
  String get dmNoFiles => 'No se encontraron archivos.';

  @override
  String get dmDeleteConfirmTitle => 'Confirmar borrado';

  @override
  String dmDeleteConfirmContent(Object file) {
    return '¿Quieres eliminar el archivo \"$file\"?';
  }

  @override
  String get dmDeleteCancel => 'Cancelar';

  @override
  String get dmDeleteConfirm => 'Eliminar';

  @override
  String get dmDeleteSuccess => 'Archivo eliminado';

  @override
  String dmDeleteError(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get dmAnalyzeButton => 'Analizar archivo de landmarks';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Error en el análisis: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV vacío o solo cabecera.';

  @override
  String get dmNeedThree => 'Se requieren al menos 3 especímenes válidos.';

  @override
  String get cameraLoadError => 'Error al cargar la cámara.';

  @override
  String get drawerInfo => 'Información';

  @override
  String get drawerInfoSubtitle => 'Modelo en uso y agradecimientos';

  @override
  String get infoPageTitle => 'Información';

  @override
  String get infoModelSection => 'Modelo en uso';

  @override
  String get infoThanksSection => 'Agradecimientos';

  @override
  String get infoPlaceholder =>
      'Próximamente añadiremos detalles del modelo y créditos.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Compartir / Exportar';

  @override
  String get homeEcoFieldButton => 'Modo Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Activa Eco-Field Mode en Ajustes para usarlo.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled =>
      'Activado para captura de campo';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Desactivado. Actívalo para usarlo desde Home.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Ubicación no concedida. Se capturará con GPS vacío.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Nueva sesión de campo';

  @override
  String get ecoFieldBatchLabel => 'Batch / Población';

  @override
  String get ecoFieldBatchHint => 'Ej.: poblacion_norte_01';

  @override
  String get ecoFieldBatchRequired => 'Introduce un nombre de batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Modo de salida';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Optimizado)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Original)';

  @override
  String get ecoFieldBlurFilterLabel => 'Filtro de desenfoque (Laplaciana)';

  @override
  String get ecoFieldStartSession => 'Iniciar sesión';

  @override
  String get ecoFieldCancelSession => 'Cancelar';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Sesión lista: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Guardada: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Error al guardar captura: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'No se detectó flor con confianza suficiente.';

  @override
  String get ecoFieldCaptureRejectedBlur =>
      'Captura descartada por desenfoque.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'No se pudo generar el recorte IA.';

  @override
  String analysisPcaError(Object error) {
    return 'Error al calcular PCA: $error';
  }

  @override
  String get analysisTitle => 'Resultados del Análisis';

  @override
  String get analysisNavTable => 'Tabla';

  @override
  String get analysisNavSave => 'Guardar';

  @override
  String get analysisWireframesSection => 'Wireframes de deformación  ±2DE';

  @override
  String get analysisNoComponents =>
      'No fue posible calcular componentes principales.';

  @override
  String get analysisScoresSection => 'Tabla de Scores';

  @override
  String get analysisInterpretationSection => 'Interpretación y guardado';

  @override
  String get analysisInterpretationHint =>
      'Ej.: PC1: apertura corolar; PC2: curvatura; PC3: variación basal...';

  @override
  String get analysisSaveWithInterpretation => 'Guardar con interpretación';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Media · $title';
  }

  @override
  String get analysisNoInterpretation => 'Sin interpretación';

  @override
  String get analysisCsvHeaderImage => 'Imagen';

  @override
  String get analysisCsvHeaderInterpretation => 'Interpretación';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Exportados: $csvFile y $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Exportado: $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - análisis';

  @override
  String get analysisShareText => 'Archivos exportados desde Theia';

  @override
  String analysisShareError(Object error) {
    return 'No se pudieron compartir los archivos: $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 Nota HCDAI:\nLos wireframes muestran deformaciones hipotéticas ±2DE sobre la forma media.\nInterprétalas biológicamente (apertura, curvatura, simetría) comparando con especímenes reales.';

  @override
  String get morphTitle => 'Morfoespacio (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Limpiar selección';

  @override
  String get morphAxisLabel => 'PC1 (Eje X)  /  PC2 (Eje Y)';

  @override
  String get specimenViewerMean => 'Media';

  @override
  String get specimenViewerSpecimen => 'Espécimen';

  @override
  String get specimenViewerOverlay => 'Superpuestos';

  @override
  String get dmSelectFileFirst => 'Selecciona un archivo primero.';

  @override
  String dmShareError(Object error) {
    return 'No se pudo compartir: $error';
  }

  @override
  String get dmAnalysisJsonNotFound =>
      'No se encontró el JSON del análisis para abrirlo.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'No se pudo abrir el análisis: $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Formato JSON inválido';

  @override
  String get dmExpectedJsonObject => 'Se esperaba un objeto JSON';

  @override
  String get dmExpectedMatrixList => 'Se esperaba matriz en formato lista';

  @override
  String get dmEmptyMatrix => 'Matriz vacía';

  @override
  String get dmExpectedMatricesList => 'Se esperaba lista de matrices';
}
