import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mywallet/l10n/app_localizations.dart';
import '../models/card_distance.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _favoritesToggleKey = GlobalKey();
  final GlobalKey _favoritesSectionKey = GlobalKey();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  List<WalletCard> _cards = [];
  bool _isLoading = true;
  bool _showFavoritesOnly = false;
  bool _favoritesExpanded = false;
  bool _pinFavoritesToggle = false;
  Timer? _pinDebounce;
  static const double _nearbyThresholdMeters = 500;
  static const Duration _notificationCooldown = Duration(hours: 6);

  @override
  void initState() {
    super.initState();
    _loadCards();
    _initDeepLinks();
    _initIntentHandler();
    _scrollController.addListener(_schedulePinCheck);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptLanguageSelectionIfNeeded();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _scrollController.dispose();
    _pinDebounce?.cancel();
    super.dispose();
  }

  void _schedulePinCheck() {
    if (_pinDebounce?.isActive ?? false) return;
    _pinDebounce = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      _updateFavoritesTogglePin();
    });
  }

  void _updateFavoritesTogglePin() {
    final favoritesCount = _cards.where((c) => c.isFavorite == true).length;
    final showToggle = !_showFavoritesOnly && favoritesCount > 1;
    if (!showToggle) {
      if (_pinFavoritesToggle) {
        setState(() {
          _pinFavoritesToggle = false;
        });
      }
      return;
    }

    final sectionContext = _favoritesSectionKey.currentContext;
    final buttonContext = _favoritesToggleKey.currentContext;
    if (sectionContext == null || buttonContext == null) return;

    final sectionBox = sectionContext.findRenderObject() as RenderBox?;
    final buttonBox = buttonContext.findRenderObject() as RenderBox?;
    if (sectionBox == null || buttonBox == null) return;
    if (!sectionBox.hasSize || !buttonBox.hasSize) return;

    final sectionOffset = sectionBox.localToGlobal(Offset.zero);
    final sectionBottom = sectionOffset.dy + sectionBox.size.height;
    final buttonOffset = buttonBox.localToGlobal(Offset.zero);
    final buttonBottom = buttonOffset.dy + buttonBox.size.height;
    final mediaQuery = MediaQuery.of(context);
    const fabHeight = 56.0;
    const fabMargin = 16.0;
    final fabTop =
        mediaQuery.size.height -
        mediaQuery.padding.bottom -
        fabMargin -
        fabHeight;
    final shouldPin = sectionBottom > fabTop && buttonBottom > fabTop;

    if (shouldPin != _pinFavoritesToggle && mounted) {
      setState(() {
        _pinFavoritesToggle = shouldPin;
      });
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {}

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
            if (mounted) {
              setState(() {
                _favoritesExpanded = false;
              });
            }
          });
        }
      }
    }
  }

  Future<void> _initIntentHandler() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final String? filePath =
          await IntentHandlerService.getInitialIntentData();
      if (filePath != null) {
        _handleSharedFile(filePath);
      }

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
        if (mounted) {
          setState(() {
            _favoritesExpanded = false;
          });
        }
      }

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
    if (mounted) {
      setState(() {
        _favoritesExpanded = false;
      });
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.snackbarPkpassImported)));
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
    cards.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    final sortedCards = await _sortCardsByProximity(cards);
    if (!mounted) return;
    setState(() {
      _cards = sortedCards;
      _isLoading = false;
    });
    await _restoreMissingIcons(sortedCards);
  }

  Future<void> _restoreMissingIcons(List<WalletCard> cards) async {
    var changed = false;
    final updatedCards = List<WalletCard>.from(cards);

    for (var i = 0; i < updatedCards.length; i++) {
      final card = updatedCards[i];
      if (card.iconPath != null && File(card.iconPath!).existsSync()) {
        continue;
      }

      if (card.webServiceURL == null ||
          card.authenticationToken == null ||
          card.passTypeIdentifier == null) {
        continue;
      }

      final refreshed = await PkpassService.updatePass(card);
      if (refreshed != null && refreshed.iconPath != null) {
        updatedCards[i] = refreshed;
        changed = true;
      }
    }

    if (!mounted || !changed) return;
    setState(() {
      _cards = updatedCards;
    });
    await _storageService.saveCards(updatedCards);
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

    final nearby = <CardDistance>[];
    final others = <WalletCard>[];

    for (final card in cards) {
      final distance = _minDistanceToCard(position, card);
      if (distance != null && distance <= _nearbyThresholdMeters) {
        nearby.add(CardDistance(card: card, distanceMeters: distance));
      } else {
        others.add(card);
      }
    }

    nearby.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    await _maybeNotifyNearbyCard(nearby);

    return [...nearby.map((e) => e.card), ...others];
  }

  Future<void> _maybeNotifyNearbyCard(List<CardDistance> nearby) async {
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

  List<WalletCard> _getVisibleCards() {
    final favorites = _cards.where((c) => c.isFavorite == true).toList();
    final others = _cards.where((c) => c.isFavorite != true).toList();
    final ordered = [...favorites, ...others];
    if (_showFavoritesOnly) return favorites;
    return ordered;
  }

  Widget _buildFavoritesSection(
    List<WalletCard> favorites,
    AppLocalizations l10n,
  ) {
    if (favorites.isEmpty) return const SizedBox.shrink();

    const double cardHeight = 196;
    const double overlapOffset = 48;

    final isExpandedView = _favoritesExpanded || favorites.length == 1;
    final expandedView = Column(
      key: const ValueKey('favorites-expanded'),
      children: favorites.map(_buildCardItem).toList(growable: false),
    );
    final collapsedView = SizedBox(
      key: const ValueKey('favorites-collapsed'),
      height: cardHeight + (favorites.length - 1) * overlapOffset,
      child: Stack(
        children: [
          for (var i = 0; i < favorites.length; i++)
            Positioned(
              top: i * overlapOffset,
              left: 0,
              right: 0,
              child: _buildCardItem(favorites[i]),
            ),
        ],
      ),
    );

    final listContent = AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: isExpandedView ? expandedView : collapsedView,
      ),
    );

    final showInlineToggle = !_showFavoritesOnly && favorites.length > 1;

    return Container(
      key: _favoritesSectionKey,
      child: Column(
        children: [
          listContent,
          if (showInlineToggle) ...[
            const SizedBox(height: 0),
            Opacity(
              opacity: _pinFavoritesToggle ? 0 : 1,
              child: IgnorePointer(
                ignoring: _pinFavoritesToggle,
                child: Center(
                  child: OutlinedButton(
                    key: _favoritesToggleKey,
                    onPressed: () {
                      setState(() {
                        _favoritesExpanded = !_favoritesExpanded;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      _favoritesExpanded
                          ? l10n.favoritesCollapse
                          : l10n.favoritesExpand,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCardItem(WalletCard card) {
    final isManualCard =
        card.webServiceURL == null &&
        card.authenticationToken == null &&
        card.passTypeIdentifier == null;
    final enableSwipe = !(card.isFavorite == true && !_favoritesExpanded);
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
        ).then((_) {
          if (mounted) {
            setState(() {
              _favoritesExpanded = false;
            });
          }
        });
      },
      onToggleFavorite: () => _toggleFavorite(card),
      onEdit: isManualCard ? () => _editCard(card) : null,
      onDelete: () => _deleteCard(card.id),
      enableSwipe: enableSwipe,
      canEdit: isManualCard,
    );
  }

  Future<void> _editCard(WalletCard card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCardScreen(initialCard: card)),
    );
    if (!mounted) return;
    if (result != null && result is WalletCard) {
      _updateCard(result);
    }
  }

  Future<void> _toggleFavorite(WalletCard card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index == -1) return;
    final updatedCard = card.copyWith(isFavorite: !(card.isFavorite == true));
    final newCards = List<WalletCard>.from(_cards);
    newCards[index] = updatedCard;
    setState(() {
      _cards = newCards;
    });
    await _storageService.saveCards(newCards);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesCount = _cards.where((c) => c.isFavorite == true).length;
    final showFavoritesToggle = !_showFavoritesOnly && favoritesCount > 1;
    if (showFavoritesToggle) {
      _schedulePinCheck();
    } else if (_pinFavoritesToggle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _pinFavoritesToggle = false;
        });
      });
    }
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _schedulePinCheck();
              return false;
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar.large(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor: Theme.of(context).colorScheme.surface,
                  scrolledUnderElevation: 2,
                  title: Text(
                    l10n.appTitle,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _showFavoritesOnly
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: _showFavoritesOnly
                            ? const Color(0xFFFFD54F)
                            : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFavoritesOnly = !_showFavoritesOnly;
                          _favoritesExpanded = _showFavoritesOnly;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingsScreen(onDataChanged: _loadCards),
                          ),
                        ).then((_) {
                          if (mounted) {
                            setState(() {
                              _favoritesExpanded = false;
                            });
                          }
                        });
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final favorites = _cards
                              .where((c) => c.isFavorite == true)
                              .toList();
                          final others = _cards
                              .where((c) => c.isFavorite != true)
                              .toList();

                          if (_showFavoritesOnly) {
                            return _buildFavoritesSection(favorites, l10n);
                          }

                          final hasFavoritesSection = favorites.isNotEmpty;
                          if (hasFavoritesSection && index == 0) {
                            return _buildFavoritesSection(favorites, l10n);
                          }

                          final otherIndex = hasFavoritesSection
                              ? index - 1
                              : index;
                          return _buildCardItem(others[otherIndex]);
                        },
                        childCount: () {
                          final favorites = _cards
                              .where((c) => c.isFavorite == true)
                              .toList();
                          final others = _cards
                              .where((c) => c.isFavorite != true)
                              .toList();
                          if (_showFavoritesOnly) {
                            return favorites.isEmpty ? 0 : 1;
                          }
                          return (favorites.isNotEmpty ? 1 : 0) + others.length;
                        }(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showFavoritesToggle && _pinFavoritesToggle)
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _favoritesExpanded = !_favoritesExpanded;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      _favoritesExpanded
                          ? l10n.favoritesCollapse
                          : l10n.favoritesExpand,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
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
