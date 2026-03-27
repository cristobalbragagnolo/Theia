// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nMobil fenotipik yapay zeka iş akışı. Çevrimdışı, cihaz üzerinde ve erişilebilir analiz.';

  @override
  String get themeMenuTooltip => 'Tema seç';

  @override
  String get themeSystem => 'Sistemi izle';

  @override
  String get themeLight => 'Aydınlık mod';

  @override
  String get themeDark => 'Karanlık mod';

  @override
  String get themeLabel => 'Tema';

  @override
  String get languageMenuTooltip => 'Dil seç';

  @override
  String get languageSystem => 'Sistem dilini kullan';

  @override
  String get languageLabel => 'Dil';

  @override
  String get uiScaleTitle => 'Arayüz boyutu';

  @override
  String get uiScaleHint => 'metin ve düğmeler';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Sıfırla';

  @override
  String get uiScaleClose => 'Kapat';

  @override
  String get homeLiveButton => 'Canlı Mod (Kamera)';

  @override
  String get homeBatchButton => 'Toplu Mod (Galeri)';

  @override
  String get homeDataManagerButton => 'Veri ve Analiz Yöneticisi';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Toplu Mod';

  @override
  String get btnApplyAi => 'Yapay zekayı uygula';

  @override
  String get btnAddGallery => 'Galeriden ekle';

  @override
  String get btnReplaceList => 'Listeyi değiştir';

  @override
  String imagesLoaded(int count) {
    return 'Yüklenen görsel: $count';
  }

  @override
  String get btnClearList => 'Listeyi temizle';

  @override
  String get sortBy => 'Sırala:';

  @override
  String get sortOriginal => 'Orijinal sıra';

  @override
  String get sortRejectedFirst => 'Önce reddedilenler';

  @override
  String get sortEditedFirst => 'Önce düzenlenenler';

  @override
  String exportResults(int count) {
    return '($count) Sonucu dışa aktar';
  }

  @override
  String get noExportable =>
      'Dışa aktarılacak onaylı veya düzenlenmiş sonuç yok.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Başarılı! \'$fileName\' $count örnekle oluşturuldu.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'İşlem $time içinde tamamlandı. $count görsel işlendi.';
  }

  @override
  String get stopProcess => 'İşlemi durdur';

  @override
  String get filterStructural => 'Yapısal filtre';

  @override
  String get filterStructuralOn => 'Açık (konumları doğrular)';

  @override
  String get filterStructuralOff => 'Kapalı (tüm tahminler geçer)';

  @override
  String get detectionLowConfidence => 'Düşük tespit güveni.';

  @override
  String rejectionPoints(Object points) {
    return 'Tutarsız nokta(lar): $points';
  }

  @override
  String get liveTitle => 'Canlı Mod';

  @override
  String liveBatchCount(int count) {
    return 'Toplu: $count örnek';
  }

  @override
  String snackAddBatch(int count) {
    return 'Örnek eklendi. Toplam: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Reddedildi: $reason. Eklenmedi.';
  }

  @override
  String get snackDiscarded => 'Sonuç atıldı.';

  @override
  String get readyNewCapture => 'Yeni çekim için hazır.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Analiz sırasında hata: $error';
  }

  @override
  String get noSpecimensToExport => 'Dışa aktarılacak örnek yok.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Başarılı! \'$fileName\' $count örnekle oluşturuldu.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Dışa aktarma hatası: $error';
  }

  @override
  String get btnDiscard => 'At';

  @override
  String get btnAccept => 'Kabul et';

  @override
  String get btnEdit => 'Düzenle';

  @override
  String get btnRetake => 'Tekrar çek';

  @override
  String get btnExportBatch => 'Topluyu dışa aktar';

  @override
  String get resultRejectedPrefix => 'REDDEDİLDİ:';

  @override
  String get resultLabel => 'Sonuç';

  @override
  String get statusApproved => 'Onaylandı';

  @override
  String get statusRejected => 'Reddedildi';

  @override
  String get statusEdited => 'Düzenlendi';

  @override
  String detailMovingPoint(int index) {
    return '$index. nokta taşınıyor';
  }

  @override
  String get detailEditor => 'Düzenleyici';

  @override
  String get detailSaveTooltip => 'Değişiklikleri kaydet';

  @override
  String get detailSaveSuccess => 'Değişiklikler kaydedildi.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Reddedildi: $reason';
  }

  @override
  String get detailPrevPoint => 'Önceki nokta';

  @override
  String get detailNextPoint => 'Sonraki nokta';

  @override
  String get detailPrevImage => 'Önceki görsel';

  @override
  String get detailNextImage => 'Sonraki görsel';

  @override
  String get dmTitle => 'Veri Yöneticisi';

  @override
  String get dmLandmarkFiles => 'Landmark dosyaları (Girdi)';

  @override
  String get dmAnalysisFiles => 'Analiz dosyaları (Sonuçlar)';

  @override
  String get dmNoFiles => 'Dosya bulunamadı.';

  @override
  String get dmDeleteConfirmTitle => 'Silme onayı';

  @override
  String dmDeleteConfirmContent(Object file) {
    return '\"$file\" dosyası silinsin mi?';
  }

  @override
  String get dmDeleteCancel => 'Vazgeç';

  @override
  String get dmDeleteConfirm => 'Sil';

  @override
  String get dmDeleteSuccess => 'Dosya silindi';

  @override
  String dmDeleteError(Object error) {
    return 'Silme hatası: $error';
  }

  @override
  String get dmAnalyzeButton => 'Landmark dosyasını analiz et';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Analiz hatası: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV boş ya da sadece başlık.';

  @override
  String get dmNeedThree => 'En az 3 geçerli örnek gerekir.';

  @override
  String get cameraLoadError => 'Kamera yüklenemedi.';

  @override
  String get drawerInfo => 'Bilgi';

  @override
  String get drawerInfoSubtitle => 'Model ve teşekkürler';

  @override
  String get infoPageTitle => 'Bilgi';

  @override
  String get infoModelSection => 'Kullanılan model';

  @override
  String get infoThanksSection => 'Teşekkürler';

  @override
  String get infoPlaceholder => 'Yakında mevcut model ve krediler eklenecek.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Paylaş / Dışa aktar';

  @override
  String get homeEcoFieldButton => 'Eco-Field Modu';

  @override
  String get homeEcoFieldLockedMessage =>
      'Kullanmak için ayarlardan Eco-Field Mode\'u etkinleştir.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Saha yakalama için etkin';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Devre dışı. Ana sayfadan kullanmak için etkinleştirin.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Konum reddedildi. Çekimler boş GPS ile devam eder.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Yeni saha oturumu';

  @override
  String get ecoFieldBatchLabel => 'Batch / Popülasyon';

  @override
  String get ecoFieldBatchHint => 'örn. kuzey_populasyon_01';

  @override
  String get ecoFieldBatchRequired => 'Bir batch adı girin.';

  @override
  String get ecoFieldOutputModeLabel => 'Çıkış modu';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Optimize)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Orijinal)';

  @override
  String get ecoFieldBlurFilterLabel => 'Bulanıklık filtresi (Laplacian)';

  @override
  String get ecoFieldStartSession => 'Oturumu başlat';

  @override
  String get ecoFieldCancelSession => 'İptal';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Oturum hazır: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Kaydedildi: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Kayıt hatası: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Çiçek yeterli güvenle algılanamadı.';

  @override
  String get ecoFieldCaptureRejectedBlur =>
      'Çekim bulanıklık nedeniyle reddedildi.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'IA kırpması oluşturulamadı.';
}
