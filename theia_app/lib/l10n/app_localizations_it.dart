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
      'Gli algoritmi di deep learning di questa app, come la scienza in generale, si basano sul lavoro di chi è venuto prima di noi. Per questo desidero ringraziare -, - e - per il loro lavoro di annotazione e il loro incredibile supporto.\n\nQuesta app è stata creata con amore, curiosità e molto impegno. Per questo voglio ringraziare i miei genitori e la mia famiglia per avermi trasmesso questi valori.\n\nSpero che questo strumento sia utile alla ricerca scientifica e aiuti chi verrà dopo di noi a scoprire e inventare cose ancora migliori.';

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

  @override
  String analysisPcaError(Object error) {
    return 'Errore nel calcolo della PCA: $error';
  }

  @override
  String get analysisTitle => 'Risultati dell’analisi';

  @override
  String get analysisNavTable => 'Tabella';

  @override
  String get analysisNavSave => 'Salva';

  @override
  String get analysisWireframesSection => 'Wireframe di deformazione ±2DS';

  @override
  String get analysisNoComponents =>
      'Impossibile calcolare le componenti principali.';

  @override
  String get analysisScoresSection => 'Tabella dei punteggi';

  @override
  String get analysisInterpretationSection => 'Interpretazione e salvataggio';

  @override
  String get analysisInterpretationHint =>
      'es.: PC1: apertura corollina; PC2: curvatura; PC3: variazione basale...';

  @override
  String get analysisSaveWithInterpretation => 'Salva con interpretazione';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Media · $title';
  }

  @override
  String get analysisNoInterpretation => 'Senza interpretazione';

  @override
  String get analysisCsvHeaderImage => 'Immagine';

  @override
  String get analysisCsvHeaderInterpretation => 'Interpretazione';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Esportati: $csvFile e $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Esportato: $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - analisi';

  @override
  String get analysisShareText => 'File esportati da Theia';

  @override
  String analysisShareError(Object error) {
    return 'Impossibile condividere i file: $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 Nota HCDAI:\nI wireframe mostrano deformazioni ipotetiche ±2DS sulla forma media.\nInterpretale biologicamente (apertura, curvatura, simmetria) confrontandole con esemplari reali.';

  @override
  String get morphTitle => 'Morfospazio (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Cancella selezione';

  @override
  String get morphAxisLabel => 'PC1 (Asse X)  /  PC2 (Asse Y)';

  @override
  String get specimenViewerMean => 'Media';

  @override
  String get specimenViewerSpecimen => 'Esemplare';

  @override
  String get specimenViewerOverlay => 'Sovrapposti';

  @override
  String get dmSelectFileFirst => 'Seleziona prima un file.';

  @override
  String dmShareError(Object error) {
    return 'Impossibile condividere: $error';
  }

  @override
  String get dmAnalysisJsonNotFound =>
      'JSON dell’analisi non trovato per l’apertura.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'Impossibile aprire l’analisi: $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Formato JSON non valido';

  @override
  String get dmExpectedJsonObject => 'Oggetto JSON previsto';

  @override
  String get dmExpectedMatrixList => 'Matrice prevista in formato lista';

  @override
  String get dmEmptyMatrix => 'Matrice vuota';

  @override
  String get dmExpectedMatricesList => 'Previsto un elenco di matrici';
}
