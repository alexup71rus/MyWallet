import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/wallet_card.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static const String _channelId = 'nearby_passes';
  static const String _channelName = 'Nearby passes';
  static const String _channelDescription = 'Notifications for passes near you';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissionsIfNeeded() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    }
  }

  Future<void> showNearbyCardNotification(
    WalletCard card,
    double distanceMeters,
  ) async {
    final distanceLabel = distanceMeters >= 1000
        ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${distanceMeters.toStringAsFixed(0)} m';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      card.id.hashCode,
      'Pass nearby',
      '${card.name} • $distanceLabel away',
      details,
    );
  }
}
