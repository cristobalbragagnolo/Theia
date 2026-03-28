// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nΚινητό φαινοτυπικό AI workflow. Ανάλυση εκτός σύνδεσης, στη συσκευή και προσβάσιμη.';

  @override
  String get themeMenuTooltip => 'Επιλογή θέματος';

  @override
  String get themeSystem => 'Σύστημα';

  @override
  String get themeLight => 'Φωτεινό θέμα';

  @override
  String get themeDark => 'Σκούρο θέμα';

  @override
  String get themeLabel => 'Θέμα';

  @override
  String get languageMenuTooltip => 'Επιλογή γλώσσας';

  @override
  String get languageSystem => 'Γλώσσα συστήματος';

  @override
  String get languageLabel => 'Γλώσσα';

  @override
  String get uiScaleTitle => 'Μέγεθος διεπαφής';

  @override
  String get uiScaleHint => 'κείμενο και κουμπιά';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Επαναφορά';

  @override
  String get uiScaleClose => 'Κλείσιμο';

  @override
  String get homeLiveButton => 'Ζωντανή λειτουργία (Κάμερα)';

  @override
  String get homeBatchButton => 'Λειτουργία παρτίδας (Συλλογή)';

  @override
  String get homeDataManagerButton => 'Διαχειριστής Δεδομένων & Ανάλυσης';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Λειτουργία παρτίδας';

  @override
  String get btnApplyAi => 'Εφαρμογή AI';

  @override
  String get btnAddGallery => 'Προσθήκη από τη συλλογή';

  @override
  String get btnReplaceList => 'Αντικατάσταση λίστας';

  @override
  String imagesLoaded(int count) {
    return 'Φόρτωση εικόνων: $count';
  }

  @override
  String get btnClearList => 'Εκκαθάριση λίστας';

  @override
  String get sortBy => 'Ταξινόμηση κατά:';

  @override
  String get sortOriginal => 'Αρχική σειρά';

  @override
  String get sortRejectedFirst => 'Απορριφθέντα πρώτα';

  @override
  String get sortEditedFirst => 'Επεξεργασμένα πρώτα';

  @override
  String exportResults(int count) {
    return 'Εξαγωγή ($count) αποτελεσμάτων';
  }

  @override
  String get noExportable =>
      'Δεν υπάρχουν εγκεκριμένα ή επεξεργασμένα αποτελέσματα για εξαγωγή.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Επιτυχία! Δημιουργήθηκε το \'$fileName\' με $count δείγματα.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Ολοκληρώθηκε σε $time. Επεξεργάστηκαν $count εικόνες.';
  }

  @override
  String get stopProcess => 'Διακοπή διαδικασίας';

  @override
  String get filterStructural => 'Δομικό φίλτρο';

  @override
  String get filterStructuralOn => 'Ενεργό (επαληθεύει θέσεις)';

  @override
  String get filterStructuralOff => 'Ανενεργό (όλες οι προβλέψεις περνούν)';

  @override
  String get detectionLowConfidence => 'Χαμηλή εμπιστοσύνη ανίχνευσης.';

  @override
  String rejectionPoints(Object points) {
    return 'Ασυνεπή σημεία: $points';
  }

  @override
  String get liveTitle => 'Ζωντανή λειτουργία';

  @override
  String liveBatchCount(int count) {
    return 'Παρτίδα: $count δείγματα';
  }

  @override
  String snackAddBatch(int count) {
    return 'Προστέθηκε δείγμα. Σύνολο: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Απορρίφθηκε: $reason. Δεν προστέθηκε.';
  }

  @override
  String get snackDiscarded => 'Αποτέλεσμα απορρίφθηκε.';

  @override
  String get readyNewCapture => 'Έτοιμο για νέα λήψη.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Σφάλμα κατά την ανάλυση: $error';
  }

  @override
  String get noSpecimensToExport => 'Δεν υπάρχουν δείγματα προς εξαγωγή.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Επιτυχία! Δημιουργήθηκε το \'$fileName\' με $count δείγματα.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Σφάλμα εξαγωγής: $error';
  }

  @override
  String get btnDiscard => 'Απόρριψη';

  @override
  String get btnAccept => 'Αποδοχή';

  @override
  String get btnEdit => 'Επεξεργασία';

  @override
  String get btnRetake => 'Επανάληψη λήψης';

  @override
  String get btnExportBatch => 'Εξαγωγή παρτίδας';

  @override
  String get resultRejectedPrefix => 'ΑΠΟΡΡΙΦΘΗΚΕ:';

  @override
  String get resultLabel => 'Αποτέλεσμα';

  @override
  String get statusApproved => 'Εγκρίθηκε';

  @override
  String get statusRejected => 'Απορρίφθηκε';

  @override
  String get statusEdited => 'Επεξεργάστηκε';

  @override
  String detailMovingPoint(int index) {
    return 'Μετακίνηση σημείου $index';
  }

  @override
  String get detailEditor => 'Επεξεργαστής';

  @override
  String get detailSaveTooltip => 'Αποθήκευση αλλαγών';

  @override
  String get detailSaveSuccess => 'Οι αλλαγές αποθηκεύτηκαν.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Απορρίφθηκε: $reason';
  }

  @override
  String get detailPrevPoint => 'Προηγούμενο σημείο';

  @override
  String get detailNextPoint => 'Επόμενο σημείο';

  @override
  String get detailPrevImage => 'Προηγούμενη εικόνα';

  @override
  String get detailNextImage => 'Επόμενη εικόνα';

  @override
  String get dmTitle => 'Διαχειριστής δεδομένων';

  @override
  String get dmLandmarkFiles => 'Αρχεία landmarks (Είσοδος)';

  @override
  String get dmAnalysisFiles => 'Αρχεία ανάλυσης (Αποτελέσματα)';

  @override
  String get dmNoFiles => 'Δεν βρέθηκαν αρχεία.';

  @override
  String get dmDeleteConfirmTitle => 'Επιβεβαίωση διαγραφής';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Διαγραφή του αρχείου \"$file\";';
  }

  @override
  String get dmDeleteCancel => 'Ακύρωση';

  @override
  String get dmDeleteConfirm => 'Διαγραφή';

  @override
  String get dmDeleteSuccess => 'Το αρχείο διαγράφηκε';

  @override
  String dmDeleteError(Object error) {
    return 'Σφάλμα διαγραφής: $error';
  }

  @override
  String get dmAnalyzeButton => 'Ανάλυση αρχείου landmarks';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Σφάλμα ανάλυσης: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV κενό ή μόνο κεφαλίδα.';

  @override
  String get dmNeedThree => 'Απαιτούνται τουλάχιστον 3 έγκυρα δείγματα.';

  @override
  String get cameraLoadError => 'Αποτυχία φόρτωσης κάμερας.';

  @override
  String get drawerInfo => 'Πληροφορίες';

  @override
  String get drawerInfoSubtitle => 'Λεπτομέρειες μοντέλου και ευχαριστίες';

  @override
  String get infoPageTitle => 'Πληροφορίες';

  @override
  String get infoModelSection => 'Μοντέλο σε χρήση';

  @override
  String get infoThanksSection => 'Ευχαριστίες';

  @override
  String get infoPlaceholder =>
      'Σύντομα θα προσθέσουμε λεπτομέρειες για το μοντέλο και τις αναφορές.';

  @override
  String get infoAcknowledgementsBody =>
      'Οι αλγόριθμοι deep learning σε αυτή την εφαρμογή, όπως και η επιστήμη γενικά, βασίζονται στο έργο όσων προηγήθηκαν από εμάς. Για αυτόν τον λόγο, θα ήθελα να ευχαριστήσω τους Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares και Andrés Ferreira Rodríguez για το έργο τους στην επισήμανση και την απίστευτη υποστήριξή τους.\n\nΑυτή η εφαρμογή δημιουργήθηκε με αγάπη, περιέργεια και πολλή δουλειά. Γι’ αυτό θέλω να εκφράσω την ευγνωμοσύνη μου στους γονείς και την οικογένειά μου που μου δίδαξαν αυτές τις αξίες.\n\nΕλπίζω αυτό το εργαλείο να αποδειχθεί χρήσιμο για την επιστημονική έρευνα και να βοηθήσει όσους έρθουν μετά από εμάς να ανακαλύψουν και να επινοήσουν ακόμη καλύτερα πράγματα.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Κοινοποίηση / Εξαγωγή';

  @override
  String get homeEcoFieldButton => 'Λειτουργία Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Ενεργοποιήστε το Eco-Field Mode από τις ρυθμίσεις.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Ενεργό για καταγραφή πεδίου';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Ανενεργό. Ενεργοποιήστε το από την αρχική οθόνη.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Η τοποθεσία απορρίφθηκε. Η λήψη θα συνεχίσει με κενό GPS.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Νέα συνεδρία πεδίου';

  @override
  String get ecoFieldBatchLabel => 'Batch / Πληθυσμός';

  @override
  String get ecoFieldBatchHint => 'π.χ. north_population_01';

  @override
  String get ecoFieldBatchRequired => 'Δώστε όνομα batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Λειτουργία εξόδου';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Βελτιστοποιημένο)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Αρχικό)';

  @override
  String get ecoFieldBlurFilterLabel => 'Φίλτρο θόλωσης (Laplacian)';

  @override
  String get ecoFieldStartSession => 'Έναρξη συνεδρίας';

  @override
  String get ecoFieldCancelSession => 'Ακύρωση';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Η συνεδρία είναι έτοιμη: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Αποθηκεύτηκε: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Σφάλμα αποθήκευσης: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Το άνθος δεν ανιχνεύτηκε με επαρκή βεβαιότητα.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Η λήψη απορρίφθηκε λόγω θόλωσης.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'Αδυναμία δημιουργίας IA crop.';

  @override
  String analysisPcaError(Object error) {
    return 'Σφάλμα κατά τον υπολογισμό του PCA: $error';
  }

  @override
  String get analysisTitle => 'Αποτελέσματα ανάλυσης';

  @override
  String get analysisNavTable => 'Πίνακας';

  @override
  String get analysisNavSave => 'Αποθήκευση';

  @override
  String get analysisWireframesSection => 'Wireframes παραμόρφωσης ±2ΤΑ';

  @override
  String get analysisNoComponents =>
      'Δεν ήταν δυνατός ο υπολογισμός των κύριων συνιστωσών.';

  @override
  String get analysisScoresSection => 'Πίνακας βαθμολογιών';

  @override
  String get analysisInterpretationSection => 'Ερμηνεία και αποθήκευση';

  @override
  String get analysisInterpretationHint =>
      'π.χ.: PC1: άνοιγμα στεφάνης· PC2: καμπυλότητα· PC3: βασική μεταβολή...';

  @override
  String get analysisSaveWithInterpretation => 'Αποθήκευση με ερμηνεία';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Μέσος όρος · $title';
  }

  @override
  String get analysisNoInterpretation => 'Χωρίς ερμηνεία';

  @override
  String get analysisCsvHeaderImage => 'Εικόνα';

  @override
  String get analysisCsvHeaderInterpretation => 'Ερμηνεία';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Εξήχθησαν: $csvFile και $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Εξήχθη: $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - ανάλυση';

  @override
  String get analysisShareText => 'Αρχεία που εξήχθησαν από το Theia';

  @override
  String analysisShareError(Object error) {
    return 'Δεν ήταν δυνατή η κοινοποίηση των αρχείων: $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 Σημείωση HCDAI:\nΤα wireframes δείχνουν υποθετικές παραμορφώσεις ±2ΤΑ πάνω στο μέσο σχήμα.\nΕρμηνεύστε τις βιολογικά (άνοιγμα, καμπυλότητα, συμμετρία) συγκρίνοντας με πραγματικά δείγματα.';

  @override
  String get morphTitle => 'Μορφόχωρος (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Καθαρισμός επιλογής';

  @override
  String get morphAxisLabel => 'PC1 (Άξονας X)  /  PC2 (Άξονας Y)';

  @override
  String get specimenViewerMean => 'Μέσος όρος';

  @override
  String get specimenViewerSpecimen => 'Δείγμα';

  @override
  String get specimenViewerOverlay => 'Επικάλυψη';

  @override
  String get dmSelectFileFirst => 'Επίλεξε πρώτα ένα αρχείο.';

  @override
  String dmShareError(Object error) {
    return 'Δεν ήταν δυνατή η κοινοποίηση: $error';
  }

  @override
  String get dmAnalysisJsonNotFound => 'Δεν βρέθηκε JSON ανάλυσης για άνοιγμα.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'Δεν ήταν δυνατό το άνοιγμα της ανάλυσης: $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Μη έγκυρη μορφή JSON';

  @override
  String get dmExpectedJsonObject => 'Αναμενόταν αντικείμενο JSON';

  @override
  String get dmExpectedMatrixList => 'Αναμενόταν μήτρα σε μορφή λίστας';

  @override
  String get dmEmptyMatrix => 'Κενή μήτρα';

  @override
  String get dmExpectedMatricesList => 'Αναμενόταν λίστα από μήτρες';
}
