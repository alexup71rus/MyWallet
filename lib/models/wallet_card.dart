class WalletCard {
  final String id;
  final String code;
  final String? displayCode;
  final String name;
  final int colorValue;
  final int? iconPoint;
  final DateTime dateAdded;
  final String cardType;
  final String? pointsLabel;
  final String? pointsValue;
  final String? webServiceURL;
  final String? authenticationToken;
  final String? passTypeIdentifier;
  final String format;
  final String? iconPath;
  final int? foregroundColor;
  final List<PassLocation> locations;

  WalletCard({
    required this.id,
    required this.code,
    this.displayCode,
    required this.name,
    required this.colorValue,
    this.iconPoint,
    required this.dateAdded,
    this.cardType = 'Loyalty Card',
    this.pointsLabel,
    this.pointsValue,
    this.webServiceURL,
    this.authenticationToken,
    this.passTypeIdentifier,
    this.format = 'qrCode',
    this.iconPath,
    this.foregroundColor,
    this.locations = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    if (displayCode != null) 'displayCode': displayCode,
    'name': name,
    'colorValue': colorValue,
    if (iconPoint != null) 'iconPoint': iconPoint,
    'dateAdded': dateAdded.toIso8601String(),
    'cardType': cardType,
    if (pointsLabel != null) 'pointsLabel': pointsLabel,
    if (pointsValue != null) 'pointsValue': pointsValue,
    if (webServiceURL != null) 'webServiceURL': webServiceURL,
    if (authenticationToken != null) 'authenticationToken': authenticationToken,
    if (passTypeIdentifier != null) 'passTypeIdentifier': passTypeIdentifier,
    'format': format,
    if (iconPath != null) 'iconPath': iconPath,
    if (foregroundColor != null) 'foregroundColor': foregroundColor,
    if (locations.isNotEmpty)
      'locations': locations.map((e) => e.toJson()).toList(),
  };

  factory WalletCard.fromJson(Map<String, dynamic> json) => WalletCard(
    id: json['id'],
    code: json['code'],
    displayCode: json['displayCode'],
    name: json['name'],
    colorValue: json['colorValue'],
    iconPoint: json['iconPoint'],
    dateAdded: json['dateAdded'] != null
        ? DateTime.parse(json['dateAdded'])
        : DateTime.now(),
    cardType: json['cardType'] ?? 'Loyalty Card',
    pointsLabel: json['pointsLabel'],
    pointsValue: json['pointsValue'],
    webServiceURL: json['webServiceURL'],
    authenticationToken: json['authenticationToken'],
    passTypeIdentifier: json['passTypeIdentifier'],
    format: json['format'] ?? 'qrCode',
    iconPath: json['iconPath'],
    foregroundColor: json['foregroundColor'],
    locations: _decodeLocations(json['locations']),
  );
}

class PassLocation {
  final double latitude;
  final double longitude;
  final String? relevantText;

  const PassLocation({
    required this.latitude,
    required this.longitude,
    this.relevantText,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    if (relevantText != null) 'relevantText': relevantText,
  };

  factory PassLocation.fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['latitude']);
    final lon = _toDouble(json['longitude']);

    return PassLocation(
      latitude: lat ?? 0,
      longitude: lon ?? 0,
      relevantText: json['relevantText']?.toString(),
    );
  }
}

List<PassLocation> _decodeLocations(dynamic raw) {
  if (raw is! List) return const [];

  final locations = <PassLocation>[];
  for (final item in raw) {
    if (item is Map<String, dynamic>) {
      final lat = _toDouble(item['latitude']);
      final lon = _toDouble(item['longitude']);
      if (lat != null && lon != null) {
        locations.add(
          PassLocation(
            latitude: lat,
            longitude: lon,
            relevantText: item['relevantText']?.toString(),
          ),
        );
      }
    } else if (item is Map) {
      final lat = _toDouble(item['latitude']);
      final lon = _toDouble(item['longitude']);
      if (lat != null && lon != null) {
        locations.add(
          PassLocation(
            latitude: lat,
            longitude: lon,
            relevantText: item['relevantText']?.toString(),
          ),
        );
      }
    }
  }

  return locations;
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
