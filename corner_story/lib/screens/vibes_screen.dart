import 'package:flutter/material.dart';
import '../theme/corner_theme.dart';

class VibesScreen extends StatefulWidget {
  const VibesScreen({super.key});

  @override
  State<VibesScreen> createState() => _VibesScreenState();
}

class _VibesScreenState extends State<VibesScreen> {
  String _selectedTab = 'Friends IRL';

  bool _card1Agreed = false;
  int _card1AgreedCount = 14;
  bool _card1Saved = false;
  int _card1SavedCount = 42;

  bool _card2Cozy = false;
  int _card2CozyCount = 28;
  bool _card2Saved = false;
  int _card2SavedCount = 19;

  final List<_CustomVibePost> _userPosts = [];

  void _openShareModal() {
    final spotController = TextEditingController();
    final quoteController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                const SizedBox(height: 16),
                Text(
                  'FIELD NOTE COMPOSER',
                  style: CornerTypography.labelCaps.copyWith(
                    color: CornerColors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Share your latest spot find',
                  style: CornerTypography.headlineSm,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: spotController,
                  style: CornerTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText: 'Spot name (e.g. Bar Pisellino, West Village)',
                    hintStyle: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                    ),
                    filled: true,
                    fillColor: CornerColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quoteController,
                  maxLines: 3,
                  style: CornerTypography.bodyMd,
                  decoration: InputDecoration(
                    hintText:
                        'What to order, best table, acoustic vibe, or queue tip...',
                    hintStyle: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                    ),
                    filled: true,
                    fillColor: CornerColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: CornerColors.hairline),
                    ),
                  ),
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
                      final spot = spotController.text.trim().isEmpty
                          ? 'Four Horsemen'
                          : spotController.text.trim();
                      final quote = quoteController.text.trim().isEmpty
                          ? 'Sit at the far end of the zinc bar around 4:30 PM. No wait, afternoon light on the walnut tables, and a rare Jura Savagnin by the glass.'
                          : quoteController.text.trim();
                      setState(() {
                        _userPosts.insert(
                          0,
                          _CustomVibePost(spotName: spot, quote: quote),
                        );
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Publish Field Note',
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

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top + 60;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 76;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.only(
            top: topInset + 14,
            bottom: bottomInset + 72,
          ),
          children: [
            // Editorial Manifest Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DISPATCH NO. 04 • FIELD NOTES',
                        style: CornerTypography.labelCaps.copyWith(
                          color: CornerColors.secondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF000000),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Zero sponsored',
                              style: CornerTypography.labelCaps.copyWith(
                                color: CornerColors.onSurfaceVariant,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: CornerTypography.headlineLgMobile,
                      children: [
                        const TextSpan(text: 'Real palates.\n'),
                        TextSpan(
                          text: 'More time in the real world.',
                          style: CornerTypography.headlineLgMobile.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Curated recommendations, honest queues, and quiet tables shared between trusted circles.',
                    style: CornerTypography.bodySm.copyWith(
                      color: CornerColors.secondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Segment Filter Bar
            SizedBox(
              height: 38,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _VibeScopePill(
                    label: 'Friends IRL',
                    icon: Icons.group_rounded,
                    badgeCount: '8',
                    isActive: _selectedTab == 'Friends IRL',
                    onTap: () => setState(() => _selectedTab = 'Friends IRL'),
                  ),
                  const SizedBox(width: 8),
                  _VibeScopePill(
                    label: 'Taste Radar',
                    isActive: _selectedTab == 'Taste Radar',
                    onTap: () => setState(() => _selectedTab = 'Taste Radar'),
                  ),
                  const SizedBox(width: 8),
                  _VibeScopePill(
                    label: 'Following',
                    isActive: _selectedTab == 'Following',
                    onTap: () => setState(() => _selectedTab = 'Following'),
                  ),
                  const SizedBox(width: 8),
                  _VibeScopePill(
                    label: 'Wine & Cellars',
                    isActive: _selectedTab == 'Wine & Cellars',
                    onTap: () =>
                        setState(() => _selectedTab = 'Wine & Cellars'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Newly published user notes (if any)
            ..._userPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CornerColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CornerColors.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/img_20.jpg',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Clara Vance',
                                        style: CornerTypography.labelMd
                                            .copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '@claravance',
                                        style: CornerTypography.bodySm.copyWith(
                                          color: CornerColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'JUST NOW • CURATOR',
                                    style: CornerTypography.labelCaps.copyWith(
                                      color: CornerColors.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            post.spotName,
                            style: CornerTypography.titleEditorial,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: CornerColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '“${post.quote}”',
                          style: CornerTypography.titleEditorial.copyWith(
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Card 1: Jake at Radio Bakery
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CornerColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    'assets/images/img_28.jpg',
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: CornerColors.surfaceContainerLowest,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF000000),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Jake Turner',
                                      style: CornerTypography.labelMd.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '@jake_t',
                                      style: CornerTypography.bodySm.copyWith(
                                        color: CornerColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'TASTE LEADER • NYC',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            showSpotDetailModal(
                              context,
                              name: 'Radio Bakery',
                              neighborhoodAndPrice: 'GREENPOINT, BK • \$\$',
                              rating: '4.9',
                              description:
                                  'Smoked salmon focaccia & Earl Grey morning buns with quiet brick courtyard seating.',
                              imageAsset: 'assets/images/img_29.jpg',
                              categoryBadge: 'Morning Ritual',
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Radio Bakery',
                                    style: CornerTypography.titleEditorial,
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.north_east_rounded,
                                    size: 15,
                                    color: CornerColors.secondary,
                                  ),
                                ],
                              ),
                              Text(
                                'Greenpoint, BK • \$\$',
                                style: CornerTypography.bodySm.copyWith(
                                  color: CornerColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Editorial Quote Body
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF000000),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '“The smoked salmon focaccia & Earl Grey pastry are genuinely worth the 15-minute queue. Go on a Thursday morning if you want quiet courtyard seating.”',
                        style: CornerTypography.titleEditorial.copyWith(
                          height: 1.48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Photographic Duo Layout
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 4 / 5,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/img_29.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CornerColors.inverseSurface
                                            .withValues(alpha: 0.78),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '8:45 AM',
                                        style:
                                            CornerTypography.labelCaps.copyWith(
                                          color: CornerColors.inverseOnSurface,
                                          fontSize: 10,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 4 / 5,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/img_30.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CornerColors.inverseSurface
                                            .withValues(alpha: 0.78),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Courtyard',
                                        style:
                                            CornerTypography.labelCaps.copyWith(
                                          color: CornerColors.inverseOnSurface,
                                          fontSize: 10,
                                          letterSpacing: 0.3,
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

                    const SizedBox(height: 14),

                    // Social & Sensory Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        const _SensoryTag(
                          icon: Icons.local_cafe_outlined,
                          label: 'Morning Ritual',
                        ),
                        const _SensoryTag(
                          icon: Icons.schedule_rounded,
                          label: '12-18 min wait',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: CornerColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Baked Daily',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.onSecondaryContainer,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(
                      height: 1,
                      color: CornerColors.surfaceContainerHigh,
                    ),
                    const SizedBox(height: 12),

                    // Action Toggles / Reactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _ReactionButton(
                              icon: Icons.thumb_up_alt_outlined,
                              activeIcon: Icons.thumb_up_alt_rounded,
                              label: 'Agreed',
                              count: _card1AgreedCount,
                              isActive: _card1Agreed,
                              onTap: () {
                                setState(() {
                                  _card1Agreed = !_card1Agreed;
                                  _card1AgreedCount += _card1Agreed ? 1 : -1;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _ReactionButton(
                              icon: Icons.bookmark_border_rounded,
                              activeIcon: Icons.bookmark_rounded,
                              label: 'Saved',
                              count: _card1SavedCount,
                              isActive: _card1Saved,
                              onTap: () {
                                setState(() {
                                  _card1Saved = !_card1Saved;
                                  _card1SavedCount += _card1Saved ? 1 : -1;
                                });
                              },
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            showSpotDetailModal(
                              context,
                              name: 'Radio Bakery',
                              neighborhoodAndPrice: 'GREENPOINT, BK • \$\$',
                              rating: '4.9',
                              description:
                                  'Smoked salmon focaccia & Earl Grey morning buns with quiet brick courtyard seating.',
                              imageAsset: 'assets/images/img_29.jpg',
                              categoryBadge: 'Morning Ritual',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add_location_alt_outlined,
                                  size: 15,
                                  color: CornerColors.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Plan visit',
                                  style: CornerTypography.labelSm.copyWith(
                                    color: CornerColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Card 2: Eliza at Café Altro Paradiso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CornerColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/images/img_31.jpg',
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color:
                                            CornerColors.surfaceContainerLowest,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: CornerColors.outlineVariant,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Eliza Vance',
                                            style: CornerTypography.labelMd
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '@eliza',
                                          style:
                                              CornerTypography.bodySm.copyWith(
                                            color: CornerColors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'FRIEND IRL • SOHO',
                                      style:
                                          CornerTypography.labelCaps.copyWith(
                                        color: CornerColors.onSurfaceVariant,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showSpotDetailModal(
                              context,
                              name: 'Café Altro Paradiso',
                              neighborhoodAndPrice: 'SPRING ST, NYC • \$\$\$',
                              rating: '4.9',
                              description:
                                  'Golden hour Italian aperitivo & unfiltered skin-contact Malvasia on dark walnut tables.',
                              imageAsset: 'assets/images/img_32.jpg',
                              categoryBadge: 'Golden Hour',
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Café Altro Paradiso',
                                    style: CornerTypography.titleEditorial,
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.north_east_rounded,
                                    size: 15,
                                    color: CornerColors.secondary,
                                  ),
                                ],
                              ),
                              Text(
                                'Spring St, NYC • \$\$\$',
                                style: CornerTypography.bodySm.copyWith(
                                  color: CornerColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Quote
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFF000000),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        '“Skip the tourist hype on TikTok; this corner table at golden hour is the single best aperitivo in the city. Ask for the unfiltered skin-contact Malvasia.”',
                        style: CornerTypography.titleEditorial.copyWith(
                          height: 1.48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Single Immersive Atmosphere Frame (16:10)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/img_32.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    CornerColors.inverseSurface
                                        .withValues(alpha: 0.65),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TABLE 14 • GOLDEN HOUR',
                                    style: CornerTypography.labelCaps.copyWith(
                                      color: CornerColors.inverseOnSurface,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.wine_bar_rounded,
                                        size: 14,
                                        color: CornerColors.inverseOnSurface,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '24 Natural Bottles',
                                        style: CornerTypography.bodySm.copyWith(
                                          color: CornerColors.inverseOnSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Reaction Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: CornerColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wb_twilight_rounded,
                                size: 14,
                                color: CornerColors.onSecondaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Golden Hour',
                                style: CornerTypography.labelCaps.copyWith(
                                  color: CornerColors.onSecondaryContainer,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const _SensoryTag(
                          icon: Icons.graphic_eq_rounded,
                          label: 'Conversational',
                        ),
                        const _SensoryTag(
                          label: 'Corner Favorite',
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(
                      height: 1,
                      color: CornerColors.surfaceContainerHigh,
                    ),
                    const SizedBox(height: 12),

                    // Footer Interactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _ReactionButton(
                              icon: Icons.favorite_border_rounded,
                              activeIcon: Icons.favorite_rounded,
                              label: 'Cozy Vibe',
                              count: _card2CozyCount,
                              isActive: _card2Cozy,
                              onTap: () {
                                setState(() {
                                  _card2Cozy = !_card2Cozy;
                                  _card2CozyCount += _card2Cozy ? 1 : -1;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _ReactionButton(
                              icon: Icons.bookmark_border_rounded,
                              activeIcon: Icons.bookmark_rounded,
                              label: 'Saved',
                              count: _card2SavedCount,
                              isActive: _card2Saved,
                              onTap: () {
                                setState(() {
                                  _card2Saved = !_card2Saved;
                                  _card2SavedCount += _card2Saved ? 1 : -1;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 62,
                          height: 24,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: _InitialCircle(
                                  text: 'JT',
                                  bg: const Color(0xFF000000),
                                  fg: CornerColors.onPrimary,
                                ),
                              ),
                              Positioned(
                                left: 18,
                                child: _InitialCircle(
                                  text: 'AL',
                                  bg: CornerColors.secondary,
                                  fg: CornerColors.onSecondary,
                                ),
                              ),
                              Positioned(
                                left: 36,
                                child: _InitialCircle(
                                  text: '+3',
                                  bg: CornerColors.surfaceContainer,
                                  fg: CornerColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Card 3: Micro Field Note (Anti-Addiction Note)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CornerColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: CornerColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.explore_off_outlined,
                        size: 24,
                        color: CornerColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No algorithmic noise.',
                            style: CornerTypography.headlineSm,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Corner surfaces spots your friends actively revisit, keeping screen time intentionally brief.',
                            style: CornerTypography.bodySm.copyWith(
                              color: CornerColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Sticky Action Bar: Share Latest Spot Find
        Positioned(
          left: 20,
          right: 20,
          bottom: bottomInset + 8,
          child: GestureDetector(
            onTap: _openShareModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CornerColors.inverseSurface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: CornerColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 16,
                      color: CornerColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Share your latest spot find...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CornerTypography.labelMd.copyWith(
                        color: CornerColors.inverseOnSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CornerColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Post vibe',
                          style: CornerTypography.labelSm.copyWith(
                            color: CornerColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: CornerColors.onSurface,
                        ),
                      ],
                    ),
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

class _CustomVibePost {
  final String spotName;
  final String quote;

  const _CustomVibePost({required this.spotName, required this.quote});
}

class _VibeScopePill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? badgeCount;
  final bool isActive;
  final VoidCallback onTap;

  const _VibeScopePill({
    required this.label,
    this.icon,
    this.badgeCount,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF000000)
              : CornerColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? CornerColors.onPrimary
                    : CornerColors.secondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: CornerTypography.labelSm.copyWith(
                color: isActive
                    ? CornerColors.onPrimary
                    : CornerColors.secondary,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? CornerColors.surface.withValues(alpha: 0.2)
                      : CornerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeCount!,
                  style: CornerTypography.labelCaps.copyWith(
                    fontSize: 10,
                    color: isActive
                        ? CornerColors.onPrimary
                        : CornerColors.onSurfaceVariant,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SensoryTag extends StatelessWidget {
  final IconData? icon;
  final String label;

  const _SensoryTag({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CornerColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: CornerColors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: CornerTypography.labelCaps.copyWith(
              color: CornerColors.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF000000)
              : CornerColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 15,
              color: isActive ? CornerColors.onPrimary : CornerColors.primary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: CornerTypography.labelSm.copyWith(
                color:
                    isActive ? CornerColors.onPrimary : CornerColors.onSurface,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: CornerTypography.labelSm.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isActive ? CornerColors.onPrimary : CornerColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialCircle extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _InitialCircle({
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: CornerTypography.labelCaps.copyWith(
          fontSize: 9.5,
          color: fg,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
