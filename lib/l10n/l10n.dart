import 'package:flutter/material.dart';
import 'package:mywallet/l10n/app_localizations.dart';

class L10n {
  static const localeKey = 'app_locale';

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale('ja'),
    Locale('ar'),
  ];

  static String localeTag(Locale locale) => locale.toLanguageTag();

  static Locale parseLocale(String tag) {
    final parts = tag.split('-');
    if (parts.length == 1) return Locale(parts[0]);
    if (parts.length == 2) {
      final second = parts[1];
      if (second.length == 4) {
        return Locale.fromSubtags(languageCode: parts[0], scriptCode: second);
      }
      return Locale(parts[0], second);
    }
    if (parts.length >= 3) {
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
        countryCode: parts[2],
      );
    }
    return Locale(parts[0]);
  }

  static String languageName(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.languageEnglish;
      case 'ru':
        return l10n.languageRussian;
      case 'zh':
        return l10n.languageChineseSimplified;
      case 'ja':
        return l10n.languageJapanese;
      case 'ar':
        return l10n.languageArabic;
      default:
        return locale.toLanguageTag();
    }
  }

  static const cardTypeKeys = <String>[
    'loyalty',
    'gift',
    'membership',
    'discount',
    'club',
  ];

  static String normalizeCardTypeKey(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'loyalty':
      case 'loyalty card':
        return 'loyalty';
      case 'gift':
      case 'gift card':
        return 'gift';
      case 'membership':
      case 'membership card':
        return 'membership';
      case 'discount':
      case 'discount card':
        return 'discount';
      case 'club':
      case 'club card':
        return 'club';
      default:
        return value;
    }
  }

  static String cardTypeLabel(AppLocalizations l10n, String cardType) {
    switch (normalizeCardTypeKey(cardType)) {
      case 'loyalty':
        return l10n.cardTypeLoyalty;
      case 'gift':
        return l10n.cardTypeGift;
      case 'membership':
        return l10n.cardTypeMembership;
      case 'discount':
        return l10n.cardTypeDiscount;
      case 'club':
        return l10n.cardTypeClub;
      default:
        return cardType;
    }
  }
}
