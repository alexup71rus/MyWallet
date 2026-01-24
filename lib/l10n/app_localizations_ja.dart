// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マイウォレット';

  @override
  String get homeWalletEmptyTitle => 'ウォレットは空です';

  @override
  String get homeWalletEmptySubtitle => '最初のポイントカードを追加しましょう';

  @override
  String get homeAddCard => 'カードを追加';

  @override
  String homeFailedImport(Object error) {
    return 'カードのインポートに失敗しました: $error';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsGoogleDriveSection => 'Google Drive バックアップ';

  @override
  String get settingsLocalBackupSection => 'ローカルバックアップ';

  @override
  String get settingsAboutSection => '情報';

  @override
  String get settingsNotSignedIn => '未ログイン';

  @override
  String get settingsSignIn => 'ログイン';

  @override
  String get settingsBackupToDrive => 'Drive にバックアップ';

  @override
  String get settingsRestoreFromDrive => 'Drive から復元';

  @override
  String get settingsExportToFile => 'ファイルにエクスポート';

  @override
  String get settingsImportFromFile => 'ファイルからインポート';

  @override
  String get settingsImportPkpass => '.pkpass カードをインポート';

  @override
  String get settingsMaxBrightnessTitle => 'カード表示時の最大輝度';

  @override
  String get settingsMaxBrightnessSubtitle => 'QRコード表示時に画面の明るさを上げます';

  @override
  String get settingsNearbySortingTitle => '近くのパスの並び替え';

  @override
  String get settingsNearbySortingSubtitle => '位置情報で距離順に並べ替えます';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsLanguageSection => '言語';

  @override
  String get settingsLanguageTitle => 'アプリの言語';

  @override
  String get settingsLanguageChoose => '言語を選択';

  @override
  String get settingsLanguageSave => '続行';

  @override
  String get settingsLanguageCancel => 'キャンセル';

  @override
  String get snackbarEnableLocationServices =>
      '近くの並び替えを使うには位置情報サービスを有効にしてください。';

  @override
  String get snackbarLocationDenied => '位置情報の権限が拒否されました。';

  @override
  String get snackbarLocationBlocked => '位置情報の権限がブロックされています。設定で有効にしてください。';

  @override
  String snackbarSignInFailed(Object error) {
    return 'ログインに失敗しました: $error';
  }

  @override
  String get snackbarBackupUploaded => 'バックアップをアップロードしました！';

  @override
  String snackbarBackupFailed(Object error) {
    return 'バックアップに失敗しました: $error';
  }

  @override
  String get snackbarNoBackupFound => 'バックアップが見つかりません。';

  @override
  String get snackbarRestoreSuccessful => '復元しました！';

  @override
  String get snackbarInvalidBackupFormat => 'バックアップ形式が無効です。';

  @override
  String snackbarRestoreFailed(Object error) {
    return '復元に失敗しました: $error';
  }

  @override
  String snackbarExportFailed(Object error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get snackbarImportSuccessful => 'インポートしました！';

  @override
  String get snackbarInvalidFileFormat => 'ファイル形式が無効です。';

  @override
  String snackbarDecodeFailed(Object message) {
    return 'JSONの解析に失敗しました: $message';
  }

  @override
  String snackbarImportFailed(Object error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get snackbarPkpassParseFailed => '.pkpass ファイルの解析に失敗しました。';

  @override
  String get snackbarPkpassImported => '.pkpass からカードをインポートしました';

  @override
  String snackbarPkpassImportFailed(Object error) {
    return 'PKPASS のインポートに失敗しました: $error';
  }

  @override
  String get backupShareText => 'MyWallet バックアップ';

  @override
  String get addCardTitle => '新しいカードを追加';

  @override
  String get addCardStorePlaceholder => '店舗名';

  @override
  String get addCardCodePlaceholder => '0000 0000 0000';

  @override
  String get addCardServiceNameLabel => 'サービス名';

  @override
  String get addCardServiceNameHint => '例：スターバックス、Tesco';

  @override
  String get addCardNameValidation => '名前を入力してください';

  @override
  String get addCardTypeLabel => 'カードタイプ';

  @override
  String get cardTypeLoyalty => 'ポイントカード';

  @override
  String get cardTypeGift => 'ギフトカード';

  @override
  String get cardTypeMembership => '会員カード';

  @override
  String get cardTypeDiscount => '割引カード';

  @override
  String get cardTypeClub => 'クラブカード';

  @override
  String get addCardCodeLabel => 'カード番号';

  @override
  String get addCardCodeHint => 'スキャンまたは入力';

  @override
  String get addCardCodeValidation => 'コードを入力してください';

  @override
  String get addCardIconLabel => 'カードアイコン';

  @override
  String get addCardColorLabel => 'カードカラー';

  @override
  String get addCardSave => 'カードを保存';

  @override
  String get addCardLinkNotPass => 'リンクから有効なパスファイルが取得できませんでした。コードとして使用します。';

  @override
  String addCardFailedFetch(Object status) {
    return 'リンクの取得に失敗しました: $status';
  }

  @override
  String addCardDownloadError(Object error) {
    return 'ダウンロードエラー: $error';
  }

  @override
  String get scannerTitle => 'QRコードをスキャン';

  @override
  String get cardUpdated => 'カードを更新しました';

  @override
  String get cardUpdateFailed => '更新がありません、または更新に失敗しました';

  @override
  String get cardDeleteTitle => 'カードを削除';

  @override
  String get cardDeleteConfirm => 'このカードを削除してもよろしいですか？';

  @override
  String get cardDeleteCancel => 'キャンセル';

  @override
  String get cardDeleteAction => '削除';

  @override
  String get cardShowCodeHint => 'レジでこのコードを提示してください\n下に引いて残高を更新';

  @override
  String barcodeError(Object error) {
    return 'バーコードの生成エラー: $error';
  }

  @override
  String get qrCodeLabel => 'QRコード';

  @override
  String get pointsLabelDefault => 'ポイント';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageChineseSimplified => '中国語（簡体）';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get languageArabic => 'アラビア語';
}
