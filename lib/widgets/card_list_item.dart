import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/wallet_card.dart';
import '../l10n/l10n.dart';

class CardListItem extends StatelessWidget {
  final WalletCard card;
  final VoidCallback onTap;

  const CardListItem({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(card.colorValue);
    final displayText =
        card.displayCode ??
        (card.code.startsWith('http') ? l10n.qrCodeLabel : card.code);
    final cardTypeLabel = L10n.cardTypeLabel(l10n, card.cardType);

    return Hero(
      tag: card.id,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, Color.lerp(color, Colors.black, 0.2)!],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (card.iconPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(card.iconPath!),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Icon(
                          card.iconPoint != null
                              ? IconData(
                                  card.iconPoint!,
                                  fontFamily: 'MaterialIcons',
                                )
                              : Icons.store_rounded,
                          color: color == const Color(0xFFF5F5F5)
                              ? Colors.black
                              : Colors.white,
                          size: 32,
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (color == const Color(0xFFF5F5F5)
                                      ? Colors.black
                                      : Colors.white)
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cardTypeLabel.toUpperCase(),
                          style: TextStyle(
                            color: color == const Color(0xFFF5F5F5)
                                ? Colors.black
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: GoogleFonts.poppins(
                          color: color == const Color(0xFFF5F5F5)
                              ? Colors.black
                              : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayText,
                        style: GoogleFonts.sourceCodePro(
                          color:
                              (color == const Color(0xFFF5F5F5)
                                      ? Colors.black
                                      : Colors.white)
                                  .withValues(alpha: 0.8),
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.pointsValue != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${card.pointsLabel ?? l10n.pointsLabelDefault}: ${card.pointsValue}',
                          style: GoogleFonts.poppins(
                            color:
                                (color == const Color(0xFFF5F5F5)
                                        ? Colors.black
                                        : Colors.white)
                                    .withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
