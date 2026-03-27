// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nWorkflow fenotipico IA su mobile. Analisi offline, on-device e accessibile.';

  @override
  String get themeMenuTooltip => 'Seleziona tema';

  @override
  String get themeSystem => 'Segui sistema';

  @override
  String get themeLight => 'Modalità chiara';

  @override
  String get themeDark => 'Modalità scura';

  @override
  String get themeLabel => 'Tema';

  @override
  String get languageMenuTooltip => 'Scegli lingua';

  @override
  String get languageSystem => 'Usa lingua di sistema';

  @override
  String get languageLabel => 'Lingua';

  @override
  String get uiScaleTitle => 'Dimensione interfaccia';

  @override
  String get uiScaleHint => 'testo e pulsanti';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Ripristina';

  @override
  String get uiScaleClose => 'Chiudi';

  @override
  String get homeLiveButton => 'Modalità Live (Fotocamera)';

  @override
  String get homeBatchButton => 'Modalità Batch (Galleria)';

  @override
  String get homeDataManagerButton => 'Gestore Dati e Analisi';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Modalità Batch';

  @override
  String get btnApplyAi => 'Applica IA';

  @override
  String get btnAddGallery => 'Aggiungi dalla Galleria';

  @override
  String get btnReplaceList => 'Sostituisci lista';

  @override
  String imagesLoaded(int count) {
    return 'Immagini caricate: $count';
  }

  @override
  String get btnClearList => 'Svuota lista';

  @override
  String get sortBy => 'Ordina per:';

  @override
  String get sortOriginal => 'Ordine originale';

  @override
  String get sortRejectedFirst => 'Rifiutate per prime';

  @override
  String get sortEditedFirst => 'Modificate per prime';

  @override
  String exportResults(int count) {
    return 'Esporta ($count) risultati';
  }

  @override
  String get noExportable =>
      'Nessun risultato approvato o modificato da esportare.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Successo! \'$fileName\' creato con $count campioni.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Processo terminato in $time. Elaborate $count immagini.';
  }

  @override
  String get stopProcess => 'Ferma processo';

  @override
  String get filterStructural => 'Filtro strutturale';

  @override
  String get filterStructuralOn => 'Attivo (valida le posizioni)';

  @override
  String get filterStructuralOff => 'Spento (tutte le previsioni passano)';

  @override
  String get detectionLowConfidence => 'Bassa confidenza di rilevamento.';

  @override
  String rejectionPoints(Object points) {
    return 'Punti incoerenti: $points';
  }

  @override
  String get liveTitle => 'Modalità Live';

  @override
  String liveBatchCount(int count) {
    return 'Lotto: $count campioni';
  }

  @override
  String snackAddBatch(int count) {
    return 'Campione aggiunto al lotto. Totale: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Rifiutato: $reason. Non aggiunto.';
  }

  @override
  String get snackDiscarded => 'Risultato scartato.';

  @override
  String get readyNewCapture => 'Pronto per una nuova acquisizione.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Errore durante l\'analisi: $error';
  }

  @override
  String get noSpecimensToExport => 'Nessun campione nel lotto da esportare.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Successo! \'$fileName\' creato con $count campioni.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Errore durante l\'esportazione: $error';
  }

  @override
  String get btnDiscard => 'Scarta';

  @override
  String get btnAccept => 'Accetta';

  @override
  String get btnEdit => 'Modifica';

  @override
  String get btnRetake => 'Ripeti';

  @override
  String get btnExportBatch => 'Esporta lotto';

  @override
  String get resultRejectedPrefix => 'RIFIUTATO:';

  @override
  String get resultLabel => 'Risultato';

  @override
  String get statusApproved => 'Approvata';

  @override
  String get statusRejected => 'Rifiutata';

  @override
  String get statusEdited => 'Modificata';

  @override
  String detailMovingPoint(int index) {
    return 'Spostando Punto $index';
  }

  @override
  String get detailEditor => 'Editor';

  @override
  String get detailSaveTooltip => 'Salva modifiche';

  @override
  String get detailSaveSuccess => 'Modifiche salvate.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Rifiutato: $reason';
  }

  @override
  String get detailPrevPoint => 'Punto precedente';

  @override
  String get detailNextPoint => 'Punto successivo';

  @override
  String get detailPrevImage => 'Immagine precedente';

  @override
  String get detailNextImage => 'Immagine successiva';

  @override
  String get dmTitle => 'Gestore Dati';

  @override
  String get dmLandmarkFiles => 'File di landmark (Input)';

  @override
  String get dmAnalysisFiles => 'File di analisi (Risultati)';

  @override
  String get dmNoFiles => 'Nessun file trovato.';

  @override
  String get dmDeleteConfirmTitle => 'Conferma eliminazione';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Vuoi eliminare il file \"$file\"?';
  }

  @override
  String get dmDeleteCancel => 'Annulla';

  @override
  String get dmDeleteConfirm => 'Elimina';

  @override
  String get dmDeleteSuccess => 'File eliminato';

  @override
  String dmDeleteError(Object error) {
    return 'Errore durante l\'eliminazione: $error';
  }

  @override
  String get dmAnalyzeButton => 'Analizza file di landmark';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Errore nell\'analisi: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV vuoto o solo intestazione.';

  @override
  String get dmNeedThree => 'Servono almeno 3 campioni validi.';

  @override
  String get cameraLoadError => 'Errore nel caricamento della fotocamera.';

  @override
  String get drawerInfo => 'Informazioni';

  @override
  String get drawerInfoSubtitle => 'Dettagli sul modello e ringraziamenti';

  @override
  String get infoPageTitle => 'Informazioni';

  @override
  String get infoModelSection => 'Modello in uso';

  @override
  String get infoThanksSection => 'Ringraziamenti';

  @override
  String get infoPlaceholder =>
      'A breve aggiungeremo dettagli sul modello attuale e i crediti.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Condividi / Esporta';

  @override
  String get homeEcoFieldButton => 'Modalità Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Attiva Eco-Field Mode nelle impostazioni per usarla.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled =>
      'Attivata per acquisizione sul campo';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Disattivata. Attivala per usarla dalla Home.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Posizione negata. Le catture continueranno con GPS vuoto.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Nuova sessione sul campo';

  @override
  String get ecoFieldBatchLabel => 'Batch / Popolazione';

  @override
  String get ecoFieldBatchHint => 'Es.: popolazione_nord_01';

  @override
  String get ecoFieldBatchRequired => 'Inserisci un nome batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Modalità di output';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Ottimizzato)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Originale)';

  @override
  String get ecoFieldBlurFilterLabel => 'Filtro sfocatura (Laplaciano)';

  @override
  String get ecoFieldStartSession => 'Avvia sessione';

  @override
  String get ecoFieldCancelSession => 'Annulla';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Sessione pronta: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Salvata: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Errore salvataggio cattura: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Fiore non rilevato con confidenza sufficiente.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Cattura scartata per sfocatura.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'Impossibile generare il crop IA.';
}
