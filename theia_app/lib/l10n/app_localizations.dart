import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt'),
    Locale('it'),
    Locale('el'),
    Locale('fr'),
    Locale('tr'),
    Locale('de'),
    Locale('ru'),
    Locale('zh'),
    Locale('ar'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Theia'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Edge AI Morphometrics.\nFlujo fenotípico de IA móvil. Análisis sin conexión, en el dispositivo y accesible.'**
  String get appTagline;

  /// No description provided for @themeMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar tema'**
  String get themeMenuTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Seguir sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get themeDark;

  /// No description provided for @themeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get languageMenuTooltip;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Usar idioma del sistema'**
  String get languageSystem;

  /// No description provided for @languageLabel.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageLabel;

  /// No description provided for @uiScaleTitle.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de interfaz'**
  String get uiScaleTitle;

  /// No description provided for @uiScaleHint.
  ///
  /// In es, this message translates to:
  /// **'texto y botones'**
  String get uiScaleHint;

  /// No description provided for @uiScaleSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{percent}% - {hint}'**
  String uiScaleSubtitle(int percent, Object hint);

  /// No description provided for @uiScaleReset.
  ///
  /// In es, this message translates to:
  /// **'Restablecer'**
  String get uiScaleReset;

  /// No description provided for @uiScaleClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get uiScaleClose;

  /// No description provided for @homeLiveButton.
  ///
  /// In es, this message translates to:
  /// **'Modo Live (Cámara)'**
  String get homeLiveButton;

  /// No description provided for @homeBatchButton.
  ///
  /// In es, this message translates to:
  /// **'Modo Batch (Galería)'**
  String get homeBatchButton;

  /// No description provided for @homeDataManagerButton.
  ///
  /// In es, this message translates to:
  /// **'Gestor de Datos y Análisis'**
  String get homeDataManagerButton;

  /// No description provided for @splashTitle.
  ///
  /// In es, this message translates to:
  /// **'Theia'**
  String get splashTitle;

  /// No description provided for @batchTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo Batch'**
  String get batchTitle;

  /// No description provided for @btnApplyAi.
  ///
  /// In es, this message translates to:
  /// **'Aplicar IA'**
  String get btnApplyAi;

  /// No description provided for @btnAddGallery.
  ///
  /// In es, this message translates to:
  /// **'Agregar de la Galería'**
  String get btnAddGallery;

  /// No description provided for @btnReplaceList.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar Lista'**
  String get btnReplaceList;

  /// No description provided for @imagesLoaded.
  ///
  /// In es, this message translates to:
  /// **'Imágenes cargadas: {count}'**
  String imagesLoaded(int count);

  /// No description provided for @btnClearList.
  ///
  /// In es, this message translates to:
  /// **'Vaciar Lista'**
  String get btnClearList;

  /// No description provided for @sortBy.
  ///
  /// In es, this message translates to:
  /// **'Ordenar por:'**
  String get sortBy;

  /// No description provided for @sortOriginal.
  ///
  /// In es, this message translates to:
  /// **'Orden original'**
  String get sortOriginal;

  /// No description provided for @sortRejectedFirst.
  ///
  /// In es, this message translates to:
  /// **'Rechazadas primero'**
  String get sortRejectedFirst;

  /// No description provided for @sortEditedFirst.
  ///
  /// In es, this message translates to:
  /// **'Editadas primero'**
  String get sortEditedFirst;

  /// No description provided for @exportResults.
  ///
  /// In es, this message translates to:
  /// **'Exportar ({count}) Resultados'**
  String exportResults(int count);

  /// No description provided for @noExportable.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados aprobados o editados para exportar.'**
  String get noExportable;

  /// No description provided for @exportSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Éxito! Se creó \'{fileName}\' con {count} especímenes.'**
  String exportSuccess(Object fileName, int count);

  /// No description provided for @processingComplete.
  ///
  /// In es, this message translates to:
  /// **'Proceso completado en {time}. Se procesaron {count} imágenes.'**
  String processingComplete(Object time, int count);

  /// No description provided for @stopProcess.
  ///
  /// In es, this message translates to:
  /// **'Detener Proceso'**
  String get stopProcess;

  /// No description provided for @filterStructural.
  ///
  /// In es, this message translates to:
  /// **'Filtro estructural'**
  String get filterStructural;

  /// No description provided for @filterStructuralOn.
  ///
  /// In es, this message translates to:
  /// **'Activado (valida posiciones)'**
  String get filterStructuralOn;

  /// No description provided for @filterStructuralOff.
  ///
  /// In es, this message translates to:
  /// **'Apagado (todas las predicciones pasan)'**
  String get filterStructuralOff;

  /// No description provided for @detectionLowConfidence.
  ///
  /// In es, this message translates to:
  /// **'Baja confianza de detección.'**
  String get detectionLowConfidence;

  /// No description provided for @rejectionPoints.
  ///
  /// In es, this message translates to:
  /// **'Incoherencia punto(s): {points}'**
  String rejectionPoints(Object points);

  /// No description provided for @liveTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo Live'**
  String get liveTitle;

  /// No description provided for @liveBatchCount.
  ///
  /// In es, this message translates to:
  /// **'Lote: {count} especímenes'**
  String liveBatchCount(int count);

  /// No description provided for @snackAddBatch.
  ///
  /// In es, this message translates to:
  /// **'Espécimen añadido al lote. Total: {count}'**
  String snackAddBatch(int count);

  /// No description provided for @snackRejectedNotAdded.
  ///
  /// In es, this message translates to:
  /// **'Rechazado: {reason}. No se añadió.'**
  String snackRejectedNotAdded(Object reason);

  /// No description provided for @snackDiscarded.
  ///
  /// In es, this message translates to:
  /// **'Resultado descartado.'**
  String get snackDiscarded;

  /// No description provided for @readyNewCapture.
  ///
  /// In es, this message translates to:
  /// **'Listo para una nueva captura.'**
  String get readyNewCapture;

  /// No description provided for @errorDuringAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Error durante el análisis: {error}'**
  String errorDuringAnalysis(Object error);

  /// No description provided for @noSpecimensToExport.
  ///
  /// In es, this message translates to:
  /// **'No hay especímenes en el lote para exportar.'**
  String get noSpecimensToExport;

  /// No description provided for @exportLiveSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Éxito! Se creó \'{fileName}\' con {count} especímenes.'**
  String exportLiveSuccess(Object fileName, int count);

  /// No description provided for @exportLiveError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar: {error}'**
  String exportLiveError(Object error);

  /// No description provided for @btnDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get btnDiscard;

  /// No description provided for @btnAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get btnAccept;

  /// No description provided for @btnEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get btnEdit;

  /// No description provided for @btnRetake.
  ///
  /// In es, this message translates to:
  /// **'Repetir'**
  String get btnRetake;

  /// No description provided for @btnExportBatch.
  ///
  /// In es, this message translates to:
  /// **'Exportar Lote'**
  String get btnExportBatch;

  /// No description provided for @resultRejectedPrefix.
  ///
  /// In es, this message translates to:
  /// **'RECHAZADO:'**
  String get resultRejectedPrefix;

  /// No description provided for @resultLabel.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get resultLabel;

  /// No description provided for @statusApproved.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get statusRejected;

  /// No description provided for @statusEdited.
  ///
  /// In es, this message translates to:
  /// **'Editada'**
  String get statusEdited;

  /// No description provided for @detailMovingPoint.
  ///
  /// In es, this message translates to:
  /// **'Moviendo Punto {index}'**
  String detailMovingPoint(int index);

  /// No description provided for @detailEditor.
  ///
  /// In es, this message translates to:
  /// **'Editor'**
  String get detailEditor;

  /// No description provided for @detailSaveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get detailSaveTooltip;

  /// No description provided for @detailSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get detailSaveSuccess;

  /// No description provided for @detailRejectedBanner.
  ///
  /// In es, this message translates to:
  /// **'Rechazado: {reason}'**
  String detailRejectedBanner(Object reason);

  /// No description provided for @detailPrevPoint.
  ///
  /// In es, this message translates to:
  /// **'Punto Anterior'**
  String get detailPrevPoint;

  /// No description provided for @detailNextPoint.
  ///
  /// In es, this message translates to:
  /// **'Punto Siguiente'**
  String get detailNextPoint;

  /// No description provided for @detailPrevImage.
  ///
  /// In es, this message translates to:
  /// **'Imagen anterior'**
  String get detailPrevImage;

  /// No description provided for @detailNextImage.
  ///
  /// In es, this message translates to:
  /// **'Siguiente imagen'**
  String get detailNextImage;

  /// No description provided for @dmTitle.
  ///
  /// In es, this message translates to:
  /// **'Gestor de Datos'**
  String get dmTitle;

  /// No description provided for @dmLandmarkFiles.
  ///
  /// In es, this message translates to:
  /// **'Archivos de Landmarks (Entrada)'**
  String get dmLandmarkFiles;

  /// No description provided for @dmAnalysisFiles.
  ///
  /// In es, this message translates to:
  /// **'Archivos de Análisis (Resultados)'**
  String get dmAnalysisFiles;

  /// No description provided for @dmNoFiles.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron archivos.'**
  String get dmNoFiles;

  /// No description provided for @dmDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar borrado'**
  String get dmDeleteConfirmTitle;

  /// No description provided for @dmDeleteConfirmContent.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres eliminar el archivo \"{file}\"?'**
  String dmDeleteConfirmContent(Object file);

  /// No description provided for @dmDeleteCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dmDeleteCancel;

  /// No description provided for @dmDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get dmDeleteConfirm;

  /// No description provided for @dmDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Archivo eliminado'**
  String get dmDeleteSuccess;

  /// No description provided for @dmDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String dmDeleteError(Object error);

  /// No description provided for @dmAnalyzeButton.
  ///
  /// In es, this message translates to:
  /// **'Analizar archivo de landmarks'**
  String get dmAnalyzeButton;

  /// No description provided for @dmErrorAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Error en el análisis: {error}'**
  String dmErrorAnalysis(Object error);

  /// No description provided for @dmCsvEmpty.
  ///
  /// In es, this message translates to:
  /// **'CSV vacío o solo cabecera.'**
  String get dmCsvEmpty;

  /// No description provided for @dmNeedThree.
  ///
  /// In es, this message translates to:
  /// **'Se requieren al menos 3 especímenes válidos.'**
  String get dmNeedThree;

  /// No description provided for @cameraLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la cámara.'**
  String get cameraLoadError;

  /// No description provided for @drawerInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get drawerInfo;

  /// No description provided for @drawerInfoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Modelo en uso y agradecimientos'**
  String get drawerInfoSubtitle;

  /// No description provided for @infoPageTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoPageTitle;

  /// No description provided for @infoModelSection.
  ///
  /// In es, this message translates to:
  /// **'Modelo en uso'**
  String get infoModelSection;

  /// No description provided for @infoThanksSection.
  ///
  /// In es, this message translates to:
  /// **'Agradecimientos'**
  String get infoThanksSection;

  /// No description provided for @infoPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Próximamente añadiremos detalles del modelo y créditos.'**
  String get infoPlaceholder;

  /// No description provided for @infoAcknowledgementsBody.
  ///
  /// In es, this message translates to:
  /// **'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.'**
  String get infoAcknowledgementsBody;

  /// No description provided for @appTaglineShort.
  ///
  /// In es, this message translates to:
  /// **'Edge AI Morphometrics'**
  String get appTaglineShort;

  /// No description provided for @shareExport.
  ///
  /// In es, this message translates to:
  /// **'Compartir / Exportar'**
  String get shareExport;

  /// No description provided for @homeEcoFieldButton.
  ///
  /// In es, this message translates to:
  /// **'Modo Eco-Field'**
  String get homeEcoFieldButton;

  /// No description provided for @homeEcoFieldLockedMessage.
  ///
  /// In es, this message translates to:
  /// **'Activa Eco-Field Mode en Ajustes para usarlo.'**
  String get homeEcoFieldLockedMessage;

  /// No description provided for @ecoFieldSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Eco-Field Mode'**
  String get ecoFieldSettingsTitle;

  /// No description provided for @ecoFieldSettingsSubtitleEnabled.
  ///
  /// In es, this message translates to:
  /// **'Activado para captura de campo'**
  String get ecoFieldSettingsSubtitleEnabled;

  /// No description provided for @ecoFieldSettingsSubtitleDisabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado. Actívalo para usarlo desde Home.'**
  String get ecoFieldSettingsSubtitleDisabled;

  /// No description provided for @ecoFieldLocationDeniedNotice.
  ///
  /// In es, this message translates to:
  /// **'Ubicación no concedida. Se capturará con GPS vacío.'**
  String get ecoFieldLocationDeniedNotice;

  /// No description provided for @ecoFieldTitle.
  ///
  /// In es, this message translates to:
  /// **'Eco-Field Mode'**
  String get ecoFieldTitle;

  /// No description provided for @ecoFieldSessionPromptTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva sesión de campo'**
  String get ecoFieldSessionPromptTitle;

  /// No description provided for @ecoFieldBatchLabel.
  ///
  /// In es, this message translates to:
  /// **'Batch / Población'**
  String get ecoFieldBatchLabel;

  /// No description provided for @ecoFieldBatchHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: poblacion_norte_01'**
  String get ecoFieldBatchHint;

  /// No description provided for @ecoFieldBatchRequired.
  ///
  /// In es, this message translates to:
  /// **'Introduce un nombre de batch.'**
  String get ecoFieldBatchRequired;

  /// No description provided for @ecoFieldOutputModeLabel.
  ///
  /// In es, this message translates to:
  /// **'Modo de salida'**
  String get ecoFieldOutputModeLabel;

  /// No description provided for @ecoFieldOutputModeAiCrop.
  ///
  /// In es, this message translates to:
  /// **'IA-Crop (Optimizado)'**
  String get ecoFieldOutputModeAiCrop;

  /// No description provided for @ecoFieldOutputModeFullFrame.
  ///
  /// In es, this message translates to:
  /// **'Full-Frame (Original)'**
  String get ecoFieldOutputModeFullFrame;

  /// No description provided for @ecoFieldBlurFilterLabel.
  ///
  /// In es, this message translates to:
  /// **'Filtro de desenfoque (Laplaciana)'**
  String get ecoFieldBlurFilterLabel;

  /// No description provided for @ecoFieldStartSession.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get ecoFieldStartSession;

  /// No description provided for @ecoFieldCancelSession.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get ecoFieldCancelSession;

  /// No description provided for @ecoFieldSessionReady.
  ///
  /// In es, this message translates to:
  /// **'Sesión lista: {session}'**
  String ecoFieldSessionReady(Object session);

  /// No description provided for @ecoFieldAiConfidenceNA.
  ///
  /// In es, this message translates to:
  /// **'NA'**
  String get ecoFieldAiConfidenceNA;

  /// No description provided for @ecoFieldCaptureSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardada: {imageName}'**
  String ecoFieldCaptureSaved(Object imageName);

  /// No description provided for @ecoFieldCaptureSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar captura: {error}'**
  String ecoFieldCaptureSaveError(Object error);

  /// No description provided for @ecoFieldCaptureRejectedNoDetection.
  ///
  /// In es, this message translates to:
  /// **'No se detectó flor con confianza suficiente.'**
  String get ecoFieldCaptureRejectedNoDetection;

  /// No description provided for @ecoFieldCaptureRejectedBlur.
  ///
  /// In es, this message translates to:
  /// **'Captura descartada por desenfoque.'**
  String get ecoFieldCaptureRejectedBlur;

  /// No description provided for @ecoFieldCaptureRejectedCrop.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el recorte IA.'**
  String get ecoFieldCaptureRejectedCrop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'el',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
