import 'package:flutter/services.dart';
import 'dart:io';

class IntentHandlerService {
  static const MethodChannel _channel = MethodChannel('com.example.mywallet/intent');

  /// Get the initial intent data when app is opened via share/open with
  static Future<String?> getInitialIntentData() async {
    try {
      final String? filePath = await _channel.invokeMethod('getInitialIntent');
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Listen for new intents when app is already running
  static void listenForIntents(Function(String) onFileReceived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewIntent') {
        final String? filePath = call.arguments as String?;
        if (filePath != null) {
          onFileReceived(filePath);
        }
      }
    });
  }
}
