// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Wallet';

  @override
  String get homeWalletEmptyTitle => 'Your wallet is empty';

  @override
  String get homeWalletEmptySubtitle => 'Add your first loyalty card';

  @override
  String get homeAddCard => 'Add Card';

  @override
  String homeFailedImport(Object error) {
    return 'Failed to import card: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGoogleDriveSection => 'Google Drive Backup';

  @override
  String get settingsLocalBackupSection => 'Local Backup';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsNotSignedIn => 'Not Signed In';

  @override
  String get settingsSignIn => 'Sign In';

  @override
  String get settingsBackupToDrive => 'Backup to Drive';

  @override
  String get settingsRestoreFromDrive => 'Restore from Drive';

  @override
  String get settingsExportToFile => 'Export to File';

  @override
  String get settingsImportFromFile => 'Import from File';

  @override
  String get settingsImportPkpass => 'Import .pkpass Card';

  @override
  String get settingsMaxBrightnessTitle => 'Max Brightness on Card';

  @override
  String get settingsMaxBrightnessSubtitle =>
      'Increase screen brightness when viewing QR codes';

  @override
  String get settingsNearbySortingTitle => 'Nearby Pass Sorting';

  @override
  String get settingsNearbySortingSubtitle =>
      'Sort passes by distance using your location';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageTitle => 'App Language';

  @override
  String get settingsLanguageChoose => 'Choose Language';

  @override
  String get settingsLanguageSave => 'Continue';

  @override
  String get settingsLanguageCancel => 'Cancel';

  @override
  String get snackbarEnableLocationServices =>
      'Enable location services to use nearby sorting.';

  @override
  String get snackbarLocationDenied => 'Location permission denied.';

  @override
  String get snackbarLocationBlocked =>
      'Location permission blocked. Enable it in Settings.';

  @override
  String snackbarSignInFailed(Object error) {
    return 'Sign in failed: $error';
  }

  @override
  String get snackbarBackupUploaded => 'Backup uploaded successfully!';

  @override
  String snackbarBackupFailed(Object error) {
    return 'Backup failed: $error';
  }

  @override
  String get snackbarNoBackupFound => 'No backup found.';

  @override
  String get snackbarRestoreSuccessful => 'Restore successful!';

  @override
  String get snackbarInvalidBackupFormat => 'Invalid backup format.';

  @override
  String snackbarRestoreFailed(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get snackbarImportSuccessful => 'Import successful!';

  @override
  String get snackbarInvalidFileFormat => 'Invalid file format.';

  @override
  String snackbarDecodeFailed(Object message) {
    return 'Failed to decode JSON: $message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get snackbarPkpassParseFailed => 'Failed to parse .pkpass file.';

  @override
  String get snackbarPkpassImported => 'Card imported from .pkpass';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'PKPASS import failed: $error';
  }

  @override
  String get backupShareText => 'MyWallet Backup';

  @override
  String get addCardTitle => 'Add New Card';

  @override
  String get addCardStorePlaceholder => 'Store Name';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => 'Service Name';

  @override
  String get addCardServiceNameHint => 'e.g. Starbucks, Tesco';

  @override
  String get addCardNameValidation => 'Please enter a name';

  @override
  String get addCardTypeLabel => 'Card Type';

  @override
  String get cardTypeLoyalty => 'Loyalty Card';

  @override
  String get cardTypeGift => 'Gift Card';

  @override
  String get cardTypeMembership => 'Membership Card';

  @override
  String get cardTypeDiscount => 'Discount Card';

  @override
  String get cardTypeClub => 'Club Card';

  @override
  String get addCardCodeLabel => 'Card Code';

  @override
  String get addCardCodeHint => 'Scan or enter code';

  @override
  String get addCardCodeValidation => 'Please enter a code';

  @override
  String get addCardIconLabel => 'Card Icon';

  @override
  String get addCardColorLabel => 'Card Color';

  @override
  String get addCardSave => 'Save Card';

  @override
  String get addCardLinkNotPass =>
      'Link did not return a valid pass file. Using as code.';

  @override
  String addCardFailedFetch(Object status) {
    return 'Failed to fetch link: $status';
  }

  @override
  String addCardDownloadError(Object error) {
    return 'Error downloading: $error';
  }

  @override
  String get scannerTitle => 'Scan QR Code';

  @override
  String get cardUpdated => 'Card updated successfully';

  @override
  String get cardUpdateFailed => 'No updates available or update failed';

  @override
  String get cardDeleteTitle => 'Delete Card';

  @override
  String get cardDeleteConfirm => 'Are you sure you want to remove this card?';

  @override
  String get cardDeleteCancel => 'Cancel';

  @override
  String get cardDeleteAction => 'Delete';

  @override
  String get cardShowCodeHint =>
      'Show this code at checkout\nPull down to refresh balance';

  @override
  String barcodeError(Object error) {
    return 'Error generating barcode: $error';
  }

  @override
  String get qrCodeLabel => 'QR code';

  @override
  String get pointsLabelDefault => 'Points';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => 'Simplified Chinese';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageArabic => 'Arabic';
}
