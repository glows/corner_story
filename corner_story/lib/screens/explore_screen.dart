import 'package:flutter/material.dart';
import '../services/corner_api_client.dart';
import '../theme/corner_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final CornerApiClient _api = CornerApiClient();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'For You';
  bool _issueBookmarked = false;
  final Set<String> _savedSpotNames = {'Obvio Cocktail Bar'};

  static const Map<String, String> _spotNameToId = {
    'Obvio Cocktail Bar': 'spt_obvio',
    'Lei': 'spt_lei',
    'Céleste Gallery & Cafe': 'spt_celeste',
  };

  @override
  void initState() {
    super.initState();
    _syncFromBackend();
  }

  Future<void> _syncFromBackend() async {
    try {
      final feed = await _api.fetchExploreFeed(
        city: 'New York',
        category: _selectedCategory,
        query: _searchController.text.trim(),
      );
      final spots = (feed['spots'] as List<dynamic>?) ?? const [];
      if (!mounted || spots.isEmpty) return;
      setState(() {
        for (final item in spots) {
          if (item is Map<String, dynamic>) {
            final name = item['name']?.toString() ?? '';
            final isSaved = item['is_saved'] == true;
            if (name.isNotEmpty) {
              if (isSaved) {
                _savedSpotNames.add(name);
              } else {
                _savedSpotNames.remove(name);
              }
            }
          }
        }
      });
    } catch (_) {
      // Offline sanctuary fallback
    }
  }

  static const List<String> _categories = [
    'For You',
    'Natural Wine',
    'Specialty Coffee',
    'Quiet Work',
    'Secret Gardens',
    'Late Night Bites',
  ];

  final List<_SpotData> _spots = const [
    _SpotData(
      name: 'Obvio Cocktail Bar',
      neighborhoodPrice: 'NOMAD · \$\$\$',
      rating: '4.9',
      description:
          'Dimly lit listening bar, vinyl only, bespoke seasonal vermouths, 0 tourist crowds.',
      imageAsset: 'assets/images/img_04.jpg',
      badge: 'HI-FI AUDIO',
      category: 'Natural Wine',
      avatarInitials: ['E', 'M', 'J'],
      avatarColors: [
        CornerColors.surfaceContainerHighest,
        CornerColors.secondaryContainer,
        CornerColors.primary,
      ],
      avatarTextColors: [
        CornerColors.onSurface,
        CornerColors.onSurface,
        CornerColors.onPrimary,
      ],
      socialProofText: 'Saved by 277 tastemakers',
      hasLiveDot: false,
      acousticNote: '68 dB · Custom Klipschorn & Japanese Jazz Vinyl',
      hours: 'Open tonight · 6:00 PM – 2:00 AM',
    ),
    _SpotData(
      name: 'Lei',
      neighborhoodPrice: 'CHINATOWN · \$\$',
      rating: '4.8',
      description:
          'Lowkey natural wine & Taiwanese small plates, unpretentious elegance, orange wines by the carafe.',
      imageAsset: 'assets/images/img_05.jpg',
      badge: 'LOW INTERVENTION',
      category: 'Natural Wine',
      avatarInitials: ['A', 'D'],
      avatarColors: [
        CornerColors.surfaceDim,
        CornerColors.surfaceContainerHighest,
      ],
      avatarTextColors: [
        CornerColors.onSurface,
        CornerColors.onSurface,
      ],
      socialProofText: 'Friends visited recently',
      hasLiveDot: false,
      acousticNote: '74 dB · Warm Bistro Murmur & Clinking Stems',
      hours: 'Open today · 5:30 PM – 11:30 PM',
    ),
    _SpotData(
      name: 'Céleste Gallery & Cafe',
      neighborhoodPrice: 'SOHO · \$\$',
      rating: '4.9',
      description:
          'Daylight sanctuary, ceremonial oat hojicha & indie art publications in a calm gallery space.',
      imageAsset: 'assets/images/img_06.jpg',
      badge: 'ART & ROAST',
      category: 'Specialty Coffee',
      avatarInitials: [],
      avatarColors: [],
      avatarTextColors: [],
      socialProofText: 'Quiet vibe right now',
      hasLiveDot: true,
      acousticNote: '56 dB · Diffused Daylight & Ambient Brian Eno',
      hours: 'Open now · 8:00 AM – 6:00 PM',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAskCornerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final promptController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.paddingOf(ctx).bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: CornerColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CornerColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: CornerColors.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CORNER CONCIERGE',
                      style: CornerTypography.labelCaps.copyWith(
                        color: CornerColors.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Describe a mood, sound, or craving.',
                  style: CornerTypography.headlineSm,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: promptController,
                  autofocus: true,
                  style: CornerTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Rainy afternoon espresso bar with wooden booths...',
                    hintStyle: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                    ),
                    filled: true,
                    fillColor: CornerColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: CornerColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickPromptChip(
                      label: 'Quiet date spot with vinyl',
                      onTap: () {
                        setState(() {
                          _searchController.text = 'vinyl';
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                    _QuickPromptChip(
                      label: 'Orange wine by the carafe',
                      onTap: () {
                        setState(() {
                          _searchController.text = 'orange wine';
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                    _QuickPromptChip(
                      label: 'Sunlit cafe for reading',
                      onTap: () {
                        setState(() {
                          _searchController.text = 'daylight';
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CornerColors.primary,
                      foregroundColor: CornerColors.onPrimary,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final prompt = promptController.text.trim();
                      setState(() {
                        _searchController.text = prompt;
                      });
                      if (prompt.isNotEmpty) {
                        _api.askCornerAi(prompt: prompt).catchError((_) => const []);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Curate Matches',
                      style: CornerTypography.labelMd.copyWith(
                        color: CornerColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_SpotData> get _filteredSpots {
    final query = _searchController.text.trim().toLowerCase();
    return _spots.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.description.toLowerCase().contains(query) ||
          s.neighborhoodPrice.toLowerCase().contains(query) ||
          s.badge.toLowerCase().contains(query);
      if (!matchesQuery) return false;
      if (_selectedCategory == 'For You') return true;
      if (_selectedCategory == 'Natural Wine') {
        return s.category == 'Natural Wine';
      }
      if (_selectedCategory == 'Specialty Coffee' ||
          _selectedCategory == 'Quiet Work') {
        return s.category == 'Specialty Coffee';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 60;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 76;
    final filtered = _filteredSpots;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(
            top: topInset + 12,
            bottom: bottomInset + 68,
          ),
          children: [
            // Search & Natural Discovery Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: CornerColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A18).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: CornerColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: CornerTypography.bodySm,
                        decoration: InputDecoration(
                          hintText:
                              'Find lowkey wine bars, quiet coffee corners...',
                          hintStyle: CornerTypography.bodySm.copyWith(
                            color: CornerColors.secondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _searchController.clear()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: CornerColors.secondary,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _openAskCornerModal,
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: CornerColors.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: CornerColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Sub-filters: Horizontal Pill Stream
            SizedBox(
              height: 34,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CornerColors.primary
                            : CornerColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: CornerTypography.labelSm.copyWith(
                          color: isSelected
                              ? CornerColors.onPrimary
                              : CornerColors.secondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Editorial Feature: Issue No. 12
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  showSpotDetailModal(
                    context,
                    name: 'Lower Manhattan Underground',
                    neighborhoodAndPrice: 'VOL. 03 · ISSUE 12',
                    rating: '5.0',
                    description:
                        'An intimate chronicle of seven cellar spaces where sound fidelity precedes social buzz, natural pours flow without fanfare, and lighting never exceeds candle-flicker.',
                    imageAsset: 'assets/images/img_03.jpg',
                    categoryBadge: 'Curated Dispatch',
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CornerColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A18).withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Hero
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 280,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/img_03.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.78),
                                      Colors.transparent,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CornerColors.surfaceContainerLowest
                                        .withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'CURATED DISPATCH',
                                    style: CornerTypography.labelCaps.copyWith(
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 12,
                                right: 10,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'VOL. 03 · ISSUE 12',
                                      style:
                                          CornerTypography.labelCaps.copyWith(
                                        color: CornerColors.surfaceContainer,
                                        letterSpacing: 1.3,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _issueBookmarked = !_issueBookmarked;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: CornerColors
                                              .surfaceContainerLowest
                                              .withValues(alpha: 0.92),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _issueBookmarked
                                              ? Icons.bookmark_added_rounded
                                              : Icons.bookmark_border_rounded,
                                          size: 18,
                                          color: _issueBookmarked
                                              ? CornerColors.onTertiaryContainer
                                              : CornerColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Lower Manhattan Underground: Acoustically Pure Sanctuaries',
                        style: CornerTypography.headlineSm,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'An intimate chronicle of seven cellar spaces where sound fidelity precedes social buzz, natural pours flow without fanfare, and lighting never exceeds candle-flicker.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CornerTypography.bodySm.copyWith(
                          color: CornerColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'By Clara Chen & Studio Corner',
                            style: CornerTypography.labelSm.copyWith(
                              color: CornerColors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            '6 MIN READ',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Curated Spot Cards Feed Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEIGHBORHOOD HAUNTS',
                        style: CornerTypography.labelCaps.copyWith(
                          color: CornerColors.secondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Curated Entries',
                        style: CornerTypography.headlineSm,
                      ),
                    ],
                  ),
                  Text(
                    "NYC · SPRING '25",
                    style: CornerTypography.labelCaps.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Curated Spot Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: filtered.map((spot) {
                  final isSaved = _savedSpotNames.contains(spot.name);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _CuratedSpotCard(
                      spot: spot,
                      isSaved: isSaved,
                      onToggleSave: () {
                        setState(() {
                          if (isSaved) {
                            _savedSpotNames.remove(spot.name);
                          } else {
                            _savedSpotNames.add(spot.name);
                          }
                        });
                        final spotId = _spotNameToId[spot.name];
                        if (spotId != null) {
                          _api.toggleSpotBookmark(spotId).catchError((_) => !isSaved);
                        }
                      },
                      onTap: () {
                        showSpotDetailModal(
                          context,
                          name: spot.name,
                          neighborhoodAndPrice: spot.neighborhoodPrice,
                          rating: spot.rating,
                          description: spot.description,
                          imageAsset: spot.imageAsset,
                          categoryBadge: spot.badge,
                          acousticNote: spot.acousticNote,
                          hours: spot.hours,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // Bottom Corner AI Prompt Pill
        Positioned(
          left: 20,
          right: 20,
          bottom: bottomInset + 8,
          child: GestureDetector(
            onTap: _openAskCornerModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A1A18).withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: CornerColors.tertiaryFixedDim,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Looking for something specific? Ask Corner AI...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CornerTypography.bodySm.copyWith(
                        color: CornerColors.surfaceContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: CornerColors.surfaceContainer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotData {
  final String name;
  final String neighborhoodPrice;
  final String rating;
  final String description;
  final String imageAsset;
  final String badge;
  final String category;
  final List<String> avatarInitials;
  final List<Color> avatarColors;
  final List<Color> avatarTextColors;
  final String socialProofText;
  final bool hasLiveDot;
  final String acousticNote;
  final String hours;

  const _SpotData({
    required this.name,
    required this.neighborhoodPrice,
    required this.rating,
    required this.description,
    required this.imageAsset,
    required this.badge,
    required this.category,
    required this.avatarInitials,
    required this.avatarColors,
    required this.avatarTextColors,
    required this.socialProofText,
    required this.hasLiveDot,
    required this.acousticNote,
    required this.hours,
  });
}

class _CuratedSpotCard extends StatelessWidget {
  final _SpotData spot;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onTap;

  const _CuratedSpotCard({
    required this.spot,
    required this.isSaved,
    required this.onToggleSave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CornerColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A18).withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 216,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      spot.imageAsset,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest
                              .withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          spot.neighborhoodPrice,
                          style: CornerTypography.labelCaps,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onToggleSave,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: CornerColors.surfaceContainerLowest
                                .withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: isSaved
                                ? CornerColors.onTertiaryContainer
                                : CornerColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    spot.name,
                    style: CornerTypography.headlineSm,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: CornerColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: CornerColors.onSurface,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        spot.rating,
                        style: CornerTypography.labelCaps,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              spot.description,
              style: CornerTypography.bodySm.copyWith(
                color: CornerColors.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (spot.avatarInitials.isNotEmpty) ...[
                      SizedBox(
                        width: spot.avatarInitials.length * 14.0 + 6,
                        height: 20,
                        child: Stack(
                          children: List.generate(
                            spot.avatarInitials.length,
                            (i) => Positioned(
                              left: i * 13.0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: spot.avatarColors[i],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CornerColors.surfaceContainerLowest,
                                    width: 1.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  spot.avatarInitials[i],
                                  style: CornerTypography.labelCaps.copyWith(
                                    fontSize: 9,
                                    color: spot.avatarTextColors[i],
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ] else if (spot.hasLiveDot) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: CornerColors.onTertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      spot.socialProofText,
                      style: CornerTypography.labelSm.copyWith(
                        color: CornerColors.secondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: CornerColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    spot.badge,
                    style: CornerTypography.labelCaps.copyWith(
                      color: CornerColors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CornerColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CornerColors.hairline),
        ),
        child: Text(
          label,
          style: CornerTypography.labelSm.copyWith(
            color: CornerColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
