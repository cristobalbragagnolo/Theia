// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nسير عمل ذكاء اصطناعي ظاهري للهواتف المحمولة. تحليل بلا اتصال، على الجهاز، ومتاحة للجميع.';

  @override
  String get themeMenuTooltip => 'اختيار السمة';

  @override
  String get themeSystem => 'اتباع النظام';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الداكن';

  @override
  String get themeLabel => 'السمة';

  @override
  String get languageMenuTooltip => 'اختيار اللغة';

  @override
  String get languageSystem => 'استخدام لغة النظام';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get uiScaleTitle => 'حجم الواجهة';

  @override
  String get uiScaleHint => 'النص والأزرار';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'إعادة تعيين';

  @override
  String get uiScaleClose => 'إغلاق';

  @override
  String get homeLiveButton => 'وضع مباشر (الكاميرا)';

  @override
  String get homeBatchButton => 'وضع دفعة (المعرض)';

  @override
  String get homeDataManagerButton => 'مدير البيانات والتحليل';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'وضع الدفعة';

  @override
  String get btnApplyAi => 'تطبيق الذكاء الاصطناعي';

  @override
  String get btnAddGallery => 'إضافة من المعرض';

  @override
  String get btnReplaceList => 'استبدال القائمة';

  @override
  String imagesLoaded(int count) {
    return 'تم تحميل الصور: $count';
  }

  @override
  String get btnClearList => 'تفريغ القائمة';

  @override
  String get sortBy => 'الترتيب حسب:';

  @override
  String get sortOriginal => 'الترتيب الأصلي';

  @override
  String get sortRejectedFirst => 'المرفوض أولاً';

  @override
  String get sortEditedFirst => 'المعدل أولاً';

  @override
  String exportResults(int count) {
    return 'تصدير ($count) من النتائج';
  }

  @override
  String get noExportable => 'لا توجد نتائج معتمدة أو معدلة للتصدير.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'تم بنجاح! تم إنشاء \'$fileName\' مع $count عيّنات.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'اكتملت العملية خلال $time. تمت معالجة $count صورة.';
  }

  @override
  String get stopProcess => 'إيقاف العملية';

  @override
  String get filterStructural => 'مرشح هيكلي';

  @override
  String get filterStructuralOn => 'مفعّل (يتحقق من المواقع)';

  @override
  String get filterStructuralOff => 'معطل (تمرير كل التنبؤات)';

  @override
  String get detectionLowConfidence => 'ثقة الاكتشاف منخفضة.';

  @override
  String rejectionPoints(Object points) {
    return 'نقاط غير متسقة: $points';
  }

  @override
  String get liveTitle => 'وضع مباشر';

  @override
  String liveBatchCount(int count) {
    return 'دفعة: $count عيّنات';
  }

  @override
  String snackAddBatch(int count) {
    return 'تمت إضافة عينة. المجموع: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'مرفوض: $reason. لم تتم الإضافة.';
  }

  @override
  String get snackDiscarded => 'تم حذف النتيجة.';

  @override
  String get readyNewCapture => 'جاهز لالتقاط جديد.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'خطأ أثناء التحليل: $error';
  }

  @override
  String get noSpecimensToExport => 'لا توجد عيّنات للتصدير.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'تم بنجاح! تم إنشاء \'$fileName\' مع $count عيّنات.';
  }

  @override
  String exportLiveError(Object error) {
    return 'خطأ في التصدير: $error';
  }

  @override
  String get btnDiscard => 'حذف';

  @override
  String get btnAccept => 'قبول';

  @override
  String get btnEdit => 'تعديل';

  @override
  String get btnRetake => 'إعادة الالتقاط';

  @override
  String get btnExportBatch => 'تصدير الدفعة';

  @override
  String get resultRejectedPrefix => 'مرفوض:';

  @override
  String get resultLabel => 'النتيجة';

  @override
  String get statusApproved => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusEdited => 'معدّل';

  @override
  String detailMovingPoint(int index) {
    return 'تحريك النقطة $index';
  }

  @override
  String get detailEditor => 'المحرر';

  @override
  String get detailSaveTooltip => 'حفظ التغييرات';

  @override
  String get detailSaveSuccess => 'تم حفظ التغييرات.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'مرفوض: $reason';
  }

  @override
  String get detailPrevPoint => 'النقطة السابقة';

  @override
  String get detailNextPoint => 'النقطة التالية';

  @override
  String get detailPrevImage => 'الصورة السابقة';

  @override
  String get detailNextImage => 'الصورة التالية';

  @override
  String get dmTitle => 'مدير البيانات';

  @override
  String get dmLandmarkFiles => 'ملفات العلامات (إدخال)';

  @override
  String get dmAnalysisFiles => 'ملفات التحليل (نتائج)';

  @override
  String get dmNoFiles => 'لم يتم العثور على ملفات.';

  @override
  String get dmDeleteConfirmTitle => 'تأكيد الحذف';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'حذف الملف \"$file\"؟';
  }

  @override
  String get dmDeleteCancel => 'إلغاء';

  @override
  String get dmDeleteConfirm => 'حذف';

  @override
  String get dmDeleteSuccess => 'تم حذف الملف';

  @override
  String dmDeleteError(Object error) {
    return 'خطأ في الحذف: $error';
  }

  @override
  String get dmAnalyzeButton => 'تحليل ملف العلامات';

  @override
  String dmErrorAnalysis(Object error) {
    return 'خطأ في التحليل: $error';
  }

  @override
  String get dmCsvEmpty => 'ملف CSV فارغ أو يحتوي على العنوان فقط.';

  @override
  String get dmNeedThree => 'مطلوب 3 عينات صالحة على الأقل.';

  @override
  String get cameraLoadError => 'تعذر تحميل الكاميرا.';

  @override
  String get drawerInfo => 'معلومات';

  @override
  String get drawerInfoSubtitle => 'تفاصيل النموذج والشكر';

  @override
  String get infoPageTitle => 'معلومات';

  @override
  String get infoModelSection => 'النموذج المستخدم';

  @override
  String get infoThanksSection => 'شكر وتقدير';

  @override
  String get infoPlaceholder => 'سنضيف قريباً تفاصيل حول النموذج والشكر.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'مشاركة / تصدير';

  @override
  String get homeEcoFieldButton => 'وضع Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'فعّل Eco-Field Mode من الإعدادات لاستخدامه.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled =>
      'مفعل لالتقاط البيانات الميدانية';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'غير مفعل. قم بتفعيله من الإعدادات.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'تم رفض الموقع. سيستمر الالتقاط مع GPS فارغ.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'جلسة ميدانية جديدة';

  @override
  String get ecoFieldBatchLabel => 'Batch / مجموعة';

  @override
  String get ecoFieldBatchHint => 'مثال: north_population_01';

  @override
  String get ecoFieldBatchRequired => 'أدخل اسم batch.';

  @override
  String get ecoFieldOutputModeLabel => 'وضع الإخراج';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (محسّن)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (أصلي)';

  @override
  String get ecoFieldBlurFilterLabel => 'مرشح الضبابية (Laplacian)';

  @override
  String get ecoFieldStartSession => 'بدء الجلسة';

  @override
  String get ecoFieldCancelSession => 'إلغاء';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'الجلسة جاهزة: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'تم الحفظ: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'خطأ في حفظ الالتقاط: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'لم يتم اكتشاف الزهرة بثقة كافية.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'تم رفض الالتقاط بسبب الضبابية.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'تعذر إنشاء قص IA.';
}
