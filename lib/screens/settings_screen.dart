import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/storage_service.dart';
import '../services/google_drive_service.dart';
import '../services/pkpass_service.dart';
import '../services/locale_service.dart';
import '../l10n/l10n.dart';
import '../widgets/language_picker.dart';
import '../models/wallet_card.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataChanged;

  const SettingsScreen({super.key, required this.onDataChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final GoogleDriveService _driveService = GoogleDriveService();
  GoogleSignInAccount? _currentUser;
  bool _isLoading = false;
  bool _isCheckingSignIn = true;
  bool _maxBrightness = true;
  bool _proximitySortingEnabled = false;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    _driveService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
    });
    _checkSignIn();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _checkSignIn() async {
    await _driveService.signInSilently();
    if (mounted) {
      setState(() {
        _isCheckingSignIn = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxBrightness = prefs.getBool('max_brightness') ?? true;
      _proximitySortingEnabled =
          prefs.getBool('proximity_sorting_enabled') ?? false;
    });
  }

  Future<void> _toggleBrightness(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('max_brightness', value);
    setState(() {
      _maxBrightness = value;
    });
  }

  Future<void> _toggleProximitySorting(bool value) async {
    if (!value) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('proximity_sorting_enabled', false);
      setState(() {
        _proximitySortingEnabled = false;
      });
      widget.onDataChanged();
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarEnableLocationServices,
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showSnackBar(AppLocalizations.of(context)!.snackbarLocationDenied);
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(AppLocalizations.of(context)!.snackbarLocationBlocked);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('proximity_sorting_enabled', true);
    setState(() {
      _proximitySortingEnabled = true;
    });
    widget.onDataChanged();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _driveService.signIn();
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarSignInFailed(e.toString()),
      );
    }
  }

  Future<void> _handleGoogleSignOut() async {
    await _driveService.signOut();
  }

  Future<void> _backupToDrive() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      final cards = await _storageService.loadCards();
      final jsonStr = jsonEncode(cards.map((e) => e.toJson()).toList());
      await _driveService.uploadBackup(jsonStr);
      _showSnackBar(AppLocalizations.of(context)!.snackbarBackupUploaded);
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarBackupFailed(e.toString()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromDrive() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);
    try {
      final jsonContent = await _driveService.restoreBackup();
      if (jsonContent == null) {
        _showSnackBar(AppLocalizations.of(context)!.snackbarNoBackupFound);
        return;
      }

      final dynamic decoded = jsonDecode(jsonContent);
      if (_storageService.validateBackupData(decoded)) {
        final List<dynamic> list = decoded as List<dynamic>;
        final newCards = list.map((e) => WalletCard.fromJson(e)).toList();
        await _storageService.saveCards(newCards);
        widget.onDataChanged();
        _showSnackBar(AppLocalizations.of(context)!.snackbarRestoreSuccessful);
      } else {
        _showSnackBar(
          AppLocalizations.of(context)!.snackbarInvalidBackupFormat,
        );
      }
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarRestoreFailed(e.toString()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportLocal() async {
    try {
      final cards = await _storageService.loadCards();
      final jsonStr = jsonEncode(cards.map((e) => e.toJson()).toList());

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/wallet_backup.json');
      await file.writeAsString(jsonStr, encoding: utf8);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: AppLocalizations.of(context)!.backupShareText);
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarExportFailed(e.toString()),
      );
    }
  }

  Future<void> _importLocal() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString(encoding: utf8);

        try {
          final dynamic decoded = jsonDecode(jsonStr);

          if (_storageService.validateBackupData(decoded)) {
            final List<dynamic> list = decoded as List<dynamic>;
            final newCards = list.map((e) => WalletCard.fromJson(e)).toList();
            await _storageService.saveCards(newCards);
            widget.onDataChanged();
            _showSnackBar(
              AppLocalizations.of(context)!.snackbarImportSuccessful,
            );
          } else {
            _showSnackBar(
              AppLocalizations.of(context)!.snackbarInvalidFileFormat,
            );
          }
        } on FormatException catch (e) {
          _showSnackBar(
            AppLocalizations.of(context)!.snackbarDecodeFailed(e.message),
          );
        }
      }
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarImportFailed(e.toString()),
      );
    }
  }

  Future<void> _importPkpass() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pkpass'],
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path == null) return;

        final card = await PkpassService.parseFile(path);
        if (card == null) {
          _showSnackBar(
            AppLocalizations.of(context)!.snackbarPkpassParseFailed,
          );
          return;
        }

        final cards = await _storageService.loadCards();
        final newCards = List<WalletCard>.from(cards)..insert(0, card);
        await _storageService.saveCards(newCards);
        widget.onDataChanged();
        _showSnackBar(AppLocalizations.of(context)!.snackbarPkpassImported);
      }
    } catch (e) {
      _showSnackBar(
        AppLocalizations.of(context)!.snackbarPkpassImportFailed(e.toString()),
      );
    }
  }

  Future<void> _pickLanguage() async {
    final selected = await showLanguagePicker(context, forceSelection: false);
    if (selected != null && mounted) {
      await LocaleService.setLocale(selected);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        LocaleService.locale.value ?? Localizations.localeOf(context);
    final user = _currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.settingsLanguageSection,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.settingsLanguageTitle),
                  subtitle: Text(L10n.languageName(l10n, currentLocale)),
                  onTap: _pickLanguage,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.settingsGoogleDriveSection,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (_isCheckingSignIn)
                  ..._buildDriveSkeletonItems()
                else ...[
                  if (user != null)
                    ListTile(
                      leading: GoogleUserCircleAvatar(identity: user),
                      title: Text(user.displayName ?? ''),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: _handleGoogleSignOut,
                      ),
                    )
                  else
                    ListTile(
                      leading: const Icon(Icons.account_circle),
                      title: Text(l10n.settingsNotSignedIn),
                      trailing: ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        child: Text(l10n.settingsSignIn),
                      ),
                    ),
                  if (user != null) ...[
                    ListTile(
                      leading: const Icon(Icons.cloud_upload),
                      title: Text(l10n.settingsBackupToDrive),
                      onTap: _backupToDrive,
                    ),
                    ListTile(
                      leading: const Icon(Icons.cloud_download),
                      title: Text(l10n.settingsRestoreFromDrive),
                      onTap: _restoreFromDrive,
                    ),
                  ],
                ],
                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.settingsLocalBackupSection,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.settingsExportToFile),
                  onTap: _exportLocal,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.settingsImportFromFile),
                  onTap: _importLocal,
                ),
                ListTile(
                  leading: const Icon(Icons.wallet),
                  title: Text(l10n.settingsImportPkpass),
                  onTap: _importPkpass,
                ),
                Tooltip(
                  message: l10n.settingsMaxBrightnessSubtitle,
                  triggerMode: TooltipTriggerMode.longPress,
                  child: SwitchListTile(
                    title: Text(l10n.settingsMaxBrightnessTitle),
                    secondary: const Icon(Icons.brightness_auto),
                    value: _maxBrightness,
                    onChanged: _toggleBrightness,
                  ),
                ),
                Tooltip(
                  message: l10n.settingsNearbySortingSubtitle,
                  triggerMode: TooltipTriggerMode.longPress,
                  child: SwitchListTile(
                    title: Text(l10n.settingsNearbySortingTitle),
                    secondary: const Icon(Icons.location_on_outlined),
                    value: _proximitySortingEnabled,
                    onChanged: _toggleProximitySorting,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.settingsAboutSection,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.settingsVersion),
                  trailing: Text(_appVersion ?? '—'),
                ),
              ],
            ),
    );
  }

  /// Builds a simple skeleton placeholder for Google Drive items.
  List<Widget> _buildDriveSkeletonItems() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);

    return [
      ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
      ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    ];
  }
}
