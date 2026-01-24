import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n.dart';

class LocaleService {
  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final tag = prefs.getString(L10n.localeKey);
    if (tag != null && tag.isNotEmpty) {
      locale.value = L10n.parseLocale(tag);
    }
  }

  static Future<void> setLocale(Locale value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(L10n.localeKey, L10n.localeTag(value));
    locale.value = value;
  }

  static Future<bool> isLocaleSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(L10n.localeKey);
  }
}
