import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ja'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get appTitle;

  /// No description provided for @homeWalletEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is empty'**
  String get homeWalletEmptyTitle;

  /// No description provided for @homeWalletEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first loyalty card'**
  String get homeWalletEmptySubtitle;

  /// No description provided for @homeAddCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get homeAddCard;

  /// No description provided for @addCardOptionScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get addCardOptionScan;

  /// No description provided for @addCardOptionImport.
  ///
  /// In en, this message translates to:
  /// **'Import from file'**
  String get addCardOptionImport;

  /// No description provided for @addCardOptionManual.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addCardOptionManual;

  /// No description provided for @homeFailedImport.
  ///
  /// In en, this message translates to:
  /// **'Failed to import card: {error}'**
  String homeFailedImport(Object error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGoogleDriveSection.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Backup'**
  String get settingsGoogleDriveSection;

  /// No description provided for @settingsLocalBackupSection.
  ///
  /// In en, this message translates to:
  /// **'Local Backup'**
  String get settingsLocalBackupSection;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Signed In'**
  String get settingsNotSignedIn;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get settingsSignIn;

  /// No description provided for @settingsBackupToDrive.
  ///
  /// In en, this message translates to:
  /// **'Backup to Drive'**
  String get settingsBackupToDrive;

  /// No description provided for @settingsRestoreFromDrive.
  ///
  /// In en, this message translates to:
  /// **'Restore from Drive'**
  String get settingsRestoreFromDrive;

  /// No description provided for @settingsExportToFile.
  ///
  /// In en, this message translates to:
  /// **'Export to File'**
  String get settingsExportToFile;

  /// No description provided for @settingsImportFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get settingsImportFromFile;

  /// No description provided for @settingsImportPkpass.
  ///
  /// In en, this message translates to:
  /// **'Import .pkpass Card'**
  String get settingsImportPkpass;

  /// No description provided for @settingsMaxBrightnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Brightness on Card'**
  String get settingsMaxBrightnessTitle;

  /// No description provided for @settingsMaxBrightnessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Increase screen brightness when viewing QR codes'**
  String get settingsMaxBrightnessSubtitle;

  /// No description provided for @settingsNearbySortingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby Pass Sorting'**
  String get settingsNearbySortingTitle;

  /// No description provided for @settingsNearbySortingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sort passes by distance using your location'**
  String get settingsNearbySortingSubtitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get settingsLanguageChoose;

  /// No description provided for @settingsLanguageSave.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get settingsLanguageSave;

  /// No description provided for @settingsLanguageCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsLanguageCancel;

  /// No description provided for @snackbarEnableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Enable location services to use nearby sorting.'**
  String get snackbarEnableLocationServices;

  /// No description provided for @snackbarLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get snackbarLocationDenied;

  /// No description provided for @snackbarLocationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location permission blocked. Enable it in Settings.'**
  String get snackbarLocationBlocked;

  /// No description provided for @snackbarSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {error}'**
  String snackbarSignInFailed(Object error);

  /// No description provided for @snackbarBackupUploaded.
  ///
  /// In en, this message translates to:
  /// **'Backup uploaded successfully!'**
  String get snackbarBackupUploaded;

  /// No description provided for @snackbarBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String snackbarBackupFailed(Object error);

  /// No description provided for @snackbarNoBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup found.'**
  String get snackbarNoBackupFound;

  /// No description provided for @snackbarRestoreSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Restore successful!'**
  String get snackbarRestoreSuccessful;

  /// No description provided for @snackbarInvalidBackupFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup format.'**
  String get snackbarInvalidBackupFormat;

  /// No description provided for @snackbarRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String snackbarRestoreFailed(Object error);

  /// No description provided for @snackbarExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String snackbarExportFailed(Object error);

  /// No description provided for @snackbarImportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get snackbarImportSuccessful;

  /// No description provided for @snackbarInvalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format.'**
  String get snackbarInvalidFileFormat;

  /// No description provided for @snackbarDecodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to decode JSON: {message}'**
  String snackbarDecodeFailed(Object message);

  /// No description provided for @snackbarImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String snackbarImportFailed(Object error);

  /// No description provided for @snackbarPkpassParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse .pkpass file.'**
  String get snackbarPkpassParseFailed;

  /// No description provided for @snackbarPkpassImported.
  ///
  /// In en, this message translates to:
  /// **'Card imported from .pkpass'**
  String get snackbarPkpassImported;

  /// No description provided for @snackbarPkpassImportFailed.
  ///
  /// In en, this message translates to:
  /// **'PKPASS import failed: {error}'**
  String snackbarPkpassImportFailed(Object error);

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'MyWallet Backup'**
  String get backupShareText;

  /// No description provided for @addCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addCardTitle;

  /// No description provided for @addCardStorePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get addCardStorePlaceholder;

  /// No description provided for @addCardCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0000 0000 0000'**
  String get addCardCodePlaceholder;

  /// No description provided for @addCardServiceNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Service Name'**
  String get addCardServiceNameLabel;

  /// No description provided for @addCardServiceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Starbucks, Tesco'**
  String get addCardServiceNameHint;

  /// No description provided for @addCardNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get addCardNameValidation;

  /// No description provided for @addCardTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get addCardTypeLabel;

  /// No description provided for @cardTypeLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Card'**
  String get cardTypeLoyalty;

  /// No description provided for @cardTypeGift.
  ///
  /// In en, this message translates to:
  /// **'Gift Card'**
  String get cardTypeGift;

  /// No description provided for @cardTypeMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership Card'**
  String get cardTypeMembership;

  /// No description provided for @cardTypeDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount Card'**
  String get cardTypeDiscount;

  /// No description provided for @cardTypeClub.
  ///
  /// In en, this message translates to:
  /// **'Club Card'**
  String get cardTypeClub;

  /// No description provided for @addCardCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Code'**
  String get addCardCodeLabel;

  /// No description provided for @addCardCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Scan or enter code'**
  String get addCardCodeHint;

  /// No description provided for @addCardCodeValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get addCardCodeValidation;

  /// No description provided for @addCardIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Icon'**
  String get addCardIconLabel;

  /// No description provided for @addCardColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Color'**
  String get addCardColorLabel;

  /// No description provided for @addCardSave.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get addCardSave;

  /// No description provided for @addCardLinkNotPass.
  ///
  /// In en, this message translates to:
  /// **'Link did not return a valid pass file. Using as code.'**
  String get addCardLinkNotPass;

  /// No description provided for @addCardFailedFetch.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch link: {status}'**
  String addCardFailedFetch(Object status);

  /// No description provided for @addCardDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Error downloading: {error}'**
  String addCardDownloadError(Object error);

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scannerTitle;

  /// No description provided for @cardUpdated.
  ///
  /// In en, this message translates to:
  /// **'Card updated successfully'**
  String get cardUpdated;

  /// No description provided for @cardUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'No updates available or update failed'**
  String get cardUpdateFailed;

  /// No description provided for @cardDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get cardDeleteTitle;

  /// No description provided for @cardDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this card?'**
  String get cardDeleteConfirm;

  /// No description provided for @cardDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cardDeleteCancel;

  /// No description provided for @cardDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cardDeleteAction;

  /// Instruction shown under the card
  ///
  /// In en, this message translates to:
  /// **'Show this code at checkout\nPull down to refresh balance'**
  String get cardShowCodeHint;

  /// No description provided for @barcodeError.
  ///
  /// In en, this message translates to:
  /// **'Error generating barcode: {error}'**
  String barcodeError(Object error);

  /// No description provided for @qrCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCodeLabel;

  /// No description provided for @pointsLabelDefault.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabelDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get languageChineseSimplified;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ja', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
