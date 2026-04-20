// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nWorkflow phénotypique IA mobile. Analyse hors ligne, sur l\'appareil et accessible.';

  @override
  String get themeMenuTooltip => 'Choisir le thème';

  @override
  String get themeSystem => 'Suivre le système';

  @override
  String get themeLight => 'Mode clair';

  @override
  String get themeDark => 'Mode sombre';

  @override
  String get themeLabel => 'Thème';

  @override
  String get languageMenuTooltip => 'Choisir la langue';

  @override
  String get languageSystem => 'Utiliser la langue du système';

  @override
  String get languageLabel => 'Langue';

  @override
  String get uiScaleTitle => 'Taille de l\'interface';

  @override
  String get uiScaleHint => 'texte et boutons';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Réinitialiser';

  @override
  String get uiScaleClose => 'Fermer';

  @override
  String get homeLiveButton => 'Mode Live (Caméra)';

  @override
  String get homeBatchButton => 'Mode Batch (Galerie)';

  @override
  String get homeDataManagerButton => 'Gestionnaire de données et d\'analyses';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Mode Batch';

  @override
  String get btnApplyAi => 'Appliquer l\'IA';

  @override
  String get btnAddGallery => 'Ajouter depuis la galerie';

  @override
  String get btnReplaceList => 'Remplacer la liste';

  @override
  String imagesLoaded(int count) {
    return 'Images chargées : $count';
  }

  @override
  String get btnClearList => 'Vider la liste';

  @override
  String get sortBy => 'Trier par :';

  @override
  String get sortOriginal => 'Ordre original';

  @override
  String get sortRejectedFirst => 'Rejetées en premier';

  @override
  String get sortEditedFirst => 'Modifiées en premier';

  @override
  String exportResults(int count) {
    return 'Exporter ($count) résultats';
  }

  @override
  String get noExportable => 'Aucun résultat approuvé ou modifié à exporter.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Succès ! \'$fileName\' créé avec $count spécimens.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Processus terminé en $time. $count images traitées.';
  }

  @override
  String get stopProcess => 'Arrêter le processus';

  @override
  String get filterStructural => 'Filtre structurel';

  @override
  String get filterStructuralOn => 'Activé (valide les positions)';

  @override
  String get filterStructuralOff =>
      'Désactivé (toutes les prédictions passent)';

  @override
  String get detectionLowConfidence => 'Faible confiance de détection.';

  @override
  String rejectionPoints(Object points) {
    return 'Point(s) incohérent(s) : $points';
  }

  @override
  String get liveTitle => 'Mode Live';

  @override
  String liveBatchCount(int count) {
    return 'Lot : $count spécimens';
  }

  @override
  String snackAddBatch(int count) {
    return 'Spécimen ajouté. Total : $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Rejeté : $reason. Non ajouté.';
  }

  @override
  String get snackDiscarded => 'Résultat supprimé.';

  @override
  String get readyNewCapture => 'Prêt pour une nouvelle capture.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Erreur pendant l\'analyse : $error';
  }

  @override
  String get noSpecimensToExport => 'Aucun spécimen dans le lot à exporter.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Succès ! \'$fileName\' créé avec $count spécimens.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Erreur d\'exportation : $error';
  }

  @override
  String get btnDiscard => 'Supprimer';

  @override
  String get btnAccept => 'Accepter';

  @override
  String get btnEdit => 'Modifier';

  @override
  String get btnRetake => 'Reprendre';

  @override
  String get btnExportBatch => 'Exporter le lot';

  @override
  String get resultRejectedPrefix => 'REJETÉ :';

  @override
  String get resultLabel => 'Résultat';

  @override
  String get statusApproved => 'Approuvée';

  @override
  String get statusRejected => 'Rejetée';

  @override
  String get statusEdited => 'Modifiée';

  @override
  String detailMovingPoint(int index) {
    return 'Déplacement du point $index';
  }

  @override
  String get detailEditor => 'Éditeur';

  @override
  String get detailSaveTooltip => 'Enregistrer les modifications';

  @override
  String get detailSaveSuccess => 'Modifications enregistrées.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Rejeté : $reason';
  }

  @override
  String get detailPrevPoint => 'Point précédent';

  @override
  String get detailNextPoint => 'Point suivant';

  @override
  String get detailPrevImage => 'Image précédente';

  @override
  String get detailNextImage => 'Image suivante';

  @override
  String get dmTitle => 'Gestionnaire de données';

  @override
  String get dmLandmarkFiles => 'Fichiers de points de repère (Entrée)';

  @override
  String get dmAnalysisFiles => 'Fichiers d\'analyse (Résultats)';

  @override
  String get dmNoFiles => 'Aucun fichier trouvé.';

  @override
  String get dmDeleteConfirmTitle => 'Confirmer la suppression';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Supprimer le fichier \"$file\" ?';
  }

  @override
  String get dmDeleteCancel => 'Annuler';

  @override
  String get dmDeleteConfirm => 'Supprimer';

  @override
  String get dmDeleteSuccess => 'Fichier supprimé';

  @override
  String dmDeleteError(Object error) {
    return 'Erreur de suppression : $error';
  }

  @override
  String get dmAnalyzeButton => 'Analyser le fichier de points';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Erreur d\'analyse : $error';
  }

  @override
  String get dmCsvEmpty => 'CSV vide ou seulement l\'en-tête.';

  @override
  String get dmNeedThree => 'Au moins 3 spécimens valides sont requis.';

  @override
  String get cameraLoadError => 'Échec du chargement de la caméra.';

  @override
  String get drawerInfo => 'Information';

  @override
  String get drawerInfoSubtitle => 'Détails du modèle et remerciements';

  @override
  String get infoPageTitle => 'Information';

  @override
  String get infoModelSection => 'Modèle utilisé';

  @override
  String get infoThanksSection => 'Remerciements';

  @override
  String get infoPlaceholder =>
      'Nous ajouterons bientôt des détails sur le modèle et les crédits.';

  @override
  String get infoAcknowledgementsBody =>
      'Les algorithmes de deep learning de cette application, comme la science en général, reposent sur le travail de celles et ceux qui nous ont précédés. C’est pourquoi je tiens à remercier -, - et - pour leur travail d’annotation et leur formidable soutien.\n\nCette application a été créée avec amour, curiosité et beaucoup de travail. Je souhaite donc remercier mes parents et ma famille de m’avoir transmis ces valeurs.\n\nJ’espère que cet outil sera utile à la recherche scientifique et aidera celles et ceux qui viendront après nous à découvrir et inventer des choses encore meilleures.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Partager / Exporter';

  @override
  String get homeEcoFieldButton => 'Mode Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Activez Eco-Field Mode dans les paramètres pour l\'utiliser.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled =>
      'Activé pour la capture terrain';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Désactivé. Activez-le pour l\'utiliser depuis l\'accueil.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Position refusée. Les captures continueront avec GPS vide.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Nouvelle session terrain';

  @override
  String get ecoFieldBatchLabel => 'Batch / Population';

  @override
  String get ecoFieldBatchHint => 'Ex. : population_nord_01';

  @override
  String get ecoFieldBatchRequired => 'Saisissez un nom de batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Mode de sortie';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Optimisé)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Original)';

  @override
  String get ecoFieldBlurFilterLabel => 'Filtre de flou (Laplacien)';

  @override
  String get ecoFieldStartSession => 'Démarrer la session';

  @override
  String get ecoFieldCancelSession => 'Annuler';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Session prête : $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Enregistrée : $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Erreur d\'enregistrement : $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Fleur non détectée avec une confiance suffisante.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Capture rejetée pour flou.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'Impossible de générer le crop IA.';

  @override
  String analysisPcaError(Object error) {
    return 'Erreur lors du calcul de l’ACP : $error';
  }

  @override
  String get analysisTitle => 'Résultats de l’analyse';

  @override
  String get analysisNavTable => 'Tableau';

  @override
  String get analysisNavSave => 'Enregistrer';

  @override
  String get analysisWireframesSection => 'Wireframes de déformation ±2ET';

  @override
  String get analysisNoComponents =>
      'Impossible de calculer les composantes principales.';

  @override
  String get analysisScoresSection => 'Tableau des scores';

  @override
  String get analysisInterpretationSection =>
      'Interprétation et enregistrement';

  @override
  String get analysisInterpretationHint =>
      'ex. : PC1 : ouverture corollaire ; PC2 : courbure ; PC3 : variation basale...';

  @override
  String get analysisSaveWithInterpretation =>
      'Enregistrer avec interprétation';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Moyenne · $title';
  }

  @override
  String get analysisNoInterpretation => 'Sans interprétation';

  @override
  String get analysisCsvHeaderImage => 'Image';

  @override
  String get analysisCsvHeaderInterpretation => 'Interprétation';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Exportés : $csvFile et $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Exporté : $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - analyse';

  @override
  String get analysisShareText => 'Fichiers exportés depuis Theia';

  @override
  String analysisShareError(Object error) {
    return 'Impossible de partager les fichiers : $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 Note HCDAI :\nLes wireframes montrent des déformations hypothétiques ±2ET autour de la forme moyenne.\nInterprétez-les biologiquement (ouverture, courbure, symétrie) en les comparant à des spécimens réels.';

  @override
  String get morphTitle => 'Morphoespace (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Effacer la sélection';

  @override
  String get morphAxisLabel => 'PC1 (Axe X)  /  PC2 (Axe Y)';

  @override
  String get specimenViewerMean => 'Moyenne';

  @override
  String get specimenViewerSpecimen => 'Spécimen';

  @override
  String get specimenViewerOverlay => 'Superposition';

  @override
  String get dmSelectFileFirst => 'Sélectionnez d’abord un fichier.';

  @override
  String dmShareError(Object error) {
    return 'Partage impossible : $error';
  }

  @override
  String get dmAnalysisJsonNotFound =>
      'JSON d’analyse introuvable pour ouverture.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'Impossible d’ouvrir l’analyse : $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Format JSON invalide';

  @override
  String get dmExpectedJsonObject => 'Objet JSON attendu';

  @override
  String get dmExpectedMatrixList => 'Matrice attendue au format liste';

  @override
  String get dmEmptyMatrix => 'Matrice vide';

  @override
  String get dmExpectedMatricesList => 'Liste de matrices attendue';
}
