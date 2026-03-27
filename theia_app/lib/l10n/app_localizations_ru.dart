// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Theia';

  @override
  String get appTagline =>
      'Edge AI Morphometrics.\nМобильный фенотипический AI-процесс. Аналитика офлайн, на устройстве и доступная.';

  @override
  String get themeMenuTooltip => 'Выбрать тему';

  @override
  String get themeSystem => 'Следовать системе';

  @override
  String get themeLight => 'Светлая тема';

  @override
  String get themeDark => 'Тёмная тема';

  @override
  String get themeLabel => 'Тема';

  @override
  String get languageMenuTooltip => 'Выбрать язык';

  @override
  String get languageSystem => 'Использовать язык системы';

  @override
  String get languageLabel => 'Язык';

  @override
  String get uiScaleTitle => 'Размер интерфейса';

  @override
  String get uiScaleHint => 'текст и кнопки';

  @override
  String uiScaleSubtitle(int percent, Object hint) {
    return '$percent% - $hint';
  }

  @override
  String get uiScaleReset => 'Сбросить';

  @override
  String get uiScaleClose => 'Закрыть';

  @override
  String get homeLiveButton => 'Режим Live (камера)';

  @override
  String get homeBatchButton => 'Пакетный режим (галерея)';

  @override
  String get homeDataManagerButton => 'Менеджер данных и анализа';

  @override
  String get splashTitle => 'Theia';

  @override
  String get batchTitle => 'Пакетный режим';

  @override
  String get btnApplyAi => 'Применить ИИ';

  @override
  String get btnAddGallery => 'Добавить из галереи';

  @override
  String get btnReplaceList => 'Заменить список';

  @override
  String imagesLoaded(int count) {
    return 'Загружено изображений: $count';
  }

  @override
  String get btnClearList => 'Очистить список';

  @override
  String get sortBy => 'Сортировать по:';

  @override
  String get sortOriginal => 'Исходный порядок';

  @override
  String get sortRejectedFirst => 'Сначала отклонённые';

  @override
  String get sortEditedFirst => 'Сначала отредактированные';

  @override
  String exportResults(int count) {
    return 'Экспорт ($count) результатов';
  }

  @override
  String get noExportable =>
      'Нет одобренных или отредактированных результатов для экспорта.';

  @override
  String exportSuccess(Object fileName, int count) {
    return 'Успех! \'$fileName\' создан с $count образцами.';
  }

  @override
  String processingComplete(Object time, int count) {
    return 'Процесс завершён за $time. Обработано $count изображений.';
  }

  @override
  String get stopProcess => 'Остановить процесс';

  @override
  String get filterStructural => 'Структурный фильтр';

  @override
  String get filterStructuralOn => 'Вкл. (проверка позиций)';

  @override
  String get filterStructuralOff => 'Выкл. (все предсказания проходят)';

  @override
  String get detectionLowConfidence => 'Низкая уверенность обнаружения.';

  @override
  String rejectionPoints(Object points) {
    return 'Несогласованные точки: $points';
  }

  @override
  String get liveTitle => 'Live режим';

  @override
  String liveBatchCount(int count) {
    return 'Партия: $count образцов';
  }

  @override
  String snackAddBatch(int count) {
    return 'Образец добавлен. Всего: $count';
  }

  @override
  String snackRejectedNotAdded(Object reason) {
    return 'Отклонено: $reason. Не добавлено.';
  }

  @override
  String get snackDiscarded => 'Результат удалён.';

  @override
  String get readyNewCapture => 'Готово к новой съемке.';

  @override
  String errorDuringAnalysis(Object error) {
    return 'Ошибка анализа: $error';
  }

  @override
  String get noSpecimensToExport => 'Нет образцов для экспорта.';

  @override
  String exportLiveSuccess(Object fileName, int count) {
    return 'Успех! \'$fileName\' создан с $count образцами.';
  }

  @override
  String exportLiveError(Object error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get btnDiscard => 'Удалить';

  @override
  String get btnAccept => 'Принять';

  @override
  String get btnEdit => 'Редактировать';

  @override
  String get btnRetake => 'Снять снова';

  @override
  String get btnExportBatch => 'Экспорт партии';

  @override
  String get resultRejectedPrefix => 'ОТКЛОНЕНО:';

  @override
  String get resultLabel => 'Результат';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get statusEdited => 'Отредактировано';

  @override
  String detailMovingPoint(int index) {
    return 'Перемещение точки $index';
  }

  @override
  String get detailEditor => 'Редактор';

  @override
  String get detailSaveTooltip => 'Сохранить изменения';

  @override
  String get detailSaveSuccess => 'Изменения сохранены.';

  @override
  String detailRejectedBanner(Object reason) {
    return 'Отклонено: $reason';
  }

  @override
  String get detailPrevPoint => 'Предыдущая точка';

  @override
  String get detailNextPoint => 'Следующая точка';

  @override
  String get detailPrevImage => 'Предыдущее изображение';

  @override
  String get detailNextImage => 'Следующее изображение';

  @override
  String get dmTitle => 'Менеджер данных';

  @override
  String get dmLandmarkFiles => 'Файлы ориентиров (вход)';

  @override
  String get dmAnalysisFiles => 'Файлы анализа (результаты)';

  @override
  String get dmNoFiles => 'Файлы не найдены.';

  @override
  String get dmDeleteConfirmTitle => 'Подтвердить удаление';

  @override
  String dmDeleteConfirmContent(Object file) {
    return 'Удалить файл \"$file\"?';
  }

  @override
  String get dmDeleteCancel => 'Отмена';

  @override
  String get dmDeleteConfirm => 'Удалить';

  @override
  String get dmDeleteSuccess => 'Файл удалён';

  @override
  String dmDeleteError(Object error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get dmAnalyzeButton => 'Анализировать файл ориентиров';

  @override
  String dmErrorAnalysis(Object error) {
    return 'Ошибка анализа: $error';
  }

  @override
  String get dmCsvEmpty => 'CSV пуст или только заголовок.';

  @override
  String get dmNeedThree => 'Требуется минимум 3 действительных образца.';

  @override
  String get cameraLoadError => 'Не удалось загрузить камеру.';

  @override
  String get drawerInfo => 'Информация';

  @override
  String get drawerInfoSubtitle => 'Детали модели и благодарности';

  @override
  String get infoPageTitle => 'Информация';

  @override
  String get infoModelSection => 'Используемая модель';

  @override
  String get infoThanksSection => 'Благодарности';

  @override
  String get infoPlaceholder => 'Скоро добавим детали модели и благодарности.';

  @override
  String get infoAcknowledgementsBody =>
      'Los algoritmos de DeepLearning de esta aplicación, como la ciencia en general, están construidas sobre el trabajo que hicieron otras personas antes que nosotros. Por eso quiero agradecer a Mohamed (Moha) Abdelaziz, A. Jesús Muñoz-Pajares y Andrés Ferreira Rodríguez por su trabajo en anotación y su gran apoyo.\n\nEsta app esta hecha con amor, curiosidad y mucho trabajo. Por lo cual quiero agradecerles a mis padres y mi familia que me inculcaron esos valores.\n\nEspero que esta herramienta sirva para la investigación científica y ayude a los que vienen luego a descubrir e inventar cosas aun mejores.';

  @override
  String get appTaglineShort => 'Edge AI Morphometrics';

  @override
  String get shareExport => 'Поделиться / Экспорт';

  @override
  String get homeEcoFieldButton => 'Режим Eco-Field';

  @override
  String get homeEcoFieldLockedMessage =>
      'Включите Eco-Field Mode в настройках.';

  @override
  String get ecoFieldSettingsTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSettingsSubtitleEnabled => 'Включен для полевого сбора';

  @override
  String get ecoFieldSettingsSubtitleDisabled =>
      'Выключен. Включите в настройках для доступа с Home.';

  @override
  String get ecoFieldLocationDeniedNotice =>
      'Доступ к геопозиции отклонен. Съемка продолжится с пустым GPS.';

  @override
  String get ecoFieldTitle => 'Eco-Field Mode';

  @override
  String get ecoFieldSessionPromptTitle => 'Новая полевая сессия';

  @override
  String get ecoFieldBatchLabel => 'Batch / Популяция';

  @override
  String get ecoFieldBatchHint => 'например, north_population_01';

  @override
  String get ecoFieldBatchRequired => 'Введите имя batch.';

  @override
  String get ecoFieldOutputModeLabel => 'Режим вывода';

  @override
  String get ecoFieldOutputModeAiCrop => 'IA-Crop (Оптимизированный)';

  @override
  String get ecoFieldOutputModeFullFrame => 'Full-Frame (Оригинал)';

  @override
  String get ecoFieldBlurFilterLabel => 'Фильтр размытия (Лапласиан)';

  @override
  String get ecoFieldStartSession => 'Начать сессию';

  @override
  String get ecoFieldCancelSession => 'Отмена';

  @override
  String ecoFieldSessionReady(Object session) {
    return 'Сессия готова: $session';
  }

  @override
  String get ecoFieldAiConfidenceNA => 'NA';

  @override
  String ecoFieldCaptureSaved(Object imageName) {
    return 'Сохранено: $imageName';
  }

  @override
  String ecoFieldCaptureSaveError(Object error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get ecoFieldCaptureRejectedNoDetection =>
      'Цветок не обнаружен с достаточной уверенностью.';

  @override
  String get ecoFieldCaptureRejectedBlur => 'Снимок отклонен из-за размытия.';

  @override
  String get ecoFieldCaptureRejectedCrop => 'Не удалось создать IA-crop.';
}
