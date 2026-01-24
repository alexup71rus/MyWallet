import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/wallet_card.dart';
import 'scanner_screen.dart';
import '../services/pkpass_service.dart';
import '../l10n/l10n.dart';

class AddCardScreen extends StatefulWidget {
  final WalletCard? initialCard; // For linking support

  const AddCardScreen({super.key, this.initialCard});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.store_rounded;
  String _selectedCardTypeKey = 'loyalty';
  String _format = 'qrCode';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    const Color(0xFF1E1E1E), // Black
    Color(0xFFF5F5F5), // Noble White
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.deepOrange,
    Colors.lime,
    Colors.pinkAccent,
    Colors.blueGrey,
  ];

  final List<IconData> _icons = [
    Icons.store_rounded,
    Icons.shopping_bag,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.fastfood,
    Icons.local_grocery_store,
    Icons.card_giftcard,
    Icons.fitness_center,
    Icons.flight,
    Icons.directions_car,
    Icons.pets,
    Icons.movie,
    Icons.sports_esports,
    Icons.local_pharmacy,
    Icons.local_gas_station,
    Icons.book,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCard != null) {
      _nameController.text = widget.initialCard!.name;
      _codeController.text = widget.initialCard!.code;
      if (widget.initialCard!.colorValue != 0) {
        _selectedColor = Color(widget.initialCard!.colorValue);
      }
      if (widget.initialCard!.iconPoint != null) {
        _selectedIcon = IconData(
          widget.initialCard!.iconPoint!,
          fontFamily: 'MaterialIcons',
        );
      }
      _selectedCardTypeKey = L10n.normalizeCardTypeKey(
        widget.initialCard!.cardType,
      );
      _format = widget.initialCard!.format;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardTypeLabel = L10n.cardTypeLabel(l10n, _selectedCardTypeKey);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCardTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview Card
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _selectedColor,
                      Color.lerp(_selectedColor, Colors.black, 0.2)!,
                    ],
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
                        Icon(
                          _selectedIcon,
                          color: _selectedColor == const Color(0xFFF5F5F5)
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
                                (_selectedColor == const Color(0xFFF5F5F5)
                                        ? Colors.black
                                        : Colors.white)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cardTypeLabel.toUpperCase(),
                            style: TextStyle(
                              color: _selectedColor == const Color(0xFFF5F5F5)
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
                          _nameController.text.isEmpty
                              ? l10n.addCardStorePlaceholder
                              : _nameController.text,
                          style: GoogleFonts.poppins(
                            color: _selectedColor == const Color(0xFFF5F5F5)
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
                          _codeController.text.isEmpty
                              ? l10n.addCardCodePlaceholder
                              : _codeController.text,
                          style: GoogleFonts.sourceCodePro(
                            color:
                                (_selectedColor == const Color(0xFFF5F5F5)
                                        ? Colors.black
                                        : Colors.white)
                                    .withValues(alpha: 0.8),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Inputs
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.addCardServiceNameLabel,
                  hintText: l10n.addCardServiceNameHint,
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) =>
                    value!.isEmpty ? l10n.addCardNameValidation : null,
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCardTypeKey,
                decoration: InputDecoration(
                  labelText: l10n.addCardTypeLabel,
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: L10n.cardTypeKeys
                    .map(
                      (typeKey) => DropdownMenuItem(
                        value: typeKey,
                        child: Text(L10n.cardTypeLabel(l10n, typeKey)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCardTypeKey = value);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: l10n.addCardCodeLabel,
                        hintText: l10n.addCardCodeHint,
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? l10n.addCardCodeValidation : null,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _scanCode,
                    icon: const Icon(Icons.camera_alt),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                l10n.addCardIconLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Text(
                l10n.addCardColorLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 3,
                                  )
                                : (color == const Color(0xFFF5F5F5)
                                      ? Border.all(color: Colors.grey.shade300)
                                      : null),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _selectedColor == color
                              ? Icon(
                                  Icons.check,
                                  color: color == const Color(0xFFF5F5F5)
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: Text(
                  l10n.addCardSave,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _findDeepLinkInContent(String content, String code, String? cardId) {
    var regex = RegExp(
      r'''window\.OSMI\s*=\s*\{\s*NAV\s*:\s*['"]([^'"]+)['"]''',
    );
    var match = regex.firstMatch(content);
    if (match != null) return match.group(1);

    regex = RegExp(r'''NAV\s*:\s*["']([^"']+)["']''');
    match = regex.firstMatch(content);

    if (match == null) {
      regex = RegExp(r'''OSMI\.NAV\s*=\s*["']([^"']+)["']''');
      match = regex.firstMatch(content);
    }

    if (match != null) return match.group(1);

    if (cardId != null) {
      regex = RegExp(
        r'''["']([^"']*/''' + RegExp.escape(cardId) + r'''[^"']*)["']''',
      );
      final matches = regex.allMatches(content);

      for (final m in matches) {
        final possibleLink = m.group(1);
        if (possibleLink != null &&
            !possibleLink.contains(code) &&
            code != possibleLink) {
          return possibleLink;
        }
      }
    }
    return null;
  }

  Future<void> _scanCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    );
    if (result != null && result is Map) {
      final code = result['code'] as String;
      final format = result['format'] as String;

      final uri = Uri.tryParse(code);
      if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
        try {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );

          final client = HttpClient();
          // Spoof a mobile browser to ensure we get the mobile version of the page (which contains the JS with the link)
          // instead of the desktop version (which just shows a QR code).
          client.userAgent =
              'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
          final request = await client.getUrl(Uri.parse(code));
          final response = await request.close();

          if (response.statusCode == 200) {
            final bytes = await response.expand((x) => x).toList();
            var processingBytes = Uint8List.fromList(bytes);

            var card = await PkpassService().parsePkpass(processingBytes);

            if (card == null) {
              try {
                final content = utf8.decode(bytes, allowMalformed: true);
                if (content.contains('<html') ||
                    content.contains('<!DOCTYPE html')) {
                  final uriCode = Uri.tryParse(code);
                  final cardId =
                      (uriCode != null && uriCode.pathSegments.isNotEmpty)
                      ? uriCode.pathSegments.last
                      : null;

                  var deepLink = _findDeepLinkInContent(content, code, cardId);

                  if (deepLink == null) {
                    final scriptRegex = RegExp(
                      r'''<script[^>]+src=["']([^"']+)["']''',
                      caseSensitive: false,
                    );
                    final scriptMatches = scriptRegex.allMatches(content);

                    for (final sMatch in scriptMatches) {
                      var scriptSrc = sMatch.group(1);
                      if (scriptSrc != null) {
                        var scriptUri = Uri.parse(scriptSrc);
                        if (!scriptUri.hasScheme) {
                          scriptUri = Uri.parse(code).resolve(scriptSrc);
                        }

                        try {
                          final scriptReq = await client.getUrl(scriptUri);
                          final scriptRes = await scriptReq.close();
                          if (scriptRes.statusCode == 200) {
                            final sBytes = await scriptRes
                                .expand((x) => x)
                                .toList();
                            final sContent = utf8.decode(
                              sBytes,
                              allowMalformed: true,
                            );

                            deepLink = _findDeepLinkInContent(
                              sContent,
                              code,
                              cardId,
                            );
                            if (deepLink != null) {
                              break;
                            }
                          }
                        } catch (e) {
                          print('Failed to analyze script $scriptSrc: $e');
                        }
                      }
                    }
                  }

                  if (deepLink != null) {
                    deepLink = deepLink.replaceAll(r'\/', '/');
                    var nextUri = Uri.parse(deepLink);
                    if (!nextUri.hasScheme) {
                      nextUri = Uri.parse(code).resolve(deepLink);
                    }

                    final request2 = await client.getUrl(nextUri);
                    final response2 = await request2.close();
                    if (response2.statusCode == 200) {
                      final bytes2 = await response2.expand((x) => x).toList();
                      final card2 = await PkpassService().parsePkpass(
                        Uint8List.fromList(bytes2),
                      );
                      if (card2 != null) {
                        card = card2;
                      }
                    }
                  }
                }
              } catch (e) {
                print('Error parsing HTML: $e');
              }
            }

            if (mounted) {
              Navigator.pop(context); // Close loading

              if (card != null) {
                Navigator.pop(context, card);
                return;
              } else {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.addCardLinkNotPass)),
                );
              }
            }
          } else {
            if (mounted) {
              Navigator.pop(context); // Close loading
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.addCardFailedFetch(response.statusCode.toString()),
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context); // Close loading dialog if error
            print('Download error: $e');
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.addCardDownloadError(e.toString()))),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _codeController.text = code;
          _format = format;
        });
      }
    }
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      final newCard = WalletCard(
        id:
            widget.initialCard?.id ??
            DateTime.now().millisecondsSinceEpoch.toString() +
                Random().nextInt(1000).toString(),
        code: _codeController.text,
        displayCode: _codeController.text,
        name: _nameController.text,
        colorValue: _selectedColor.toARGB32(),
        iconPoint: _selectedIcon.codePoint,
        dateAdded: widget.initialCard?.dateAdded ?? DateTime.now(),
        cardType: _selectedCardTypeKey,
        format: _format,
      );
      Navigator.pop(context, newCard);
    }
  }
}
