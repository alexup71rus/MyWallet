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

  static List<PassLocation> decodeLocations(dynamic raw) {
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
}

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
