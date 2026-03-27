// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline => 'Edge AI Morphometrics.\n移动表型 AI 工作流。离线、在设备上且可及的分析。';

  @override
  String get themeMenuTooltip => '选择主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get themeLabel => '主题';

  @override
  String get languageMenuTooltip => '选择语言';

  @override
  String get languageSystem => '使用系统语言';

  @override
  String get languageLabel => '语言';

  @override
  String get uiScaleTitle => '界面大小';

  @override
  String get uiScaleHint => '文字和按钮';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => '重置';

  @override
  String get uiScaleClose => '关闭';

  @override
  String get homeLiveButton => '实时模式（相机）';

  @override
  String get homeBatchButton => '批处理模式（图库）';

  @override
  String get homeDataManagerButton => '数据与分析管理器';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => '批处理模式';

  @override
  String get btnApplyAi => '应用 AI';

  @override
  String get btnAddGallery => '从图库添加';

  @override
  String get btnReplaceList => '替换列表';

  @override
  String imagesLoaded(int count) {
    return '已加载图片：$count';
  }

  @override
  String get btnClearList => '清空列表';

  @override
  String get sortBy => '排序依据:';

  @override
  String get sortOriginal => '原始顺序';

  @override
  String get sortRejectedFirst => '先显示拒绝';

  @override
  String get sortEditedFirst => '先显示已编辑';

  @override
  String exportResults(int count) {
    return '导出（$count）个结果';
  }

  @override
  String get noExportable => '没有可导出的已批准或已编辑结果。';

  @override
  String exportSuccess(Object fileName, int count) {
    return '成功！\'$fileName\' 已创建，包含 $count 个样本。';
  }

  @override
  String processingComplete(Object time, int count) {
    return '处理在 $time 内完成。已处理 $count 张图片。';
  }

  @override
  String get stopProcess => '停止处理';

  @override
  String get filterStructural => '结构过滤器';

  @override
  String get filterStructuralOn => '开启（验证位置）';

  @override
  String get filterStructuralOff => '关闭（全部通过）';

  @override
  String get detectionLowConfidence => '检测置信度低。';

  @override
  String rejectionPoints(Object points) {
    return '不一致的点：$points';
  }

  @override
  String get liveTitle => '实时模式';

  @override
  String liveBatchCount(int count) {
    return '批次：$count 个样本';
  }

  @override
  String snackAddBatch(int count) {
    return '样本已添加。总计：$count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return '已拒绝：$reason。未添加。';
  }

  @override
  String get snackDiscarded => '结果已丢弃。';

  @override
  String get readyNewCapture => '准备好新的拍摄。';

  @override
  String errorDuringAnalysis(Object error) {
    return '分析错误：$error';
  }

  @override
  String get noSpecimensToExport => '批次中没有可导出的样本。';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return '成功！\'$fileName\' 已创建，包含 $count 个样本。';
  }

  @override
  String exportLiveError(Object error) {
    return '导出错误：$error';
  }

  @override
  String get btnDiscard => '丢弃';

  @override
  String get btnAccept => '接受';

  @override
  String get btnEdit => '编辑';

  @override
  String get btnRetake => '重新拍摄';

  @override
  String get btnExportBatch => '导出批次';

  @override
  String get resultRejectedPrefix => '已拒绝:';

  @override
  String get resultLabel => '结果';

  @override
  String get statusApproved => '已批准';

  @override
  String get statusRejected => '已拒绝';

  @override
  String get statusEdited => '已编辑';

  @override
  String detailMovingPoint(int index) {
    return '移动第 $index 点';
  }

  @override
  String get detailEditor => '编辑器';

  @override
  String get detailSaveTooltip => '保存更改';

  @override
  String get detailSaveSuccess => '更改已保存。';

  @override
  String detailRejectedBanner(Object reason) {
    return '已拒绝：$reason';
  }

  @override
  String get detailPrevPoint => '上一个点';

  @override
  String get detailNextPoint => '下一个点';

  @override
  String get detailPrevImage => '上一张图片';

  @override
  String get detailNextImage => '下一张图片';

  @override
  String get dmTitle => '数据管理器';

  @override
  String get dmLandmarkFiles => '特征点文件（输入）';

  @override
  String get dmAnalysisFiles => '分析文件（结果）';

  @override
  String get dmNoFiles => '未找到文件。';

  @override
  String get dmDeleteConfirmTitle => '确认删除';

  @override
  String dmDeleteConfirmContent(Object file) {
    return '删除文件 \"$file\"？';
  }

  @override
  String get dmDeleteCancel => '取消';

  @override
  String get dmDeleteConfirm => '删除';

  @override
  String get dmDeleteSuccess => '文件已删除';

  @override
  String dmDeleteError(Object error) {
    return '删除出错：$error';
  }

  @override
  String get dmAnalyzeButton => '分析特征点文件';

  @override
  String dmErrorAnalysis(Object error) {
    return '分析错误：$error';
  }

  @override
  String get dmCsvEmpty => 'CSV 为空或只有表头。';

  @override
  String get dmNeedThree => '至少需要 3 个有效样本。';

  @override
  String get cameraLoadError => '无法加载相机。';

  @override
  String get drawerInfo => '信息';

  @override
  String get drawerInfoSubtitle => '模型详情和致谢';

  @override
  String get infoPageTitle => '信息';

  @override
  String get infoModelSection => '使用中的模型';

  @override
  String get infoThanksSection => '致谢';

  @override
  String get infoPlaceholder => '我们很快会添加模型详情和鸣谢。';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => '分享 / 导出';

  @override
  String get homeEcoFieldButton => 'Eco-Field 模式';

  @override
  String get homeEcoFieldLockedMessage => '请先在设置中启用 Eco-Field Mode。';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => '已启用用于野外采集';

  @override
  String get ecoFieldSettingsSubtitleDisabled => '未启用。请在设置中开启后从首页使用。';

  @override
  String get ecoFieldLocationDeniedNotice => '定位权限被拒绝。将继续拍摄但 GPS 为空。';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => '新建野外会话';

  @override
  String get ecoFieldBatchLabel => 'Batch / 种群';

  @override
  String get ecoFieldBatchHint => '例如：north_population_01';

  @override
  String get ecoFieldBatchRequired => '请输入 batch 名称。';

  @override
  String get ecoFieldOutputModeLabel => '输出模式';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop（优化）';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame（原图）';

  @override
  String get ecoFieldBlurFilterLabel => '模糊过滤（拉普拉斯）';

  @override
  String get ecoFieldStartSession => '开始会话';

  @override
  String get ecoFieldCancelSession => '取消';

  @override
  String ecoFieldSessionReady(Object session) {
    return '会话已就绪：$session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return '已保存：$imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return '保存拍摄失败：$error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection => '未以足够置信度检测到花朵。';

  @override
  String get ecoFieldCaptureRejectedBlur => '图像模糊，已丢弃。';

  @override
  String get ecoFieldCaptureRejectedCrop => '无法生成 IA 裁剪图。';
}
