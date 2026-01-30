import 'pass_location.dart';

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
  final bool? isFavorite;
  final bool isDemo;

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
    this.isFavorite,
    this.isDemo = false,
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
    'isFavorite': isFavorite == true,
    'isDemo': isDemo,
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
    locations: PassLocation.decodeLocations(json['locations']),
    isFavorite: json['isFavorite'] == true,
    isDemo: json['isDemo'] == true,
  );

  WalletCard copyWith({bool? isFavorite, bool? isDemo}) => WalletCard(
    id: id,
    code: code,
    displayCode: displayCode,
    name: name,
    colorValue: colorValue,
    iconPoint: iconPoint,
    dateAdded: dateAdded,
    cardType: cardType,
    pointsLabel: pointsLabel,
    pointsValue: pointsValue,
    webServiceURL: webServiceURL,
    authenticationToken: authenticationToken,
    passTypeIdentifier: passTypeIdentifier,
    format: format,
    iconPath: iconPath,
    foregroundColor: foregroundColor,
    locations: locations,
    isFavorite: isFavorite ?? this.isFavorite ?? false,
    isDemo: isDemo ?? this.isDemo,
  );
}
