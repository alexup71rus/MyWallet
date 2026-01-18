import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import '../models/wallet_card.dart';
import '../services/storage_service.dart';
import '../services/intent_handler_service.dart';
import '../services/pkpass_service.dart';
import '../widgets/card_list_item.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  List<WalletCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _initDeepLinks();
    _initIntentHandler();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      // Ignore errors handling initial link
    }

    // Handle incoming links while app is in foreground/background
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'add') {
      final String? name = uri.queryParameters['name'];
      final String? code = uri.queryParameters['code'];
      final String? colorStr = uri.queryParameters['color'];
      int colorValue = 0;

      if (colorStr != null) {
        // Try parsing hex color (e.g. 0xFF0000)
        try {
          colorValue = int.parse(colorStr);
        } catch (_) {}
      }

      if (name != null && code != null) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCardScreen(
                initialCard: WalletCard(
                  id: '',
                  code: code,
                  displayCode: code,
                  name: name,
                  colorValue: colorValue,
                  dateAdded: DateTime.now(),
                ),
              ),
            ),
          ).then((result) {
            if (result != null && result is WalletCard) {
              _addCard(result);
            }
          });
        }
      }
    }
  }

  Future<void> _initIntentHandler() async {
    // Handle initial intent (app opened via share/open with)
    if (Platform.isAndroid || Platform.isIOS) {
      final String? filePath = await IntentHandlerService.getInitialIntentData();
      if (filePath != null) {
        _handleSharedFile(filePath);
      }

      // Listen for new intents while app is running
      IntentHandlerService.listenForIntents((filePath) {
        _handleSharedFile(filePath);
      });
    }
  }

  Future<void> _handleSharedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;

      final bytes = await file.readAsBytes();
      final pkpassService = PkpassService();
      final card = await pkpassService.parsePkpass(bytes);

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCardScreen(initialCard: card),
          ),
        );
        if (result != null && result is WalletCard) {
          _addCard(result);
        }
      }

      // Clean up temp file
      try {
        await file.delete();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import card: $e')),
        );
      }
    }
  }

  Future<void> _loadCards() async {
    final cards = await _storageService.loadCards();
    // Sort by Date Added descending
    cards.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  Future<void> _addCard(WalletCard card) async {
    final newCards = List<WalletCard>.from(_cards)..insert(0, card);
    setState(() {
      _cards = newCards;
    });
    await _storageService.saveCards(newCards);
  }

  Future<void> _deleteCard(String id) async {
    final newCards = List<WalletCard>.from(_cards)
      ..removeWhere((c) => c.id == id);
    setState(() {
      _cards = newCards;
    });
    await _storageService.saveCards(newCards);
  }

  Future<void> _updateCard(WalletCard updatedCard) async {
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      final newCards = List<WalletCard>.from(_cards);
      newCards[index] = updatedCard;
      setState(() {
        _cards = newCards;
      });
      await _storageService.saveCards(newCards);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'My Wallet',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsScreen(onDataChanged: _loadCards),
                    ),
                  );
                },
              ),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_cards.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wallet_rounded,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wallet is empty',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first loyalty card',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final card = _cards[index];
                  return CardListItem(
                    card: card,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardDetailScreen(
                            card: card,
                            onDelete: () => _deleteCard(card.id),
                            onUpdate: _updateCard,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: _cards.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );
          if (result != null && result is WalletCard) {
            _addCard(result);
          }
        },
        label: const Text(
          'Add Card',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_card),
      ),
    );
  }
}
