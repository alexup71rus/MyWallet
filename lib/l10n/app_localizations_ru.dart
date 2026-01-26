// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Мой кошелек';

  @override
  String get homeWalletEmptyTitle => 'Ваш кошелек пуст';

  @override
  String get homeWalletEmptySubtitle => 'Добавьте свою первую карту лояльности';

  @override
  String get homeAddCard => 'Добавить карту';

  @override
  String get addCardOptionScan => 'Сканировать QR-код';

  @override
  String get addCardOptionImport => 'Импорт из файла';

  @override
  String get addCardOptionManual => 'Добавить вручную';

  @override
  String homeFailedImport(Object error) {
    return 'Не удалось импортировать карту: $error';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGoogleDriveSection => 'Резервная копия Google Drive';

  @override
  String get settingsLocalBackupSection => 'Локальная резервная копия';

  @override
  String get settingsAboutSection => 'О приложении';

  @override
  String get settingsNotSignedIn => 'Не выполнен вход';

  @override
  String get settingsSignIn => 'Войти';

  @override
  String get settingsBackupToDrive => 'Сохранить в Drive';

  @override
  String get settingsRestoreFromDrive => 'Восстановить из Drive';

  @override
  String get settingsExportToFile => 'Экспорт в файл';

  @override
  String get settingsImportFromFile => 'Импорт из файла';

  @override
  String get settingsImportPkpass => 'Импорт карты .pkpass';

  @override
  String get settingsMaxBrightnessTitle => 'Максимальная яркость на карте';

  @override
  String get settingsMaxBrightnessSubtitle =>
      'Увеличивать яркость при просмотре QR-кодов';

  @override
  String get settingsNearbySortingTitle => 'Сортировка по близости';

  @override
  String get settingsNearbySortingSubtitle =>
      'Сортировать карты по расстоянию с помощью геолокации';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get settingsLanguageSection => 'Язык';

  @override
  String get settingsLanguageTitle => 'Язык приложения';

  @override
  String get settingsLanguageChoose => 'Выберите язык';

  @override
  String get settingsLanguageSave => 'Продолжить';

  @override
  String get settingsLanguageCancel => 'Отмена';

  @override
  String get snackbarEnableLocationServices =>
      'Включите службы геолокации для сортировки по близости.';

  @override
  String get snackbarLocationDenied => 'Доступ к геолокации запрещен.';

  @override
  String get snackbarLocationBlocked =>
      'Доступ к геолокации заблокирован. Разрешите в настройках.';

  @override
  String snackbarSignInFailed(Object error) {
    return 'Вход не выполнен: $error';
  }

  @override
  String get snackbarBackupUploaded => 'Резервная копия загружена!';

  @override
  String snackbarBackupFailed(Object error) {
    return 'Не удалось создать резервную копию: $error';
  }

  @override
  String get snackbarNoBackupFound => 'Резервная копия не найдена.';

  @override
  String get snackbarRestoreSuccessful => 'Восстановление выполнено!';

  @override
  String get snackbarInvalidBackupFormat => 'Неверный формат резервной копии.';

  @override
  String snackbarRestoreFailed(Object error) {
    return 'Не удалось восстановить: $error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return 'Экспорт не удался: $error';
  }

  @override
  String get snackbarImportSuccessful => 'Импорт выполнен!';

  @override
  String get snackbarInvalidFileFormat => 'Неверный формат файла.';

  @override
  String snackbarDecodeFailed(Object message) {
    return 'Не удалось декодировать JSON: $message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get snackbarPkpassParseFailed => 'Не удалось разобрать файл .pkpass.';

  @override
  String get snackbarPkpassImported => 'Карта импортирована из .pkpass';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'Импорт PKPASS не удался: $error';
  }

  @override
  String get backupShareText => 'Резервная копия MyWallet';

  @override
  String get addCardTitle => 'Добавить карту';

  @override
  String get addCardStorePlaceholder => 'Название магазина';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => 'Название сервиса';

  @override
  String get addCardServiceNameHint => 'например Starbucks, Tesco';

  @override
  String get addCardNameValidation => 'Введите название';

  @override
  String get addCardTypeLabel => 'Тип карты';

  @override
  String get cardTypeLoyalty => 'Карта лояльности';

  @override
  String get cardTypeGift => 'Подарочная карта';

  @override
  String get cardTypeMembership => 'Членская карта';

  @override
  String get cardTypeDiscount => 'Дисконтная карта';

  @override
  String get cardTypeClub => 'Клубная карта';

  @override
  String get addCardCodeLabel => 'Код карты';

  @override
  String get addCardCodeHint => 'Сканируйте или введите код';

  @override
  String get addCardCodeValidation => 'Введите код';

  @override
  String get addCardIconLabel => 'Иконка карты';

  @override
  String get addCardColorLabel => 'Цвет карты';

  @override
  String get addCardSave => 'Сохранить карту';

  @override
  String get addCardLinkNotPass =>
      'Ссылка не вернула файл пропуска. Используем как код.';

  @override
  String addCardFailedFetch(Object status) {
    return 'Не удалось загрузить ссылку: $status';
  }

  @override
  String addCardDownloadError(Object error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get scannerTitle => 'Сканировать QR-код';

  @override
  String get cardUpdated => 'Карта обновлена';

  @override
  String get cardUpdateFailed =>
      'Обновления недоступны или не удалось обновить';

  @override
  String get cardDeleteTitle => 'Удалить карту';

  @override
  String get cardDeleteConfirm => 'Вы уверены, что хотите удалить эту карту?';

  @override
  String get cardDeleteCancel => 'Отмена';

  @override
  String get cardDeleteAction => 'Удалить';

  @override
  String get cardShowCodeHint =>
      'Покажите этот код на кассе\nПотяните вниз для обновления баланса';

  @override
  String barcodeError(Object error) {
    return 'Ошибка генерации штрихкода: $error';
  }

  @override
  String get qrCodeLabel => 'QR-код';

  @override
  String get pointsLabelDefault => 'Баллы';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageChineseSimplified => 'Китайский (упрощенный)';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageArabic => 'Арабский';
}
