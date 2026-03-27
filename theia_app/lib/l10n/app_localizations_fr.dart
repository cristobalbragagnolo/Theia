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
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

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
}
