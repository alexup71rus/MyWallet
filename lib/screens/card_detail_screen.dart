import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/wallet_card.dart';
import '../services/pkpass_service.dart';

class CardDetailScreen extends StatefulWidget {
  final WalletCard card;
  final VoidCallback onDelete;
  final Function(WalletCard) onUpdate;

  const CardDetailScreen({
    super.key,
    required this.card,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late WalletCard _card;
  double? _originalBrightness;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    _setBrightness();
  }

  Future<void> _setBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('max_brightness') ?? true) {
      try {
        _originalBrightness = await ScreenBrightness().current;
        await ScreenBrightness().setScreenBrightness(1.0);
      } catch (e) {
        print('Error setting brightness: $e');
      }
    }
  }

  @override
  void dispose() {
    _resetBrightness();
    super.dispose();
  }

  Future<void> _resetBrightness() async {
    if (_originalBrightness != null) {
      try {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
      } catch (e) {
        print('Error resetting brightness: $e');
      }
    } else {
      try {
        await ScreenBrightness().resetScreenBrightness();
      } catch (_) {}
    }
  }

  Future<void> _handleRefresh() async {
    // Slight delay to show the indicator if response is too fast
    final minWait = Future.delayed(const Duration(seconds: 1));
    final updateFuture = PkpassService.updatePass(_card);

    final results = await Future.wait([minWait, updateFuture]);
    final newCard = results[1] as WalletCard?;

    if (mounted) {
      if (newCard != null) {
        setState(() => _card = newCard);
        widget.onUpdate(newCard);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cardUpdated)));
      } else {
        // Only show error if we expected an update (has url) but failed
        if (_card.webServiceURL != null) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.cardUpdateFailed)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Treat noble white as light color (needs dark text)
    final color = Color(_card.colorValue);
    // Use foregroundColor if available, otherwise fallback based on card brightness
    final isWhiteCard = color == const Color(0xFFF5F5F5);

    final foregroundColor = _card.foregroundColor != null
        ? Color(_card.foregroundColor!)
        : (isWhiteCard ? Colors.black87 : Colors.white);

    // If it's a white card, try using the brand color (foreground) for the background
    // Otherwise fallback to dark grey
    final backgroundColor = isWhiteCard
        ? (_card.foregroundColor != null
              ? Color(_card.foregroundColor!)
              : const Color(0xFF2C2C2C))
        : color;

    // Determine if color is dark or light
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final isDark = brightness == Brightness.dark;

    final displayText =
        _card.displayCode ??
        (_card.code.startsWith('http') ? l10n.qrCodeLabel : _card.code);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Confirm delete
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.cardDeleteTitle),
                  content: Text(l10n.cardDeleteConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.cardDeleteCancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pop(context); // Close screen
                        widget.onDelete();
                      },
                      child: Text(
                        l10n.cardDeleteAction,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: color,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  100, // Ensure scrollable for RefreshIndicator
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: widget.card.id,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_card.iconPath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_card.iconPath!),
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Icon(
                                    _card.iconPoint != null
                                        ? IconData(
                                            _card.iconPoint!,
                                            fontFamily: 'MaterialIcons',
                                          )
                                        : Icons.store,
                                    color: color,
                                    size: 28,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _card.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            if (_card.pointsValue != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${_card.pointsLabel ?? l10n.pointsLabelDefault}: ${_card.pointsValue}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isWhiteCard
                                      ? foregroundColor
                                      : backgroundColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 32),
                            BarcodeWidget(
                              barcode: _getBarcode(_card.format),
                              data: _card.code,
                              width:
                                  [
                                    'qrCode',
                                    'aztec',
                                    'dataMatrix',
                                  ].contains(_card.format)
                                  ? 250
                                  : double.infinity,
                              height:
                                  [
                                    'qrCode',
                                    'aztec',
                                    'dataMatrix',
                                  ].contains(_card.format)
                                  ? 250
                                  : 120,
                              color: Colors.black,
                              drawText: false,
                              errorBuilder: (context, error) => Center(
                                child: Text(
                                  l10n.barcodeError(error.toString()),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              displayText,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  l10n.cardShowCodeHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Barcode _getBarcode(String format) {
    switch (format) {
      case 'qrCode':
        return Barcode.qrCode();
      case 'pdf417':
        return Barcode.pdf417();
      case 'aztec':
        return Barcode.aztec();
      case 'code128':
        return Barcode.code128();
      case 'code39':
        return Barcode.code39();
      case 'code93':
        return Barcode.code93();
      case 'ean13':
        return Barcode.ean13();
      case 'ean8':
        return Barcode.ean8();
      case 'upcA':
        return Barcode.upcA();
      case 'upcE':
        return Barcode.upcE();
      case 'dataMatrix':
        return Barcode.dataMatrix();
      case 'codabar':
        return Barcode.codabar();
      default:
        return Barcode.qrCode();
    }
  }
}
