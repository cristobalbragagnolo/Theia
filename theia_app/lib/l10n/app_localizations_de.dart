// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nMobiler phänotypischer KI-Workflow. Analyse offline, auf dem Gerät und zugänglich.';

  @override
  String get themeMenuTooltip => 'Thema wählen';

  @override
  String get themeSystem => 'Systemvorgabe';

  @override
  String get themeLight => 'Helles Design';

  @override
  String get themeDark => 'Dunkles Design';

  @override
  String get themeLabel => 'Thema';

  @override
  String get languageMenuTooltip => 'Sprache wählen';

  @override
  String get languageSystem => 'Systemsprache verwenden';

  @override
  String get languageLabel => 'Sprache';

  @override
  String get uiScaleTitle => 'Größe der Oberfläche';

  @override
  String get uiScaleHint => 'Text und Schaltflächen';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Zurücksetzen';

  @override
  String get uiScaleClose => 'Schließen';

  @override
  String get homeLiveButton => 'Live-Modus (Kamera)';

  @override
  String get homeBatchButton => 'Batch-Modus (Galerie)';

  @override
  String get homeDataManagerButton => 'Daten- & Analyse-Manager';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Batch-Modus';

  @override
  String get btnApplyAi => 'KI anwenden';

  @override
  String get btnAddGallery => 'Aus Galerie hinzufügen';

  @override
  String get btnReplaceList => 'Liste ersetzen';

  @override
  String imagesLoaded(int count) {
    return 'Bilder geladen: $count';
  }

  @override
  String get btnClearList => 'Liste leeren';

  @override
  String get sortBy => 'Sortieren nach:';

  @override
  String get sortOriginal => 'Ursprüngliche Reihenfolge';

  @override
  String get sortRejectedFirst => 'Abgelehnte zuerst';

  @override
  String get sortEditedFirst => 'Bearbeitete zuerst';

  @override
  String exportResults(int count) {
    return '($count) Ergebnisse exportieren';
  }

  @override
  String get noExportable =>
      'Keine freigegebenen oder bearbeiteten Ergebnisse zum Export.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Erfolg! \'$fileName\' erstellt mit $count Exemplaren.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Prozess in $time abgeschlossen. $count Bilder verarbeitet.';
  }

  @override
  String get stopProcess => 'Prozess stoppen';

  @override
  String get filterStructural => 'Strukturfilter';

  @override
  String get filterStructuralOn => 'An (Positionen validieren)';

  @override
  String get filterStructuralOff => 'Aus (alle Vorhersagen zulassen)';

  @override
  String get detectionLowConfidence => 'Geringe Erkennungssicherheit.';

  @override
  String rejectionPoints(Object points) {
    return 'Inkonsistente Punkte: $points';
  }

  @override
  String get liveTitle => 'Live-Modus';

  @override
  String liveBatchCount(int count) {
    return 'Satz: $count Exemplare';
  }

  @override
  String snackAddBatch(int count) {
    return 'Exemplar hinzugefügt. Gesamt: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Abgelehnt: $reason. Nicht hinzugefügt.';
  }

  @override
  String get snackDiscarded => 'Ergebnis verworfen.';

  @override
  String get readyNewCapture => 'Bereit für eine neue Aufnahme.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Fehler während der Analyse: $error';
  }

  @override
  String get noSpecimensToExport => 'Keine Exemplare im Satz zum Export.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Erfolg! \'$fileName\' erstellt mit $count Exemplaren.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Exportfehler: $error';
  }

  @override
  String get btnDiscard => 'Verwerfen';

  @override
  String get btnAccept => 'Akzeptieren';

  @override
  String get btnEdit => 'Bearbeiten';

  @override
  String get btnRetake => 'Erneut aufnehmen';

  @override
  String get btnExportBatch => 'Satz exportieren';

  @override
  String get resultRejectedPrefix => 'ABGELEHNT:';

  @override
  String get resultLabel => 'Ergebnis';

  @override
  String get statusApproved => 'Genehmigt';

  @override
  String get statusRejected => 'Abgelehnt';

  @override
  String get statusEdited => 'Bearbeitet';

  @override
  String detailMovingPoint(int index) {
    return 'Punkt $index verschieben';
  }

  @override
  String get detailEditor => 'Editor';

  @override
  String get detailSaveTooltip => 'Änderungen speichern';

  @override
  String get detailSaveSuccess => 'Änderungen gespeichert.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Abgelehnt: $reason';
  }

  @override
  String get detailPrevPoint => 'Vorheriger Punkt';

  @override
  String get detailNextPoint => 'Nächster Punkt';

  @override
  String get detailPrevImage => 'Vorheriges Bild';

  @override
  String get detailNextImage => 'Nächstes Bild';

  @override
  String get dmTitle => 'Datenmanager';

  @override
  String get dmLandmarkFiles => 'Landmarken-Dateien (Eingabe)';

  @override
  String get dmAnalysisFiles => 'Analyse-Dateien (Ergebnisse)';

  @override
  String get dmNoFiles => 'Keine Dateien gefunden.';

  @override
  String get dmDeleteConfirmTitle => 'Löschen bestätigen';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Datei \"$file\" löschen?';
  }

  @override
  String get dmDeleteCancel => 'Abbrechen';

  @override
  String get dmDeleteConfirm => 'Löschen';

  @override
  String get dmDeleteSuccess => 'Datei gelöscht';

  @override
  String dmDeleteError(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get dmAnalyzeButton => 'Landmarken-Datei analysieren';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Analysefehler: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV leer oder nur Kopfzeile.';

  @override
  String get dmNeedThree => 'Mindestens 3 gültige Exemplare erforderlich.';

  @override
  String get cameraLoadError => 'Kamera konnte nicht geladen werden.';

  @override
  String get drawerInfo => 'Information';

  @override
  String get drawerInfoSubtitle => 'Modelldetails und Danksagungen';

  @override
  String get infoPageTitle => 'Information';

  @override
  String get infoModelSection => 'Verwendetes Modell';

  @override
  String get infoThanksSection => 'Danksagungen';

  @override
  String get infoPlaceholder =>
      'Bald fügen wir Details zum Modell und Credits hinzu.';

  @override
  String get infoAcknowledgementsBody =>
      'Die Deep-Learning-Algorithmen in dieser App basieren, wie die Wissenschaft im Allgemeinen, auf der Arbeit derjenigen, die vor uns kamen. Deshalb möchte ich Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares und Andrés Ferreira Rodríguez für ihre Annotationsarbeit und ihre großartige Unterstützung danken.\n\nDiese App wurde mit Liebe, Neugier und viel harter Arbeit erstellt. Daher möchte ich meinen Eltern und meiner Familie danken, die mir diese Werte vermittelt haben.\n\nIch hoffe, dass dieses Tool der wissenschaftlichen Forschung nützt und denjenigen, die nach uns kommen, hilft, noch bessere Dinge zu entdecken und zu erfinden.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Teilen / Exportieren';

  @override
  String get homeEcoFieldButton => 'Eco-Field-Modus';

  @override
  String get homeEcoFieldLockedMessage =>
      'Aktiviere den Eco-Field Mode in den Einstellungen.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Für Feldaufnahme aktiviert';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Deaktiviert. In den Einstellungen aktivieren.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Standort verweigert. Erfassung läuft mit leerem GPS weiter.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Neue Feldsitzung';

  @override
  String get ecoFieldBatchLabel => 'Batch / Population';

  @override
  String get ecoFieldBatchHint => 'z. B. nord_population_01';

  @override
  String get ecoFieldBatchRequired => 'Bitte einen Batch-Namen eingeben.';

  @override
  String get ecoFieldOutputModeLabel => 'Ausgabemodus';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Optimiert)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Original)';

  @override
  String get ecoFieldBlurFilterLabel => 'Unschärfefilter (Laplacian)';

  @override
  String get ecoFieldStartSession => 'Sitzung starten';

  @override
  String get ecoFieldCancelSession => 'Abbrechen';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Sitzung bereit: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Gespeichert: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Blüte nicht mit ausreichender Sicherheit erkannt.';

  @override
  String get ecoFieldCaptureRejectedBlur =>
      'Aufnahme wegen Unschärfe verworfen.';

  @override
  String get ecoFieldCaptureRejectedCrop =>
      'IA-Crop konnte nicht erstellt werden.';

  @override
  String analysisPcaError(Object error) {
    return 'Fehler bei der Berechnung der PCA: $error';
  }

  @override
  String get analysisTitle => 'Analyseergebnisse';

  @override
  String get analysisNavTable => 'Tabelle';

  @override
  String get analysisNavSave => 'Speichern';

  @override
  String get analysisWireframesSection => 'Deformations-Wireframes ±2SD';

  @override
  String get analysisNoComponents =>
      'Hauptkomponenten konnten nicht berechnet werden.';

  @override
  String get analysisScoresSection => 'Score-Tabelle';

  @override
  String get analysisInterpretationSection => 'Interpretation und Speichern';

  @override
  String get analysisInterpretationHint =>
      'z. B. PC1: Kronenöffnung; PC2: Krümmung; PC3: basale Variation...';

  @override
  String get analysisSaveWithInterpretation => 'Mit Interpretation speichern';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Mittelwert · $title';
  }

  @override
  String get analysisNoInterpretation => 'Keine Interpretation';

  @override
  String get analysisCsvHeaderImage => 'Bild';

  @override
  String get analysisCsvHeaderInterpretation => 'Interpretation';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Exportiert: $csvFile und $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Exportiert: $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - Analyse';

  @override
  String get analysisShareText => 'Dateien aus Theia exportiert';

  @override
  String analysisShareError(Object error) {
    return 'Dateien konnten nicht geteilt werden: $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 HCDAI-Hinweis:\nDie Wireframes zeigen hypothetische ±2SD-Verformungen um die Mittelgestalt.\nInterpretiere sie biologisch (Öffnung, Krümmung, Symmetrie) im Vergleich mit realen Exemplaren.';

  @override
  String get morphTitle => 'Morphoraum (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Auswahl aufheben';

  @override
  String get morphAxisLabel => 'PC1 (X-Achse)  /  PC2 (Y-Achse)';

  @override
  String get specimenViewerMean => 'Mittelwert';

  @override
  String get specimenViewerSpecimen => 'Exemplar';

  @override
  String get specimenViewerOverlay => 'Überlagert';

  @override
  String get dmSelectFileFirst => 'Wähle zuerst eine Datei aus.';

  @override
  String dmShareError(Object error) {
    return 'Teilen nicht möglich: $error';
  }

  @override
  String get dmAnalysisJsonNotFound =>
      'Analyse-JSON zum Öffnen nicht gefunden.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'Analyse konnte nicht geöffnet werden: $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Ungültiges JSON-Format';

  @override
  String get dmExpectedJsonObject => 'JSON-Objekt erwartet';

  @override
  String get dmExpectedMatrixList => 'Matrix im Listenformat erwartet';

  @override
  String get dmEmptyMatrix => 'Leere Matrix';

  @override
  String get dmExpectedMatricesList => 'Matrixliste erwartet';
}
