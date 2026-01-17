import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<GoogleSignInAccount?> signInSilently() async {
    return _googleSignIn.signInSilently();
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
  }

  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  Future<void> uploadBackup(String jsonContent) async {
    final api = await _getDriveApi();
    if (api == null) throw Exception("Not authenticated");

    const fileName = "wallet_backup.json";

    // Check if file exists
    final fileList = await api.files.list(
      q: "name = '$fileName' and trashed = false",
      $fields: "files(id, name)",
    );

    final fileToUpload = drive.File()..name = fileName;
    final media = drive.Media(
      Stream.value(utf8.encode(jsonContent)),
      utf8.encode(jsonContent).length,
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Update existing
      final fileId = fileList.files!.first.id!;
      await api.files.update(fileToUpload, fileId, uploadMedia: media);
    } else {
      // Create new
      await api.files.create(fileToUpload, uploadMedia: media);
    }
  }

  Future<String?> restoreBackup() async {
    final api = await _getDriveApi();
    if (api == null) throw Exception("Not authenticated");

    const fileName = "wallet_backup.json";

    final fileList = await api.files.list(
      q: "name = '$fileName' and trashed = false",
      $fields: "files(id, name)",
    );

    if (fileList.files == null || fileList.files!.isEmpty) {
      return null;
    }

    final fileId = fileList.files!.first.id!;
    final media =
        await api.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final stream = media.stream;
    final content = await utf8.decodeStream(stream);
    return content;
  }
}
