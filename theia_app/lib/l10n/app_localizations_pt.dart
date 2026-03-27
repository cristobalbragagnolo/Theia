// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nFluxo de IA fenotípica móvel. Análise offline, no dispositivo e acessível.';

  @override
  String get themeMenuTooltip => 'Escolher tema';

  @override
  String get themeSystem => 'Seguir sistema';

  @override
  String get themeLight => 'Modo claro';

  @override
  String get themeDark => 'Modo escuro';

  @override
  String get themeLabel => 'Tema';

  @override
  String get languageMenuTooltip => 'Escolher idioma';

  @override
  String get languageSystem => 'Usar idioma do sistema';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get uiScaleTitle => 'Tamanho da interface';

  @override
  String get uiScaleHint => 'texto e botões';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Restaurar';

  @override
  String get uiScaleClose => 'Fechar';

  @override
  String get homeLiveButton => 'Modo Live (Câmera)';

  @override
  String get homeBatchButton => 'Modo Batch (Galeria)';

  @override
  String get homeDataManagerButton => 'Gestor de Dados e Análises';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Modo Batch';

  @override
  String get btnApplyAi => 'Aplicar IA';

  @override
  String get btnAddGallery => 'Adicionar da Galeria';

  @override
  String get btnReplaceList => 'Substituir Lista';

  @override
  String imagesLoaded(int count) {
    return 'Imagens carregadas: $count';
  }

  @override
  String get btnClearList => 'Limpar Lista';

  @override
  String get sortBy => 'Ordenar por:';

  @override
  String get sortOriginal => 'Ordem original';

  @override
  String get sortRejectedFirst => 'Rejeitadas primeiro';

  @override
  String get sortEditedFirst => 'Editadas primeiro';

  @override
  String exportResults(int count) {
    return 'Exportar ($count) Resultados';
  }

  @override
  String get noExportable =>
      'Não há resultados aprovados ou editados para exportar.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Sucesso! \'$fileName\' criado com $count espécimes.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Processo finalizado em $time. $count imagens processadas.';
  }

  @override
  String get stopProcess => 'Parar processo';

  @override
  String get filterStructural => 'Filtro estrutural';

  @override
  String get filterStructuralOn => 'Ativado (valida posições)';

  @override
  String get filterStructuralOff => 'Desligado (todas as previsões passam)';

  @override
  String get detectionLowConfidence => 'Baixa confiança de detecção.';

  @override
  String rejectionPoints(Object points) {
    return 'Inconsistência no(s) ponto(s): $points';
  }

  @override
  String get liveTitle => 'Modo Live';

  @override
  String liveBatchCount(int count) {
    return 'Lote: $count espécimes';
  }

  @override
  String snackAddBatch(int count) {
    return 'Espécime adicionado ao lote. Total: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Rejeitado: $reason. Não adicionado.';
  }

  @override
  String get snackDiscarded => 'Resultado descartado.';

  @override
  String get readyNewCapture => 'Pronto para uma nova captura.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Erro durante a análise: $error';
  }

  @override
  String get noSpecimensToExport => 'Não há espécimes no lote para exportar.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Sucesso! \'$fileName\' criado com $count espécimes.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String get btnDiscard => 'Descartar';

  @override
  String get btnAccept => 'Aceitar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnRetake => 'Repetir';

  @override
  String get btnExportBatch => 'Exportar Lote';

  @override
  String get resultRejectedPrefix => 'REJEITADO:';

  @override
  String get resultLabel => 'Resultado';

  @override
  String get statusApproved => 'Aprovada';

  @override
  String get statusRejected => 'Rejeitada';

  @override
  String get statusEdited => 'Editada';

  @override
  String detailMovingPoint(int index) {
    return 'Movendo Ponto $index';
  }

  @override
  String get detailEditor => 'Editor';

  @override
  String get detailSaveTooltip => 'Salvar Alterações';

  @override
  String get detailSaveSuccess => 'Alterações salvas.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Rejeitado: $reason';
  }

  @override
  String get detailPrevPoint => 'Ponto Anterior';

  @override
  String get detailNextPoint => 'Próximo Ponto';

  @override
  String get detailPrevImage => 'Imagem anterior';

  @override
  String get detailNextImage => 'Próxima imagem';

  @override
  String get dmTitle => 'Gestor de Dados';

  @override
  String get dmLandmarkFiles => 'Arquivos de Landmarks (Entrada)';

  @override
  String get dmAnalysisFiles => 'Arquivos de Análises (Resultados)';

  @override
  String get dmNoFiles => 'Nenhum arquivo encontrado.';

  @override
  String get dmDeleteConfirmTitle => 'Confirmar exclusão';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Deseja excluir o arquivo \"$file\"?';
  }

  @override
  String get dmDeleteCancel => 'Cancelar';

  @override
  String get dmDeleteConfirm => 'Excluir';

  @override
  String get dmDeleteSuccess => 'Arquivo excluído';

  @override
  String dmDeleteError(Object error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String get dmAnalyzeButton => 'Analisar arquivo de landmarks';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Erro na análise: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV vazio ou apenas cabeçalho.';

  @override
  String get dmNeedThree => 'São necessários pelo menos 3 espécimes válidos.';

  @override
  String get cameraLoadError => 'Erro ao carregar a câmera.';

  @override
  String get drawerInfo => 'Informações';

  @override
  String get drawerInfoSubtitle => 'Detalhes do modelo e agradecimentos';

  @override
  String get infoPageTitle => 'Informações';

  @override
  String get infoModelSection => 'Modelo em uso';

  @override
  String get infoThanksSection => 'Agradecimentos';

  @override
  String get infoPlaceholder =>
      'Em breve adicionaremos detalhes do modelo atual e créditos.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Compartilhar / Exportar';

  @override
  String get homeEcoFieldButton => 'Modo Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Ative o Eco-Field Mode nas configurações para usar.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Ativado para captura em campo';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Desativado. Ative para usar na Home.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Localização negada. Capturas continuarão com GPS vazio.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Nova sessão de campo';

  @override
  String get ecoFieldBatchLabel => 'Batch / População';

  @override
  String get ecoFieldBatchHint => 'Ex.: populacao_norte_01';

  @override
  String get ecoFieldBatchRequired => 'Informe um nome de batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Modo de saída';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Otimizado)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Original)';

  @override
  String get ecoFieldBlurFilterLabel => 'Filtro de desfoque (Laplaciano)';

  @override
  String get ecoFieldStartSession => 'Iniciar sessão';

  @override
  String get ecoFieldCancelSession => 'Cancelar';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Sessão pronta: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Salva: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Erro ao salvar captura: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Flor não detectada com confiança suficiente.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Captura descartada por desfoque.';

  @override
  String get ecoFieldCaptureRejectedCrop =>
      'Não foi possível gerar o recorte IA.';
}
