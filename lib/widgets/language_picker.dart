import 'package:flutter/material.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../services/locale_service.dart';

Future<Locale?> showLanguagePicker(
  BuildContext context, {
  required bool forceSelection,
}) {
  final l10n = AppLocalizations.of(context)!;
  final currentLocale =
      LocaleService.locale.value ?? Localizations.localeOf(context);

  Locale selected = currentLocale;

  return showDialog<Locale>(
    context: context,
    barrierDismissible: !forceSelection,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.settingsLanguageChoose),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final locale in L10n.supportedLocales)
                    RadioListTile<Locale>(
                      value: locale,
                      groupValue: selected,
                      title: Text(L10n.languageName(l10n, locale)),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => selected = value);
                      },
                    ),
                ],
              ),
            ),
            actions: [
              if (!forceSelection)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.settingsLanguageCancel),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, selected),
                child: Text(l10n.settingsLanguageSave),
              ),
            ],
          );
        },
      );
    },
  );
}
