// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nMobile phenotypic AI workflow. Offline, on-device, and accessible analysis.';

  @override
  String get themeMenuTooltip => 'Select theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeLabel => 'Theme';

  @override
  String get languageMenuTooltip => 'Choose language';

  @override
  String get languageSystem => 'Use system language';

  @override
  String get languageLabel => 'Language';

  @override
  String get uiScaleTitle => 'Interface size';

  @override
  String get uiScaleHint => 'text and buttons';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Reset';

  @override
  String get uiScaleClose => 'Close';

  @override
  String get homeLiveButton => 'Live Mode (Camera)';

  @override
  String get homeBatchButton => 'Batch Mode (Gallery)';

  @override
  String get homeDataManagerButton => 'Data & Analysis Manager';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Batch Mode';

  @override
  String get btnApplyAi => 'Apply AI';

  @override
  String get btnAddGallery => 'Add from Gallery';

  @override
  String get btnReplaceList => 'Replace List';

  @override
  String imagesLoaded(int count) {
    return 'Images loaded: $count';
  }

  @override
  String get btnClearList => 'Clear List';

  @override
  String get sortBy => 'Sort by:';

  @override
  String get sortOriginal => 'Original order';

  @override
  String get sortRejectedFirst => 'Rejected first';

  @override
  String get sortEditedFirst => 'Edited first';

  @override
  String exportResults(int count) {
    return 'Export ($count) Results';
  }

  @override
  String get noExportable => 'No approved or edited results to export.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Success! \'$fileName\' created with $count specimens.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Process finished in $time. $count images processed.';
  }

  @override
  String get stopProcess => 'Stop Process';

  @override
  String get filterStructural => 'Structural filter';

  @override
  String get filterStructuralOn => 'On (validates positions)';

  @override
  String get filterStructuralOff => 'Off (all predictions pass)';

  @override
  String get detectionLowConfidence => 'Low detection confidence.';

  @override
  String rejectionPoints(Object points) {
    return 'Inconsistent point(s): $points';
  }

  @override
  String get liveTitle => 'Live Mode';

  @override
  String liveBatchCount(int count) {
    return 'Batch: $count specimens';
  }

  @override
  String snackAddBatch(int count) {
    return 'Specimen added. Total: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Rejected: $reason. Not added.';
  }

  @override
  String get snackDiscarded => 'Result discarded.';

  @override
  String get readyNewCapture => 'Ready for a new capture.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Error during analysis: $error';
  }

  @override
  String get noSpecimensToExport => 'No specimens in the batch to export.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Success! \'$fileName\' created with $count specimens.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Export error: $error';
  }

  @override
  String get btnDiscard => 'Discard';

  @override
  String get btnAccept => 'Accept';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnRetake => 'Retake';

  @override
  String get btnExportBatch => 'Export Batch';

  @override
  String get resultRejectedPrefix => 'REJECTED:';

  @override
  String get resultLabel => 'Result';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusEdited => 'Edited';

  @override
  String detailMovingPoint(int index) {
    return 'Moving Point $index';
  }

  @override
  String get detailEditor => 'Editor';

  @override
  String get detailSaveTooltip => 'Save Changes';

  @override
  String get detailSaveSuccess => 'Changes saved.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Rejected: $reason';
  }

  @override
  String get detailPrevPoint => 'Previous Point';

  @override
  String get detailNextPoint => 'Next Point';

  @override
  String get detailPrevImage => 'Previous image';

  @override
  String get detailNextImage => 'Next image';

  @override
  String get dmTitle => 'Data Manager';

  @override
  String get dmLandmarkFiles => 'Landmark files (Input)';

  @override
  String get dmAnalysisFiles => 'Analysis files (Results)';

  @override
  String get dmNoFiles => 'No files found.';

  @override
  String get dmDeleteConfirmTitle => 'Confirm delete';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Delete file \"$file\"?';
  }

  @override
  String get dmDeleteCancel => 'Cancel';

  @override
  String get dmDeleteConfirm => 'Delete';

  @override
  String get dmDeleteSuccess => 'File deleted';

  @override
  String dmDeleteError(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get dmAnalyzeButton => 'Analyze landmark file';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Analysis error: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV empty or header only.';

  @override
  String get dmNeedThree => 'At least 3 valid specimens are required.';

  @override
  String get cameraLoadError => 'Camera failed to load.';

  @override
  String get drawerInfo => 'Information';

  @override
  String get drawerInfoSubtitle => 'Model details and acknowledgements';

  @override
  String get infoPageTitle => 'Information';

  @override
  String get infoModelSection => 'Model in use';

  @override
  String get infoThanksSection => 'Acknowledgements';

  @override
  String get infoPlaceholder =>
      'We will soon add details about the current model and credits.';

  @override
  String get infoAcknowledgementsBody =>
      'The deep learning algorithms in this app, much like science in general, are built upon the work of those who came before us. For this reason, I would like to thank -, -, and - for their annotation work and incredible support.\n\nThis app was created with love, curiosity, and a lot of hard work. Therefore, I want to express my gratitude to my parents and family for teaching me these values.\n\nI hope this tool proves useful for scientific research and helps those who come after us to discover and invent even better things.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Share / Export';

  @override
  String get homeEcoFieldButton => 'Eco-Field Mode';

  @override
  String get homeEcoFieldLockedMessage =>
      'Enable Eco-Field Mode in Settings to use it.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Enabled for field capture';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Disabled. Enable it to use from Home.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Location denied. Captures will continue with empty GPS fields.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'New field session';

  @override
  String get ecoFieldBatchLabel => 'Batch / Population';

  @override
  String get ecoFieldBatchHint => 'e.g. north_population_01';

  @override
  String get ecoFieldBatchRequired => 'Please provide a batch name.';

  @override
  String get ecoFieldOutputModeLabel => 'Output mode';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Optimized)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Original)';

  @override
  String get ecoFieldBlurFilterLabel => 'Blur filter (Laplacian)';

  @override
  String get ecoFieldStartSession => 'Start session';

  @override
  String get ecoFieldCancelSession => 'Cancel';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Session ready: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Saved: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Capture save error: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Flower not detected with enough confidence.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Capture discarded due to blur.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'Unable to generate AI crop.';

  @override
  String analysisPcaError(Object error) {
    return 'Error calculating PCA: $error';
  }

  @override
  String get analysisTitle => 'Analysis Results';

  @override
  String get analysisNavTable => 'Table';

  @override
  String get analysisNavSave => 'Save';

  @override
  String get analysisWireframesSection => 'Deformation wireframes ±2SD';

  @override
  String get analysisNoComponents =>
      'Unable to calculate principal components.';

  @override
  String get analysisScoresSection => 'Scores Table';

  @override
  String get analysisInterpretationSection => 'Interpretation and save';

  @override
  String get analysisInterpretationHint =>
      'e.g. PC1: corolla opening; PC2: curvature; PC3: basal variation...';

  @override
  String get analysisSaveWithInterpretation => 'Save with interpretation';

  @override
  String analysisWireframeMeanLabel(Object title) {
    return 'Mean · $title';
  }

  @override
  String get analysisNoInterpretation => 'No interpretation';

  @override
  String get analysisCsvHeaderImage => 'Image';

  @override
  String get analysisCsvHeaderInterpretation => 'Interpretation';

  @override
  String analysisExportedBoth(Object csvFile, Object jsonFile) {
    return 'Exported: $csvFile and $jsonFile';
  }

  @override
  String analysisExportedSingle(Object csvFile) {
    return 'Exported: $csvFile';
  }

  @override
  String get analysisShareSubject => 'Edge AI Morphometrics - analysis';

  @override
  String get analysisShareText => 'Files exported from Theia';

  @override
  String analysisShareError(Object error) {
    return 'Could not share files: $error';
  }

  @override
  String get analysisHcdaiNote =>
      '🧠 HCDAI Note:\nWireframes show hypothetical ±2SD deformations over the mean shape.\nInterpret them biologically (opening, curvature, symmetry) by comparing with real specimens.';

  @override
  String get morphTitle => 'Morphospace (PC1 vs PC2)';

  @override
  String get morphClearSelectionTooltip => 'Clear selection';

  @override
  String get morphAxisLabel => 'PC1 (X Axis)  /  PC2 (Y Axis)';

  @override
  String get specimenViewerMean => 'Mean';

  @override
  String get specimenViewerSpecimen => 'Specimen';

  @override
  String get specimenViewerOverlay => 'Overlay';

  @override
  String get dmSelectFileFirst => 'Select a file first.';

  @override
  String dmShareError(Object error) {
    return 'Could not share: $error';
  }

  @override
  String get dmAnalysisJsonNotFound => 'Analysis JSON was not found to open.';

  @override
  String dmOpenAnalysisError(Object error) {
    return 'Could not open analysis: $error';
  }

  @override
  String get dmInvalidJsonFormat => 'Invalid JSON format';

  @override
  String get dmExpectedJsonObject => 'Expected a JSON object';

  @override
  String get dmExpectedMatrixList => 'Expected matrix in list format';

  @override
  String get dmEmptyMatrix => 'Empty matrix';

  @override
  String get dmExpectedMatricesList => 'Expected list of matrices';
}
