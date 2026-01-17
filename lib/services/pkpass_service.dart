import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:archive/archive.dart';
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

  static WalletCard? _parseBytes(Uint8List bytes) {
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
      final points = _extractPoints(data);

      final id =
          (data['serialNumber'] ?? data['authenticationToken'])?.toString() ??
          '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}';

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
      );
    } catch (_) {
      return null;
    }
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
      );
    }
    if (barcode is Map && barcode['altText'] != null) {
      return BarcodeData(
        message: barcode['altText'].toString(),
        altText: barcode['altText']?.toString(),
      );
    }

    final barcodes = data['barcodes'];
    if (barcodes is List && barcodes.isNotEmpty) {
      final first = barcodes.first;
      if (first is Map && first['message'] != null) {
        return BarcodeData(
          message: first['message'].toString(),
          altText: first['altText']?.toString(),
        );
      }
      if (first is Map && first['altText'] != null) {
        return BarcodeData(
          message: first['altText'].toString(),
          altText: first['altText']?.toString(),
        );
      }
    }

    return null;
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
    final background = _parseColorString(
      data['backgroundColor']?.toString() ?? '',
    );
    if (background != null && !_isNearWhite(background)) {
      return background;
    }

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
    final storeCard = data['storeCard'];
    if (storeCard is! Map) return null;

    final headerFields = storeCard['headerFields'];
    if (headerFields is! List || headerFields.isEmpty) return null;

    Map<dynamic, dynamic>? candidate;
    for (final field in headerFields) {
      if (field is Map) {
        final key = field['key']?.toString().toLowerCase() ?? '';
        final label = field['label']?.toString().toLowerCase() ?? '';
        if (key.contains('points') ||
            key.contains('balance') ||
            label.contains('баланс')) {
          candidate = field.cast<dynamic, dynamic>();
          break;
        }
        candidate ??= field.cast<dynamic, dynamic>();
      }
    }

    if (candidate == null) return null;
    String label = candidate['label']?.toString() ?? 'Points';

    // Force "Balance" if it is Russian "Баланс" or just generally "Balance" requested
    if (label.toLowerCase().contains('баланс')) {
      label = 'Balance';
    }

    final value = candidate['value']?.toString();
    if (value == null || value.isEmpty) return null;

    return PointsData(label: label, value: value);
  }

  static bool _isNearWhite(int argb) {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return r > 240 && g > 240 && b > 240;
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

  const BarcodeData({required this.message, this.altText});
}
