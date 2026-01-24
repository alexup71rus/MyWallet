// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'محفظتي';

  @override
  String get homeWalletEmptyTitle => 'محفظتك فارغة';

  @override
  String get homeWalletEmptySubtitle => 'أضف أول بطاقة ولاء';

  @override
  String get homeAddCard => 'إضافة بطاقة';

  @override
  String homeFailedImport(Object error) {
    return 'فشل استيراد البطاقة: $error';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsGoogleDriveSection => 'نسخة احتياطية على Google Drive';

  @override
  String get settingsLocalBackupSection => 'نسخة احتياطية محلية';

  @override
  String get settingsAboutSection => 'حول';

  @override
  String get settingsNotSignedIn => 'غير مسجل الدخول';

  @override
  String get settingsSignIn => 'تسجيل الدخول';

  @override
  String get settingsBackupToDrive => 'نسخ احتياطي إلى Drive';

  @override
  String get settingsRestoreFromDrive => 'استعادة من Drive';

  @override
  String get settingsExportToFile => 'تصدير إلى ملف';

  @override
  String get settingsImportFromFile => 'استيراد من ملف';

  @override
  String get settingsImportPkpass => 'استيراد بطاقة .pkpass';

  @override
  String get settingsMaxBrightnessTitle => 'أقصى سطوع عند عرض البطاقة';

  @override
  String get settingsMaxBrightnessSubtitle =>
      'زيادة سطوع الشاشة عند عرض رموز QR';

  @override
  String get settingsNearbySortingTitle => 'ترتيب البطاقات القريبة';

  @override
  String get settingsNearbySortingSubtitle =>
      'ترتيب حسب المسافة باستخدام الموقع';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get settingsLanguageTitle => 'لغة التطبيق';

  @override
  String get settingsLanguageChoose => 'اختر اللغة';

  @override
  String get settingsLanguageSave => 'متابعة';

  @override
  String get settingsLanguageCancel => 'إلغاء';

  @override
  String get snackbarEnableLocationServices =>
      'فعّل خدمات الموقع لاستخدام الترتيب حسب القرب.';

  @override
  String get snackbarLocationDenied => 'تم رفض إذن الموقع.';

  @override
  String get snackbarLocationBlocked => 'إذن الموقع محظور. فعّله من الإعدادات.';

  @override
  String snackbarSignInFailed(Object error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get snackbarBackupUploaded => 'تم رفع النسخة الاحتياطية بنجاح!';

  @override
  String snackbarBackupFailed(Object error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get snackbarNoBackupFound => 'لم يتم العثور على نسخة احتياطية.';

  @override
  String get snackbarRestoreSuccessful => 'تمت الاستعادة بنجاح!';

  @override
  String get snackbarInvalidBackupFormat => 'تنسيق النسخة الاحتياطية غير صالح.';

  @override
  String snackbarRestoreFailed(Object error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get snackbarImportSuccessful => 'تم الاستيراد بنجاح!';

  @override
  String get snackbarInvalidFileFormat => 'تنسيق الملف غير صالح.';

  @override
  String snackbarDecodeFailed(Object message) {
    return 'فشل تحليل JSON: $message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get snackbarPkpassParseFailed => 'فشل تحليل ملف .pkpass.';

  @override
  String get snackbarPkpassImported => 'تم استيراد البطاقة من .pkpass';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'فشل استيراد PKPASS: $error';
  }

  @override
  String get backupShareText => 'نسخة MyWallet الاحتياطية';

  @override
  String get addCardTitle => 'إضافة بطاقة جديدة';

  @override
  String get addCardStorePlaceholder => 'اسم المتجر';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => 'اسم الخدمة';

  @override
  String get addCardServiceNameHint => 'مثال: Starbucks، Tesco';

  @override
  String get addCardNameValidation => 'يرجى إدخال الاسم';

  @override
  String get addCardTypeLabel => 'نوع البطاقة';

  @override
  String get cardTypeLoyalty => 'بطاقة ولاء';

  @override
  String get cardTypeGift => 'بطاقة هدية';

  @override
  String get cardTypeMembership => 'بطاقة عضوية';

  @override
  String get cardTypeDiscount => 'بطاقة خصم';

  @override
  String get cardTypeClub => 'بطاقة نادي';

  @override
  String get addCardCodeLabel => 'رمز البطاقة';

  @override
  String get addCardCodeHint => 'امسح أو أدخل الرمز';

  @override
  String get addCardCodeValidation => 'يرجى إدخال الرمز';

  @override
  String get addCardIconLabel => 'أيقونة البطاقة';

  @override
  String get addCardColorLabel => 'لون البطاقة';

  @override
  String get addCardSave => 'حفظ البطاقة';

  @override
  String get addCardLinkNotPass =>
      'لم تُرجِع الرابط ملف تمرير صالحًا. سيتم استخدامه كرمز.';

  @override
  String addCardFailedFetch(Object status) {
    return 'فشل جلب الرابط: $status';
  }

  @override
  String addCardDownloadError(Object error) {
    return 'خطأ في التنزيل: $error';
  }

  @override
  String get scannerTitle => 'مسح رمز QR';

  @override
  String get cardUpdated => 'تم تحديث البطاقة';

  @override
  String get cardUpdateFailed => 'لا توجد تحديثات أو فشل التحديث';

  @override
  String get cardDeleteTitle => 'حذف البطاقة';

  @override
  String get cardDeleteConfirm => 'هل أنت متأكد أنك تريد إزالة هذه البطاقة؟';

  @override
  String get cardDeleteCancel => 'إلغاء';

  @override
  String get cardDeleteAction => 'حذف';

  @override
  String get cardShowCodeHint =>
      'اعرض هذا الرمز عند الدفع\nاسحب لأسفل لتحديث الرصيد';

  @override
  String barcodeError(Object error) {
    return 'خطأ في إنشاء الباركود: $error';
  }

  @override
  String get qrCodeLabel => 'رمز QR';

  @override
  String get pointsLabelDefault => 'النقاط';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageChineseSimplified => 'الصينية المبسطة';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get languageRussian => 'الروسية';

  @override
  String get languageArabic => 'العربية';
}
