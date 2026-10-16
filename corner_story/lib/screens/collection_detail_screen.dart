import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/corner_api_client.dart';
import '../services/corner_library.dart';
import '../theme/corner_theme.dart';
import 'spot_detail_screen.dart';

/// Screen: Monograph Issue Reader / Curated Collection Detail
/// Implements `stitch_ui_style_redesign/natural_wine_vinyl_curated_collection/code.html`
class CollectionDetailScreen extends StatefulWidget {
  final String collectionTitle;
  final String collectionRibbon;
  final String spotsCountLabel;
  final String coverAsset;

  const CollectionDetailScreen({
    super.key,
    this.collectionTitle = 'Natural Wine & Vinyl Sanctuaries',
    this.collectionRibbon = 'Collection No. 08 · Kyoto & NYC',
    this.spotsCountLabel = '12 curated spots',
    this.coverAsset = 'assets/images/img_40.jpg',
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  bool _isGuideSaved = false;
  final Set<String> _likedStopIds = {};
  final Set<String> _savingStops = {};
  bool _savingGuide = false;

  @override
  void initState() {
    super.initState();
    _restoreLibrary();
  }

  Future<void> _restoreLibrary() async {
    try {
      final library = await CornerLibrary.instance.read();
      if (!mounted) return;
      setState(() {
        _isGuideSaved = library['guide:${widget.collectionTitle}'] == true;
        _likedStopIds.clear();
        for (final stop in _stops) {
          if (library['spot:${stop.spotId ?? stop.name}'] == true) {
            _likedStopIds.add(stop.number);
          }
        }
      });
    } catch (_) {
      // Browsing is available when local storage cannot be read.
    }
  }

  Future<void> _toggleGuideSave() async {
    if (_savingGuide) return;
    _savingGuide = true;
    try {
      await CornerLibrary.instance.put(
        'guide:${widget.collectionTitle}',
        !_isGuideSaved,
      );
      if (!mounted) return;
      setState(() => _isGuideSaved = !_isGuideSaved);
      _showEditorialToast(
        _isGuideSaved
            ? 'Collection archived to your personal library.'
            : 'Removed from saved collections.',
      );
    } catch (_) {
      if (mounted) {
        _showEditorialToast('Could not save the collection. Please try again.');
      }
    } finally {
      _savingGuide = false;
    }
  }

  Future<void> _toggleStopLike(String number) async {
    if (!_savingStops.add(number)) return;
    final stop = _stops.firstWhere((stop) => stop.number == number);
    try {
      final saved = stop.spotId == null
          ? !_likedStopIds.contains(number)
          : await CornerApiClient()
                .toggleSpotBookmark(stop.spotId!)
                .timeout(const Duration(seconds: 10));
      await CornerLibrary.instance.put(
        'spot:${stop.spotId ?? stop.name}',
        saved,
      );
      if (!mounted) return;
      setState(
        () => saved ? _likedStopIds.add(number) : _likedStopIds.remove(number),
      );
      _showEditorialToast(
        saved
            ? 'Saved spot to your personal radar.'
            : 'Removed from your tasting queue.',
      );
    } catch (_) {
      if (mounted) {
        _showEditorialToast('Could not save this stop. Please try again.');
      }
    } finally {
      _savingStops.remove(number);
    }
  }

  Future<void> _openRouteExport() async {
    // These stops span three cities; export separate city links instead of an impossible walking route.
    await Clipboard.setData(
      const ClipboardData(
        text:
            'Natural Wine & Vinyl Sanctuaries\n'
            'NYC: https://www.google.com/maps/dir/?api=1&origin=Eavesdrop+Brooklyn&destination=Obvio+New+York&travelmode=transit\n'
            'Oakland: https://www.google.com/maps/search/?api=1&query=Bar+Shiru+Oakland\n'
            'Kyoto: https://www.google.com/maps/search/?api=1&query=Monk+Kyoto',
      ),
    );
    if (mounted) {
      _showEditorialToast('City map links copied: NYC, Oakland and Kyoto.');
    }
  }

  void _showEditorialToast(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CornerColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
        duration: const Duration(milliseconds: 2200),
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: CornerColors.tertiaryFixed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CornerText(
                msg,
                style: CornerTypography.labelSm.copyWith(
                  color: CornerColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<_CollectionStopData> _stops = [
    _CollectionStopData(
      number: '01',
      spotId: 'spot_eavesdrop',
      name: 'Eavesdrop',
      locationAndPrice: 'GREENPOINT, NYC · \$\$\$',
      timeBadge: 'HI-FI LISTENING · 5:30 PM',
      timeIcon: Icons.schedule_rounded,
      imageAsset: 'assets/images/img_44.jpg',
      description: 'Start when the sun is golden. Japanese vermouth highballs, rare pressed Japanese jazz records, and low-dB custom wood acoustic chambers designed for pure conversational intimacy.',
      curatorNote: 'Curator note: Request the corner alcove seat near the vintage Tannoy monitors.',
      noteIcon: Icons.hearing_rounded,
    ),
    _CollectionStopData(
      number: '02',
      spotId: 'spot_obvio',
      name: 'Obvio',
      locationAndPrice: 'NOMAD, NYC · \$\$\$\$',
      timeBadge: 'DEEP CELLAR · 8:00 PM',
      timeIcon: Icons.wine_bar_rounded,
      imageAsset: 'assets/images/img_45.jpg',
      description: 'Zero tourist volume. Custom analog rotary mixer, skin-contact orange wines by the glass, and forgotten European soul pressings spin on twin restored Technics SL-1200MK2s.',
      curatorNote: 'Saved by 14 sommelier contacts in your circle',
      noteIcon: Icons.auto_awesome_rounded,
    ),
    _CollectionStopData(
      number: '03',
      spotId: null,
      name: 'Bar Shiru',
      locationAndPrice: 'OAKLAND / VISITING · \$\$',
      timeBadge: 'LATE ROTATION · 10:30 PM',
      timeIcon: Icons.album_rounded,
      imageAsset: 'assets/images/img_46.jpg',
      description: 'Acoustic architecture inspired by classic Tokyo jazz kissas. Line-stage preamps and tube amplifiers paired with low-intervention gamay and biodynamic cider flights.',
      curatorNote: 'Sound policy: Full album play-throughs only, no fast skips',
      noteIcon: Icons.tune_rounded,
    ),
    _CollectionStopData(
      number: '04',
      spotId: null,
      name: 'Monk',
      locationAndPrice: 'KYOTO, JAPAN · \$\$\$\$',
      timeBadge: 'PILGRIMAGE HAUNT',
      timeIcon: Icons.temple_buddhist_rounded,
      imageAsset: 'assets/images/img_47.jpg',
      description: 'Fireplace hearth, natural Loire Valley pairings, and gentle ambient drone cassettes. A quiet sanctuary tucked alongside the Philosopher’s Path where time visibly slows down.',
      curatorNote: "Philosopher's Path, Sakyo Ward, Kyoto",
      noteIcon: Icons.location_on_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.paddingOf(context).top + 60),
              ),

              // 1. Curator Metadata Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/img_39.jpg',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CornerText(
                                    'Clara Vance',
                                    style: CornerTypography.labelSm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: CornerColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              CornerText(
                                '@CLARAVANCE · CURATOR',
                                style: CornerTypography.labelCaps.copyWith(
                                  color: CornerColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _toggleGuideSave,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: CornerColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isGuideSaved
                                    ? Icons.bookmark_added_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 19,
                                color: _isGuideSaved
                                    ? CornerColors.onTertiaryContainer
                                    : CornerColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: _openRouteExport,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: CornerColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: CornerColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Monograph Cover Hero (4:5)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(widget.coverAsset, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.black.withValues(alpha: 0.30),
                                  Colors.black.withValues(alpha: 0.40),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CornerColors.surface.withValues(
                                          alpha: 0.22,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: CornerText(
                                        widget.collectionRibbon.toUpperCase(),
                                        style: CornerTypography.labelCaps
                                            .copyWith(
                                              color: CornerColors.onPrimary,
                                              letterSpacing: 1.1,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: CornerColors.surface.withValues(
                                          alpha: 0.22,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.graphic_eq_rounded,
                                        size: 16,
                                        color: CornerColors.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CornerText(
                                      widget.collectionTitle,
                                      style: CornerTypography.headlineLgMobile
                                          .copyWith(
                                            color: CornerColors.onPrimary,
                                            height: 1.18,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        CornerText(
                                          widget.spotsCountLabel,
                                          style: CornerTypography.labelSm
                                              .copyWith(
                                                color: CornerColors
                                                    .surfaceContainerHighest,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: CornerColors
                                                .surfaceContainerHighest,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CornerText(
                                          _isGuideSaved
                                              ? '4.3k saves'
                                              : '4.2k saves',
                                          style: CornerTypography.labelSm
                                              .copyWith(
                                                color: CornerColors
                                                    .surfaceContainerHighest,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: CornerColors
                                                .surfaceContainerHighest,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CornerText(
                                          'Updated 3d ago',
                                          style: CornerTypography.labelSm
                                              .copyWith(
                                                color: CornerColors
                                                    .surfaceContainerHighest,
                                              ),
                                        ),
                                      ],
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
                ),
              ),

              // 3. Curator's Manifesto Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: CornerColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              size: 16,
                              color: CornerColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            CornerText(
                              "CURATOR'S MANIFESTO",
                              style: CornerTypography.labelCaps.copyWith(
                                color: CornerColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CornerText(
                          '“A deeply personal taxonomy of spaces where acoustic fidelity and low-intervention fermentation meet. These are not drinking halls; they are quiet listening temples where the needle drops before the cork pops.”',
                          style: CornerTypography.titleEditorial.copyWith(
                            height: 1.48,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 54,
                              height: 24,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/img_41.jpg',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 15,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/img_42.jpg',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 30,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/img_43.jpg',
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CornerText(
                                'Recommended by Elena, Kenzo & 38 other tastemakers',
                                style: CornerTypography.bodySm.copyWith(
                                  color: CornerColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Route Sequence Overview Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CornerText(
                            'CHRONOLOGICAL SEQUENCE',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const CornerText(
                            'The Ideal Acoustic Itinerary',
                            style: CornerTypography.headlineSm,
                          ),
                        ],
                      ),
                      CornerText(
                        '4 Selected Stops',
                        style: CornerTypography.labelSm.copyWith(
                          color: CornerColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Stops List (01..04)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: _stops.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final stop = _stops[index];
                    final isLiked = _likedStopIds.contains(stop.number);
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SpotDetailScreen(
                              spotId: stop.spotId,
                              initialSaved: isLiked,
                              name: stop.name,
                              neighborhoodAndPrice: stop.locationAndPrice,
                              rating: '4.9',
                              description: stop.description,
                              imageAsset: stop.imageAsset,
                              categoryBadge: stop.timeBadge,
                              acousticNote: stop.curatorNote,
                            ),
                          ),
                        );
                        if (mounted) await _restoreLibrary();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      stop.imageAsset,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.78,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              stop.timeIcon,
                                              size: 13,
                                              color: CornerColors.tertiaryFixed,
                                            ),
                                            const SizedBox(width: 5),
                                            CornerText(
                                              stop.timeBadge,
                                              style: CornerTypography.labelCaps
                                                  .copyWith(
                                                    color:
                                                        CornerColors.onPrimary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleStopLike(stop.number),
                                        child: Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: CornerColors.surface
                                                .withValues(alpha: 0.88),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isLiked
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            size: 17,
                                            color: isLiked
                                                ? CornerColors
                                                      .onTertiaryContainer
                                                : CornerColors.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    CornerText(
                                      stop.number,
                                      style: CornerTypography.titleEditorial
                                          .copyWith(
                                            color:
                                                CornerColors.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    CornerText(
                                      stop.name,
                                      style: CornerTypography.headlineSm,
                                    ),
                                  ],
                                ),
                                CornerText(
                                  stop.locationAndPrice,
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            CornerText(
                              stop.description,
                              style: CornerTypography.bodyMd.copyWith(
                                color: CornerColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  stop.noteIcon,
                                  size: 15,
                                  color: CornerColors.onTertiaryContainer,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: CornerText(
                                    stop.curatorNote,
                                    style: CornerTypography.bodySm.copyWith(
                                      color: CornerColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 6. Interactive Route Map Summary Teaser
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CornerColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CornerText(
                                  'SPATIAL MAPPING',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.onSurfaceVariant,
                                  ),
                                ),
                                CornerText(
                                  'Walking & Transit Waypoints',
                                  style: CornerTypography.titleEditorial
                                      .copyWith(fontStyle: FontStyle.normal),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.explore_outlined,
                              size: 20,
                              color: CornerColors.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 176,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/img_48.jpg',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CornerColors.surface.withValues(
                                        alpha: 0.92,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: CornerColors
                                                .onTertiaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CornerText(
                                          '4 Sanctuary coordinates linked',
                                          style: CornerTypography.labelSm,
                                        ),
                                      ],
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
                ),
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CornerPageHeader(
              title: 'Monograph Issue Reader',
              onBack: () => Navigator.pop(context),
              onShare: _openRouteExport,
            ),
          ),

          // Sticky Floating Action Deck
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 14,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CornerColors.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleGuideSave,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: CornerColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isGuideSaved
                                  ? Icons.check_rounded
                                  : Icons.bookmark_add_outlined,
                              size: 18,
                              color: CornerColors.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            CornerText(
                              _isGuideSaved
                                  ? 'Saved to Your Places'
                                  : 'Save Full Guide to My Map',
                              style: CornerTypography.labelMd.copyWith(
                                color: CornerColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _openRouteExport,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: CornerColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 18,
                            color: CornerColors.onSurface,
                          ),
                          const SizedBox(width: 6),
                          CornerText('Export', style: CornerTypography.labelMd),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionStopData {
  final String number;
  final String? spotId;
  final String name;
  final String locationAndPrice;
  final String timeBadge;
  final IconData timeIcon;
  final String imageAsset;
  final String description;
  final String curatorNote;
  final IconData noteIcon;

  const _CollectionStopData({
    required this.number,
    required this.spotId,
    required this.name,
    required this.locationAndPrice,
    required this.timeBadge,
    required this.timeIcon,
    required this.imageAsset,
    required this.description,
    required this.curatorNote,
    required this.noteIcon,
  });
}
