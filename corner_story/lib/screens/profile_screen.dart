import 'dart:async';
import 'package:flutter/material.dart';
import '../services/corner_api_client.dart';
import '../theme/corner_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CornerApiClient _api = CornerApiClient();
  String _selectedCity = 'All (86)';
  String _selectedTab = 'My Curations';
  bool _linkCopied = false;
  Timer? _copyTimer;
  String _cornersCount = '38';
  String _bio =
      'Architect & slow coffee enthusiast. Curating hidden courtyards, subterranean soundbars, and natural cellars in NYC, Milan & Kyoto.';

  static const List<String> _cities = [
    'All (86)',
    'New York (52)',
    'Kyoto (21)',
    'Milan (13)',
  ];

  static const List<String> _tabs = [
    'My Curations',
    'Want to Try (45)',
    'Moments',
  ];

  @override
  void initState() {
    super.initState();
    _syncProfileFromBackend();
  }

  Future<void> _syncProfileFromBackend() async {
    try {
      final data = await _api.fetchProfile(handle: 'claravance');
      final user = data['user'] as Map<String, dynamic>?;
      if (!mounted || user == null) return;
      setState(() {
        final corners = user['corners_count'];
        if (corners != null) {
          _cornersCount = corners.toString();
        }
        final bio = user['bio']?.toString() ?? '';
        if (bio.isNotEmpty) {
          _bio = bio;
        }
      });
    } catch (_) {
      // Offline sanctuary fallback
    }
  }

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  void _handleShareMap() {
    setState(() => _linkCopied = true);
    _copyTimer?.cancel();
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _linkCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 60;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 76;

    return ListView(
      padding: EdgeInsets.only(
        top: topInset + 16,
        bottom: bottomInset + 20,
      ),
      children: [
        // Identity Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: CornerColors.surfaceContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/img_20.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CornerColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _handleShareMap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _linkCopied
                                  ? Icons.check_rounded
                                  : Icons.share_location_rounded,
                              size: 18,
                              color: CornerColors.onPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _linkCopied ? 'Link Copied' : 'Share Map',
                              style: CornerTypography.labelMd.copyWith(
                                color: CornerColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile preferences unlocked'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: CornerColors.onSurface,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: CornerTypography.labelMd,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Bio & Handle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'Clara Vance',
                    style: CornerTypography.headlineMd,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@claravance',
                    style: CornerTypography.labelSm.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _bio,
                style: CornerTypography.bodyMd.copyWith(
                  color: CornerColors.secondary,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Editorial Metrics Strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: CornerColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    value: _cornersCount,
                    label: 'CORNERS',
                  ),
                ),
                const Expanded(
                  child: _MetricItem(
                    value: '1.2k',
                    label: 'FOLLOWERS',
                  ),
                ),
                const Expanded(
                  child: _MetricItem(
                    value: '148',
                    label: 'FOLLOWING',
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'TOP 5%',
                          style: CornerTypography.labelCaps.copyWith(
                            color: CornerColors.onSecondaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TASTE',
                        style: CornerTypography.labelCaps.copyWith(
                          color: CornerColors.secondary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Curated Cities Horizontal Scroll
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE CHAPTERS',
                style: CornerTypography.labelCaps.copyWith(
                  color: CornerColors.secondary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '86 Curated Spots',
                style: CornerTypography.labelCaps.copyWith(
                  color: CornerColors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = _cities[index];
              final isSelected = city == _selectedCity;
              return GestureDetector(
                onTap: () => setState(() => _selectedCity = city),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF000000)
                        : CornerColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    city,
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

        const SizedBox(height: 22),

        // Segmented Section Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: CornerColors.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = tab == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CornerColors.surfaceContainerLowest
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tab,
                        style: CornerTypography.labelSm.copyWith(
                          color: isSelected
                              ? CornerColors.onSurface
                              : CornerColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Section: Curations Bento Grid Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Curated Collections',
                    style: CornerTypography.headlineSm,
                  ),
                  Text(
                    'Handcrafted guides updated weekly',
                    style: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create new Curated Collection'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: CornerColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: CornerColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Editorial Cards 2x2 Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CollectionGridCard(
                      tag: 'ATMOSPHERES',
                      title: 'Natural Wine &\nVinyl',
                      imageAsset: 'assets/images/img_21.jpg',
                      rating: '4.9',
                      spotsSaved: '12 spots\nsaved',
                      cities: 'KYOTO •\nNYC',
                      onTap: () {
                        showSpotDetailModal(
                          context,
                          name: 'Natural Wine & Vinyl',
                          neighborhoodAndPrice: 'KYOTO • NYC · 12 SPOTS',
                          rating: '4.9',
                          description:
                              'Subterranean listening bars with custom horn speakers, Japanese jazz pressings, and low-intervention orange pours.',
                          imageAsset: 'assets/images/img_21.jpg',
                          categoryBadge: 'Atmospheres',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _CollectionGridCard(
                      tag: 'FOCUS SPACES',
                      title: 'Sun-drenched\nWork Cafes',
                      imageAsset: 'assets/images/img_22.jpg',
                      spotsSaved: '8 spots\nsaved',
                      cities: 'SOHO •\nBUSHWICK',
                      onTap: () {
                        showSpotDetailModal(
                          context,
                          name: 'Sun-drenched Work Cafes',
                          neighborhoodAndPrice: 'SOHO • BUSHWICK · 8 SPOTS',
                          rating: '4.8',
                          description:
                              'Loft cafes with industrial steel-frame windows, natural oak communal tables, and single-origin pour-overs.',
                          imageAsset: 'assets/images/img_22.jpg',
                          categoryBadge: 'Focus Spaces',
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CollectionGridCard(
                      tag: 'SOLITUDE',
                      title: 'Secret Green\nSanctuaries',
                      imageAsset: 'assets/images/img_23.jpg',
                      spotsSaved: '6 spots\nsaved',
                      cities: 'BRERA •\nNAVIGLI',
                      onTap: () {
                        showSpotDetailModal(
                          context,
                          name: 'Secret Green Sanctuaries',
                          neighborhoodAndPrice: 'BRERA • NAVIGLI · 6 SPOTS',
                          rating: '4.9',
                          description:
                              'Hidden Italian courtyard cloisters with ivy-covered stone arcades and shaded marble benches.',
                          imageAsset: 'assets/images/img_23.jpg',
                          categoryBadge: 'Solitude',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _CollectionGridCard(
                      tag: 'MIDNIGHT',
                      title: 'Late Night Ramen\n& Jazz',
                      imageAsset: 'assets/images/img_24.jpg',
                      spotsSaved: '9 spots\nsaved',
                      cities: 'LOWER EAST\nSIDE',
                      onTap: () {
                        showSpotDetailModal(
                          context,
                          name: 'Late Night Ramen & Jazz',
                          neighborhoodAndPrice: 'LOWER EAST SIDE · 9 SPOTS',
                          rating: '4.8',
                          description:
                              'Atmospheric counter seating after midnight with steaming artisan broths and warm brass fixtures.',
                          imageAsset: 'assets/images/img_24.jpg',
                          categoryBadge: 'Midnight',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // Editorial Highlight Banner: Start Building
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CornerColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: CornerColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.push_pin_outlined,
                        size: 18,
                        color: CornerColors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'QUIET CARTOGRAPHY',
                          style: CornerTypography.labelCaps.copyWith(
                            color: CornerColors.secondary,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const Text(
                          'Start building your corner',
                          style: CornerTypography.headlineSm,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Save the table with the afternoon light, the bookshop that plays ECM vinyl, or the park bench under the ginkgo tree.',
                  style: CornerTypography.bodySm.copyWith(
                    color: CornerColors.secondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pin a new place to your Corner map'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pin a Place',
                          style: CornerTypography.labelMd.copyWith(
                            color: CornerColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ready to import saved lists'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Import from Maps',
                          style: CornerTypography.labelMd,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Candid Moments & Visited Feed
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Candid Moments',
                        style: CornerTypography.headlineSm,
                      ),
                      Text(
                        'Photographic notes & sensory fragments',
                        style: CornerTypography.bodySm.copyWith(
                          color: CornerColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '24 NOTES',
                    style: CornerTypography.labelCaps.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Asymmetric Editorial Photo Layout (7 cols : 5 cols)
              SizedBox(
                height: 276,
                child: Row(
                  children: [
                    // Big featured vertical photo (7/12)
                    Expanded(
                      flex: 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/img_25.jpg',
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: CornerColors.surface
                                      .withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FONDAZIONE PRADA',
                                      style:
                                          CornerTypography.labelCaps.copyWith(
                                        color: CornerColors.secondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Shadow study, 10:45 AM',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: CornerTypography.bodySm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Two stacked smaller photos (5/12)
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/img_26.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CornerColors
                                            .surfaceContainerLowest
                                            .withValues(alpha: 0.92),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Kyoto',
                                        style:
                                            CornerTypography.labelCaps.copyWith(
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/img_27.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CornerColors
                                            .surfaceContainerLowest
                                            .withValues(alpha: 0.92),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Dimes Sq',
                                        style:
                                            CornerTypography.labelCaps.copyWith(
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value;
  final String label;

  const _MetricItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: CornerTypography.headlineSm,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: CornerTypography.labelCaps.copyWith(
            color: CornerColors.secondary,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _CollectionGridCard extends StatelessWidget {
  final String tag;
  final String title;
  final String imageAsset;
  final String? rating;
  final String spotsSaved;
  final String cities;
  final VoidCallback onTap;

  const _CollectionGridCard({
    required this.tag,
    required this.title,
    required this.imageAsset,
    this.rating,
    required this.spotsSaved,
    required this.cities,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: CornerColors.onTertiaryContainer,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating!,
                              style: CornerTypography.labelCaps,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tag,
                          style: CornerTypography.labelCaps.copyWith(
                            color: CornerColors.tertiaryFixed,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: CornerTypography.headlineSm.copyWith(
                            fontSize: 17,
                            height: 1.2,
                            color: CornerColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spotsSaved,
                  style: CornerTypography.bodySm.copyWith(
                    color: CornerColors.secondary,
                    height: 1.25,
                  ),
                ),
                Text(
                  cities,
                  textAlign: TextAlign.right,
                  style: CornerTypography.labelCaps.copyWith(
                    color: CornerColors.onSurfaceVariant,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
