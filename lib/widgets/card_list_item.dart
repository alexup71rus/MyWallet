import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/wallet_card.dart';
import '../l10n/l10n.dart';

class CardListItem extends StatelessWidget {
  final WalletCard card;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableSwipe;
  final bool canEdit;

  const CardListItem({
    super.key,
    required this.card,
    required this.onTap,
    required this.onToggleFavorite,
    this.onEdit,
    this.onDelete,
    this.enableSwipe = true,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(card.colorValue);
    final displayText =
        card.displayCode ??
        (card.code.startsWith('http') ? l10n.qrCodeLabel : card.code);
    final cardTypeLabel = L10n.cardTypeLabel(l10n, card.cardType);

    final cardContent = Container(
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
                    if (card.iconPath != null &&
                        File(card.iconPath!).existsSync())
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
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
                        ),
                        const SizedBox(width: 8),
                        if (card.pointsValue == null)
                          IconButton(
                            onPressed: onToggleFavorite,
                            iconSize: 24,
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: card.isFavorite == true
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_border_rounded,
                                        color: color == const Color(0xFFF5F5F5)
                                            ? Colors.black
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFD54F),
                                        size: 18,
                                      ),
                                    ],
                                  )
                                : Icon(
                                    Icons.star_border_rounded,
                                    color: color == const Color(0xFFF5F5F5)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                          ),
                      ],
                    ),
                    if (card.pointsValue != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
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
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onToggleFavorite,
                            iconSize: 24,
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: card.isFavorite == true
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_border_rounded,
                                        color: color == const Color(0xFFF5F5F5)
                                            ? Colors.black
                                            : Colors.white,
                                        size: 24,
                                      ),
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFD54F),
                                        size: 18,
                                      ),
                                    ],
                                  )
                                : Icon(
                                    Icons.star_border_rounded,
                                    color: color == const Color(0xFFF5F5F5)
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!enableSwipe || onDelete == null) {
      return cardContent;
    }

    return Dismissible(
      key: ValueKey('card-${card.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        final l10n = AppLocalizations.of(context)!;
        if (direction == DismissDirection.startToEnd) {
          if (!canEdit || onEdit == null) return false;
          onEdit?.call();
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.cardDeleteTitle),
              content: Text(l10n.cardDeleteConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cardDeleteCancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    l10n.cardDeleteAction,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
          if (result == true) {
            onDelete?.call();
            return true;
          }
          return false;
        }

        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: canEdit
              ? const Color(0xFF3757BF)
              : Colors.grey.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Icon(
          Icons.edit,
          color: Colors.white.withValues(alpha: canEdit ? 1 : 0.5),
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: cardContent,
    );
  }
}
