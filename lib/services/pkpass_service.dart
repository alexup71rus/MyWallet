import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/wallet_card.dart';

class PkpassService {
  static Future<WalletCard?> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final bytes = await file.readAsBytes();
      return _parseBytes(bytes);
    } catch (_) {
      return null;
    }
  }

  Future<WalletCard?> parsePkpass(Uint8List bytes) async {
    return _parseBytes(bytes);
  }

  static Future<WalletCard?> _parseBytes(Uint8List bytes) async {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final passEntry = archive.files.firstWhere(
        (f) => f.name.toLowerCase() == 'pass.json',
      );

      final passJson = utf8.decode(passEntry.content as List<int>);
      final Map<String, dynamic> data = jsonDecode(passJson);

      final barcodeData = _extractBarcode(data);
      final code = barcodeData?.message;
      if (code == null || code.isEmpty) return null;

      final name = _extractName(data);
      final cardType = _extractCardType(data);
      final colorValue =
          _extractColor(data) ?? const ColorDefaults().defaultColor;
      final foregroundColor = _parseColorString(
        data['foregroundColor']?.toString() ?? '',
      );

      final points = _extractPoints(data);
      final locations = _extractLocations(data);

      final id =
          (data['serialNumber'] ?? data['authenticationToken'])?.toString() ??
          '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}';

      String? iconPath;
      try {
        final iconFile = _findIconFile(archive);
        if (iconFile != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = '${id}_icon.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(iconFile.content as List<int>);
          iconPath = file.path;
        }
      } catch (e) {
        print('Error extracting icon: $e');
      }

      return WalletCard(
        id: id,
        code: code,
        displayCode: barcodeData?.altText ?? code,
        name: name,
        colorValue: colorValue,
        dateAdded: DateTime.now(),
        cardType: cardType,
        pointsLabel: points?.label,
        pointsValue: points?.value,
        webServiceURL: data['webServiceURL']?.toString(),
        authenticationToken: data['authenticationToken']?.toString(),
        passTypeIdentifier: data['passTypeIdentifier']?.toString(),
        format: barcodeData?.format ?? 'qrCode',
        iconPath: iconPath,
        foregroundColor: foregroundColor,
        locations: locations,
      );
    } catch (_) {
      return null;
    }
  }

  static ArchiveFile? _findIconFile(Archive archive) {
    // Prefer higher resolution icons
    final priorities = ['icon@3x.png', 'icon@2x.png', 'icon.png'];

    for (final name in priorities) {
      try {
        return archive.files.firstWhere(
          (f) => f.name.toLowerCase() == name.toLowerCase(),
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Attempts to update the card from the web service.
  /// Returns a new WalletCard if successful, or null otherwise.
  static Future<WalletCard?> updatePass(WalletCard card) async {
    if (card.webServiceURL == null ||
        card.authenticationToken == null ||
        card.passTypeIdentifier == null) {
      return null;
    }

    try {
      final client = HttpClient();
      // Ensure slash at end of webServiceURL if needed, though standard says it includes it usually
      var baseUrl = card.webServiceURL!;
      if (!baseUrl.endsWith('/')) baseUrl += '/';

      final url = Uri.parse(
        '${baseUrl}v1/passes/${card.passTypeIdentifier}/${card.id}',
      );

      final request = await client.getUrl(url);
      request.headers.add(
        'Authorization',
        'ApplePass ${card.authenticationToken}',
      );

      // If we had a 'If-Modified-Since' we could use it, but we force fetch for now.

      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await response.expand((x) => x).toList();
        // The response is the .pkpass file (zip)
        return _parseBytes(Uint8List.fromList(bytes));
      }
    } catch (e) {
      print('Error updating pass: $e');
    }
    return null;
  }

  static BarcodeData? _extractBarcode(Map<String, dynamic> data) {
    final barcode = data['barcode'];
    if (barcode is Map && barcode['message'] != null) {
      return BarcodeData(
        message: barcode['message'].toString(),
        altText: barcode['altText']?.toString(),
        format: _mapPkBarcodeFormat(barcode['format']?.toString()),
      );
    }
    // Apple sometimes puts barcode in top level if it's legacy, but usually inside 'barcode' or 'barcodes'
    // Actually standard is 'barcode' (dict) or 'barcodes' (array of dicts)

    final barcodes = data['barcodes'];
    if (barcodes is List && barcodes.isNotEmpty) {
      final first = barcodes.first;
      if (first is Map && first['message'] != null) {
        return BarcodeData(
          message: first['message'].toString(),
          altText: first['altText']?.toString(),
          format: _mapPkBarcodeFormat(first['format']?.toString()),
        );
      }
    }

    return null;
  }

  static String _mapPkBarcodeFormat(String? pkFormat) {
    switch (pkFormat) {
      case 'PKBarcodeFormatQR':
        return 'qrCode';
      case 'PKBarcodeFormatPDF417':
        return 'pdf417';
      case 'PKBarcodeFormatAztec':
        return 'aztec';
      case 'PKBarcodeFormatCode128':
        return 'code128';
      default:
        return 'qrCode';
    }
  }

  static String _extractName(Map<String, dynamic> data) {
    final logoText = data['logoText']?.toString().trim();
    if (logoText != null && logoText.isNotEmpty && logoText != ' ') {
      return logoText;
    }

    return (data['organizationName'] ?? data['description'] ?? 'Card')
        .toString();
  }

  static String _extractCardType(Map<String, dynamic> data) {
    if (data.containsKey('storeCard')) return 'Loyalty Card';
    if (data.containsKey('coupon')) return 'Coupon';
    if (data.containsKey('eventTicket')) return 'Ticket';
    if (data.containsKey('boardingPass')) return 'Boarding Pass';
    if (data.containsKey('generic')) return 'Membership Card';
    return 'Loyalty Card';
  }

  static int? _extractColor(Map<String, dynamic> data) {
    // 1. Try background color first
    final background = _parseColorString(
      data['backgroundColor']?.toString() ?? '',
    );

    // If we have a valid background color
    if (background != null) {
      // If it's NOT white, use it
      if (!_isNearWhite(background)) {
        return background;
      }
      // If it IS white, return a "noble white" (light greyish) instead of pure white
      // or falling back to foreground immediately.
      return 0xFFF5F5F5; // Colors.grey[100]
    }

    // 2. Fallback to foreground if background was missing/invalid
    final foreground = _parseColorString(
      data['foregroundColor']?.toString() ?? '',
    );
    if (foreground != null) return foreground;

    final label = _parseColorString(data['labelColor']?.toString() ?? '');
    return label ?? background;
  }

  static int? _parseColorString(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('#')) {
      final hex = trimmed.substring(1);
      if (hex.length == 6) {
        return int.parse('FF$hex', radix: 16);
      }
      if (hex.length == 8) {
        return int.parse(hex, radix: 16);
      }
    }

    final rgbMatch = RegExp(
      r'rgb\s*\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*\)',
    ).firstMatch(trimmed.toLowerCase());
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!);
      final g = int.parse(rgbMatch.group(2)!);
      final b = int.parse(rgbMatch.group(3)!);
      return (0xFF << 24) | (r << 16) | (g << 8) | b;
    }

    return null;
  }

  static PointsData? _extractPoints(Map<String, dynamic> data) {
    final cardData =
        data['storeCard'] ??
        data['coupon'] ??
        data['generic'] ??
        data['eventTicket'] ??
        data['boardingPass'];

    if (cardData is! Map) return null;

    final headerFields = cardData['headerFields'];
    if (headerFields is! List || headerFields.isEmpty) return null;

    for (final field in headerFields) {
      if (field is! Map) continue;

      final key = field['key']?.toString().toLowerCase() ?? '';
      final label = field['label']?.toString().toLowerCase() ?? '';

      if (key == 'clientpoints' ||
          key.contains('balance') ||
          key.contains('points') ||
          key.contains('bonus') ||
          label.contains('баланс') ||
          label.contains('balance')) {
        String displayLabel = field['label']?.toString() ?? 'Points';
        if (displayLabel.toLowerCase().contains('баланс')) {
          displayLabel = 'Balance';
        }

        final value = field['value']?.toString();
        if (value == null || value.isEmpty) continue;

        return PointsData(label: displayLabel, value: value);
      }
    }

    return null;
  }

  static List<PassLocation> _extractLocations(Map<String, dynamic> data) {
    final rawLocations = data['locations'];
    if (rawLocations is! List) return const [];

    final locations = <PassLocation>[];
    for (final entry in rawLocations) {
      if (entry is Map) {
        final lat = _toDouble(entry['latitude']);
        final lon = _toDouble(entry['longitude']);
        if (lat != null && lon != null) {
          locations.add(
            PassLocation(
              latitude: lat,
              longitude: lon,
              relevantText: entry['relevantText']?.toString(),
            ),
          );
        }
      }
    }

    return locations;
  }

  static bool _isNearWhite(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return r > 240 && g > 240 && b > 240;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class ColorDefaults {
  const ColorDefaults();

  int get defaultColor => 0xFF3F51B5;
}

class PointsData {
  final String label;
  final String value;

  const PointsData({required this.label, required this.value});
}

class BarcodeData {
  final String message;
  final String? altText;
  final String format;

  const BarcodeData({
    required this.message,
    this.altText,
    this.format = 'qrCode',
  });
}
