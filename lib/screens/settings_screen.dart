import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/storage_service.dart';
import '../services/google_drive_service.dart';
import '../services/pkpass_service.dart';
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

  @override
  void initState() {
    super.initState();
    _driveService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (mounted) {
        setState(() {
          _currentUser = account;
        });
      }
    });
    _driveService.signInSilently();
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _driveService.signIn();
    } catch (e) {
      _showSnackBar('Sign in failed: $e');
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
      _showSnackBar('Backup uploaded successfully!');
    } catch (e) {
      _showSnackBar('Backup failed: $e');
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
        _showSnackBar('No backup found.');
        return;
      }

      final dynamic decoded = jsonDecode(jsonContent);
      if (_storageService.validateBackupData(decoded)) {
        final List<dynamic> list = decoded as List<dynamic>;
        final newCards = list.map((e) => WalletCard.fromJson(e)).toList();
        await _storageService.saveCards(newCards);
        widget.onDataChanged();
        _showSnackBar('Restore successful!');
      } else {
        _showSnackBar('Invalid backup format.');
      }
    } catch (e) {
      _showSnackBar('Restore failed: $e');
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

      await Share.shareXFiles([XFile(file.path)], text: 'MyWallet Backup');
    } catch (e) {
      _showSnackBar('Export failed: $e');
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
            _showSnackBar('Import successful!');
          } else {
            _showSnackBar('Invalid file format.');
          }
        } on FormatException catch (e) {
          _showSnackBar('Failed to decode JSON: ${e.message}');
        }
      }
    } catch (e) {
      _showSnackBar('Import failed: $e');
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
          _showSnackBar('Failed to parse .pkpass file.');
          return;
        }

        final cards = await _storageService.loadCards();
        final newCards = List<WalletCard>.from(cards)..insert(0, card);
        await _storageService.saveCards(newCards);
        widget.onDataChanged();
        _showSnackBar('Card imported from .pkpass');
      }
    } catch (e) {
      _showSnackBar('PKPASS import failed: $e');
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
    final user = _currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Google Drive Backup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
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
                    title: const Text('Not Signed In'),
                    trailing: ElevatedButton(
                      onPressed: _handleGoogleSignIn,
                      child: const Text('Sign In'),
                    ),
                  ),

                if (user != null) ...[
                  ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: const Text('Backup to Drive'),
                    onTap: _backupToDrive,
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Restore from Drive'),
                    onTap: _restoreFromDrive,
                  ),
                ],

                const Divider(),

                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Local Backup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export to File'),
                  onTap: _exportLocal,
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import from File'),
                  onTap: _importLocal,
                ),
                ListTile(
                  leading: const Icon(Icons.wallet),
                  title: const Text('Import .pkpass Card'),
                  onTap: _importPkpass,
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
              ],
            ),
    );
  }
}
