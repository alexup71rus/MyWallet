import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_card.dart';

class StorageService {
  static const String _keyCards = 'wallet_cards';

  Future<List<WalletCard>> loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString(_keyCards);
    if (cardsJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(cardsJson);
      return decoded.map((e) => WalletCard.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCards(List<WalletCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(cards.map((e) => e.toJson()).toList());
    await prefs.setString(_keyCards, encoded);
  }

  bool validateBackupData(dynamic data) {
    if (data is! List) return false;
    if (data.isEmpty) return true; // Empty list is valid backup
    for (var item in data) {
      if (item is! Map<String, dynamic>) return false;
      if (!item.containsKey('id') ||
          !item.containsKey('code') ||
          !item.containsKey('name')) {
        return false;
      }
    }
    return true;
  }
}
