import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
  }

  Future<void> _handleRefresh() async {
    setState(() => _isUpdating = true);

    // Slight delay to show the indicator if response is too fast
    final minWait = Future.delayed(const Duration(seconds: 1));
    final updateFuture = PkpassService.updatePass(_card);

    final results = await Future.wait([minWait, updateFuture]);
    final newCard = results[1] as WalletCard?;

    if (mounted) {
      setState(() => _isUpdating = false);
      if (newCard != null) {
        setState(() => _card = newCard);
        widget.onUpdate(newCard);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully')),
        );
      } else {
        // Only show error if we expected an update (has url) but failed
        if (_card.webServiceURL != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No updates available or update failed'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_card.colorValue);
    // Determine if color is dark or light
    final brightness = ThemeData.estimateBrightnessForColor(color);
    final isDark = brightness == Brightness.dark;
    final displayText =
        _card.displayCode ??
        (_card.code.startsWith('http') ? 'QR code' : _card.code);

    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Confirm delete
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Card'),
                  content: const Text(
                    'Are you sure you want to remove this card?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        Navigator.pop(context); // Close screen
                        widget.onDelete();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
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
                Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          const SizedBox(width: 8),
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
                          '${_card.pointsLabel ?? 'Points'}: ${_card.pointsValue}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),
                      QrImageView(
                        data: _card.code,
                        version: QrVersions.auto,
                        size: 250.0,
                        backgroundColor: Colors.white,
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
                const SizedBox(height: 50),
                Text(
                  'Show this code at checkout\nPull down to refresh balance',
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
}
