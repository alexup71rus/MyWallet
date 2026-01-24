// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '我的钱包';

  @override
  String get homeWalletEmptyTitle => '你的钱包是空的';

  @override
  String get homeWalletEmptySubtitle => '添加第一张会员卡';

  @override
  String get homeAddCard => '添加卡片';

  @override
  String homeFailedImport(Object error) {
    return '导入卡片失败：$error';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsGoogleDriveSection => 'Google Drive 备份';

  @override
  String get settingsLocalBackupSection => '本地备份';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsNotSignedIn => '未登录';

  @override
  String get settingsSignIn => '登录';

  @override
  String get settingsBackupToDrive => '备份到 Drive';

  @override
  String get settingsRestoreFromDrive => '从 Drive 恢复';

  @override
  String get settingsExportToFile => '导出到文件';

  @override
  String get settingsImportFromFile => '从文件导入';

  @override
  String get settingsImportPkpass => '导入 .pkpass 卡';

  @override
  String get settingsMaxBrightnessTitle => '查看卡片时最高亮度';

  @override
  String get settingsMaxBrightnessSubtitle => '查看二维码时提高屏幕亮度';

  @override
  String get settingsNearbySortingTitle => '附近卡片排序';

  @override
  String get settingsNearbySortingSubtitle => '使用定位按距离排序';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLanguageSection => '语言';

  @override
  String get settingsLanguageTitle => '应用语言';

  @override
  String get settingsLanguageChoose => '选择语言';

  @override
  String get settingsLanguageSave => '继续';

  @override
  String get settingsLanguageCancel => '取消';

  @override
  String get snackbarEnableLocationServices => '请开启定位服务以使用附近排序。';

  @override
  String get snackbarLocationDenied => '定位权限被拒绝。';

  @override
  String get snackbarLocationBlocked => '定位权限被阻止，请在设置中开启。';

  @override
  String snackbarSignInFailed(Object error) {
    return '登录失败：$error';
  }

  @override
  String get snackbarBackupUploaded => '备份上传成功！';

  @override
  String snackbarBackupFailed(Object error) {
    return '备份失败：$error';
  }

  @override
  String get snackbarNoBackupFound => '未找到备份。';

  @override
  String get snackbarRestoreSuccessful => '恢复成功！';

  @override
  String get snackbarInvalidBackupFormat => '备份格式无效。';

  @override
  String snackbarRestoreFailed(Object error) {
    return '恢复失败：$error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String get snackbarImportSuccessful => '导入成功！';

  @override
  String get snackbarInvalidFileFormat => '文件格式无效。';

  @override
  String snackbarDecodeFailed(Object message) {
    return '无法解析 JSON：$message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String get snackbarPkpassParseFailed => '无法解析 .pkpass 文件。';

  @override
  String get snackbarPkpassImported => '已从 .pkpass 导入卡片';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'PKPASS 导入失败：$error';
  }

  @override
  String get backupShareText => 'MyWallet 备份';

  @override
  String get addCardTitle => '添加新卡';

  @override
  String get addCardStorePlaceholder => '商店名称';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => '服务名称';

  @override
  String get addCardServiceNameHint => '例如 星巴克、Tesco';

  @override
  String get addCardNameValidation => '请输入名称';

  @override
  String get addCardTypeLabel => '卡片类型';

  @override
  String get cardTypeLoyalty => '积分卡';

  @override
  String get cardTypeGift => '礼品卡';

  @override
  String get cardTypeMembership => '会员卡';

  @override
  String get cardTypeDiscount => '折扣卡';

  @override
  String get cardTypeClub => '俱乐部卡';

  @override
  String get addCardCodeLabel => '卡号';

  @override
  String get addCardCodeHint => '扫描或输入卡号';

  @override
  String get addCardCodeValidation => '请输入卡号';

  @override
  String get addCardIconLabel => '卡片图标';

  @override
  String get addCardColorLabel => '卡片颜色';

  @override
  String get addCardSave => '保存卡片';

  @override
  String get addCardLinkNotPass => '链接未返回有效票据文件，已作为代码使用。';

  @override
  String addCardFailedFetch(Object status) {
    return '获取链接失败：$status';
  }

  @override
  String addCardDownloadError(Object error) {
    return '下载错误：$error';
  }

  @override
  String get scannerTitle => '扫描二维码';

  @override
  String get cardUpdated => '卡片更新成功';

  @override
  String get cardUpdateFailed => '没有更新或更新失败';

  @override
  String get cardDeleteTitle => '删除卡片';

  @override
  String get cardDeleteConfirm => '确定要删除此卡片吗？';

  @override
  String get cardDeleteCancel => '取消';

  @override
  String get cardDeleteAction => '删除';

  @override
  String get cardShowCodeHint => '结账时出示此码\n下拉可刷新余额';

  @override
  String barcodeError(Object error) {
    return '生成条码出错：$error';
  }

  @override
  String get qrCodeLabel => '二维码';

  @override
  String get pointsLabelDefault => '积分';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageArabic => '阿拉伯语';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '我的钱包';

  @override
  String get homeWalletEmptyTitle => '你的钱包是空的';

  @override
  String get homeWalletEmptySubtitle => '添加第一张会员卡';

  @override
  String get homeAddCard => '添加卡片';

  @override
  String homeFailedImport(Object error) {
    return '导入卡片失败：$error';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsGoogleDriveSection => 'Google Drive 备份';

  @override
  String get settingsLocalBackupSection => '本地备份';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsNotSignedIn => '未登录';

  @override
  String get settingsSignIn => '登录';

  @override
  String get settingsBackupToDrive => '备份到 Drive';

  @override
  String get settingsRestoreFromDrive => '从 Drive 恢复';

  @override
  String get settingsExportToFile => '导出到文件';

  @override
  String get settingsImportFromFile => '从文件导入';

  @override
  String get settingsImportPkpass => '导入 .pkpass 卡';

  @override
  String get settingsMaxBrightnessTitle => '查看卡片时最高亮度';

  @override
  String get settingsMaxBrightnessSubtitle => '查看二维码时提高屏幕亮度';

  @override
  String get settingsNearbySortingTitle => '附近卡片排序';

  @override
  String get settingsNearbySortingSubtitle => '使用定位按距离排序';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLanguageSection => '语言';

  @override
  String get settingsLanguageTitle => '应用语言';

  @override
  String get settingsLanguageChoose => '选择语言';

  @override
  String get settingsLanguageSave => '继续';

  @override
  String get settingsLanguageCancel => '取消';

  @override
  String get snackbarEnableLocationServices => '请开启定位服务以使用附近排序。';

  @override
  String get snackbarLocationDenied => '定位权限被拒绝。';

  @override
  String get snackbarLocationBlocked => '定位权限被阻止，请在设置中开启。';

  @override
  String snackbarSignInFailed(Object error) {
    return '登录失败：$error';
  }

  @override
  String get snackbarBackupUploaded => '备份上传成功！';

  @override
  String snackbarBackupFailed(Object error) {
    return '备份失败：$error';
  }

  @override
  String get snackbarNoBackupFound => '未找到备份。';

  @override
  String get snackbarRestoreSuccessful => '恢复成功！';

  @override
  String get snackbarInvalidBackupFormat => '备份格式无效。';

  @override
  String snackbarRestoreFailed(Object error) {
    return '恢复失败：$error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String get snackbarImportSuccessful => '导入成功！';

  @override
  String get snackbarInvalidFileFormat => '文件格式无效。';

  @override
  String snackbarDecodeFailed(Object message) {
    return '无法解析 JSON：$message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return '导入失败：$error';
  }

  @override
  String get snackbarPkpassParseFailed => '无法解析 .pkpass 文件。';

  @override
  String get snackbarPkpassImported => '已从 .pkpass 导入卡片';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'PKPASS 导入失败：$error';
  }

  @override
  String get backupShareText => 'MyWallet 备份';

  @override
  String get addCardTitle => '添加新卡';

  @override
  String get addCardStorePlaceholder => '商店名称';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => '服务名称';

  @override
  String get addCardServiceNameHint => '例如 星巴克、Tesco';

  @override
  String get addCardNameValidation => '请输入名称';

  @override
  String get addCardTypeLabel => '卡片类型';

  @override
  String get cardTypeLoyalty => '积分卡';

  @override
  String get cardTypeGift => '礼品卡';

  @override
  String get cardTypeMembership => '会员卡';

  @override
  String get cardTypeDiscount => '折扣卡';

  @override
  String get cardTypeClub => '俱乐部卡';

  @override
  String get addCardCodeLabel => '卡号';

  @override
  String get addCardCodeHint => '扫描或输入卡号';

  @override
  String get addCardCodeValidation => '请输入卡号';

  @override
  String get addCardIconLabel => '卡片图标';

  @override
  String get addCardColorLabel => '卡片颜色';

  @override
  String get addCardSave => '保存卡片';

  @override
  String get addCardLinkNotPass => '链接未返回有效票据文件，已作为代码使用。';

  @override
  String addCardFailedFetch(Object status) {
    return '获取链接失败：$status';
  }

  @override
  String addCardDownloadError(Object error) {
    return '下载错误：$error';
  }

  @override
  String get scannerTitle => '扫描二维码';

  @override
  String get cardUpdated => '卡片更新成功';

  @override
  String get cardUpdateFailed => '没有更新或更新失败';

  @override
  String get cardDeleteTitle => '删除卡片';

  @override
  String get cardDeleteConfirm => '确定要删除此卡片吗？';

  @override
  String get cardDeleteCancel => '取消';

  @override
  String get cardDeleteAction => '删除';

  @override
  String get cardShowCodeHint => '结账时出示此码\n下拉可刷新余额';

  @override
  String barcodeError(Object error) {
    return '生成条码出错：$error';
  }

  @override
  String get qrCodeLabel => '二维码';

  @override
  String get pointsLabelDefault => '积分';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageArabic => '阿拉伯语';
}
