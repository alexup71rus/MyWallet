import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/wallet_card.dart';
import '../services/storage_service.dart';
import '../services/intent_handler_service.dart';
import '../services/pkpass_service.dart';
import '../services/notification_service.dart';
import '../services/locale_service.dart';
import '../widgets/card_list_item.dart';
import '../widgets/language_picker.dart';
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
  final NotificationService _notificationService = NotificationService.instance;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  List<WalletCard> _cards = [];
  bool _isLoading = true;
  static const double _nearbyThresholdMeters = 500;
  static const Duration _notificationCooldown = Duration(hours: 6);

  @override
  void initState() {
    super.initState();
    _loadCards();
    _initDeepLinks();
    _initIntentHandler();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptLanguageSelectionIfNeeded();
    });
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
      final String? filePath =
          await IntentHandlerService.getInitialIntentData();
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.homeFailedImport(e.toString()))),
        );
      }
    }
  }

  Future<void> _openAddCardScreen({bool autoScan = false}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardScreen(autoScan: autoScan),
      ),
    );
    if (result != null && result is WalletCard) {
      _addCard(result);
    }
  }

  Future<void> _importPkpassFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pkpass'],
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path == null) return;

        final card = await PkpassService.parseFile(path);
        if (card == null) {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.snackbarPkpassParseFailed)),
          );
          return;
        }

        final newCards = List<WalletCard>.from(_cards)..insert(0, card);
        if (!mounted) return;
        setState(() {
          _cards = newCards;
        });
        await _storageService.saveCards(newCards);

        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackbarPkpassImported)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackbarPkpassImportFailed(e.toString()))),
      );
    }
  }

  Future<void> _showAddCardOptions() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: Text(l10n.addCardOptionScan),
                  onTap: () {
                    Navigator.pop(context);
                    _openAddCardScreen(autoScan: true);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_present),
                  title: Text(l10n.addCardOptionImport),
                  onTap: () {
                    Navigator.pop(context);
                    _importPkpassFromFile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.addCardOptionManual),
                  onTap: () {
                    Navigator.pop(context);
                    _openAddCardScreen();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _promptLanguageSelectionIfNeeded() async {
    final isSet = await LocaleService.isLocaleSet();
    if (isSet || !mounted) return;
    final selected = await showLanguagePicker(context, forceSelection: true);
    if (selected != null && mounted) {
      await LocaleService.setLocale(selected);
    }
  }

  Future<void> _loadCards() async {
    final cards = await _storageService.loadCards();
    // Sort by Date Added descending
    cards.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    final sortedCards = await _sortCardsByProximity(cards);
    if (!mounted) return;
    setState(() {
      _cards = sortedCards;
      _isLoading = false;
    });
  }

  Future<List<WalletCard>> _sortCardsByProximity(List<WalletCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('proximity_sorting_enabled') ?? false;
    if (!isEnabled) return cards;
    if (!cards.any((card) => card.locations.isNotEmpty)) return cards;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return cards;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return cards;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    final nearby = <_CardDistance>[];
    final others = <WalletCard>[];

    for (final card in cards) {
      final distance = _minDistanceToCard(position, card);
      if (distance != null && distance <= _nearbyThresholdMeters) {
        nearby.add(_CardDistance(card: card, distanceMeters: distance));
      } else {
        others.add(card);
      }
    }

    nearby.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    await _maybeNotifyNearbyCard(nearby);

    return [...nearby.map((e) => e.card), ...others];
  }

  Future<void> _maybeNotifyNearbyCard(List<_CardDistance> nearby) async {
    if (nearby.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final nearest = nearby.first;
    final lastKey = 'last_notified_${nearest.card.id}';
    final lastMillis = prefs.getInt(lastKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastMillis != null) {
      final elapsed = Duration(milliseconds: now - lastMillis);
      if (elapsed < _notificationCooldown) return;
    }

    await _notificationService.ensureInitialized();
    await _notificationService.requestPermissionsIfNeeded();
    await _notificationService.showNearbyCardNotification(
      nearest.card,
      nearest.distanceMeters,
    );

    await prefs.setInt(lastKey, now);
  }

  double? _minDistanceToCard(Position position, WalletCard card) {
    if (card.locations.isEmpty) return null;

    double? minDistance;
    for (final location in card.locations) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        location.latitude,
        location.longitude,
      );
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              l10n.appTitle,
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
                      l10n.homeWalletEmptyTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeWalletEmptySubtitle,
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
        onPressed: _showAddCardOptions,
        label: Text(
          l10n.homeAddCard,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_card),
      ),
    );
  }
}

class _CardDistance {
  final WalletCard card;
  final double distanceMeters;

  const _CardDistance({required this.card, required this.distanceMeters});
}
