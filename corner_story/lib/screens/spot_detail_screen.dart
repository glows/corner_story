import 'package:flutter/material.dart';

import '../services/place_photos.dart';

import 'package:flutter/services.dart';

import '../services/corner_api_client.dart';
import '../services/corner_library.dart';
import '../theme/corner_theme.dart';
import '../widgets/place_image.dart';

/// Screen: Eavesdrop / Place Detail View
/// Implements `stitch_ui_style_redesign/eavesdrop_spot_detail_view/code.html`
class SpotDetailScreen extends StatefulWidget {
  final String? spotId;
  final bool initialSaved;
  final Map<String, dynamic>? verifiedData;
  final String name;
  final String neighborhoodAndPrice;
  final String rating;
  final String description;
  final String imageAsset;
  final String categoryBadge;
  final String? acousticNote;
  final String? hours;

  const SpotDetailScreen({
    super.key,
    this.spotId,
    this.initialSaved = false,
    this.verifiedData,
    required this.name,
    required this.neighborhoodAndPrice,
    required this.rating,
    required this.description,
    required this.imageAsset,
    required this.categoryBadge,
    this.acousticNote,
    this.hours,
  });

  @override
  State<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen> {
  final CornerApiClient _api = CornerApiClient();
  bool _isSaved = false;
  bool _inviteCopied = false;
  bool _saving = false;

  String get _storageKey => 'spot:${widget.spotId ?? widget.name}';

  @override
  void initState() {
    super.initState();
    _isSaved = widget.initialSaved;
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final library = await CornerLibrary.instance.read();
      if (mounted && !_saving && library[_storageKey] is bool) {
        setState(() => _isSaved = library[_storageKey] as bool);
      }
    } catch (_) {
      // The caller's saved state remains available if local storage fails.
    }
  }

  Future<void> _toggleSavedState() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = widget.spotId == null
          ? !_isSaved
          : await _api
                .toggleSpotBookmark(widget.spotId!)
                .timeout(const Duration(seconds: 10));
      await CornerLibrary.instance.put(_storageKey, saved);
      if (mounted) setState(() => _isSaved = saved);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CornerText('Could not save this place. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleAudioPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: CornerText(
          'An audio recording is not available for this place yet.',
        ),
      ),
    );
  }

  Future<void> _handleShareInvite() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.name}\nhttps://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.verifiedData?['address']?.toString() ?? widget.name)}',
      ),
    );
    if (!mounted) return;
    setState(() => _inviteCopied = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: CornerText('Place link copied.')));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _inviteCopied = false);
      }
    });
  }

  Widget _buildPlaceOverview() {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      appBar: AppBar(
        backgroundColor: CornerColors.surface,
        leading: BackButton(onPressed: () => Navigator.pop(context, _isSaved)),
        title: const CornerText(
          'Place Detail View',
          style: CornerTypography.titleEditorial,
        ),
        actions: [
          IconButton(
            tooltip: cornerCopy(context, 'Copy place link'),
            onPressed: _handleShareInvite,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: PlaceImage(source: widget.imageAsset),
            ),
          ),
          const SizedBox(height: 24),
          CornerText(
            widget.categoryBadge.toUpperCase(),
            style: CornerTypography.labelCaps.copyWith(
              color: CornerColors.terracotta,
            ),
          ),
          const SizedBox(height: 8),
          CornerText(widget.name, style: CornerTypography.headlineLgMobile),
          const SizedBox(height: 8),
          CornerText(
            widget.rating.isEmpty
                ? widget.neighborhoodAndPrice
                : '${widget.neighborhoodAndPrice}  ·  ★ ${widget.rating}',
            style: CornerTypography.labelMd,
          ),
          const SizedBox(height: 20),
          CornerText(
            widget.description,
            style: CornerTypography.titleEditorial.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
          if (widget.acousticNote != null && widget.acousticNote!.isNotEmpty)
            _overviewRow(
              Icons.graphic_eq_rounded,
              'Atmosphere',
              widget.acousticNote!,
            ),
          if (widget.hours != null)
            _overviewRow(Icons.schedule_rounded, 'Hours', widget.hours!),
          if (widget.verifiedData != null) ...[
            if (placePhotoCredits[widget.imageAsset] != null)
              _overviewRow(
                Icons.photo_camera_outlined,
                'Photo source',
                placePhotoCredits[widget.imageAsset]!,
              ),
            _overviewRow(
              Icons.place_outlined,
              'Address',
              widget.verifiedData!['address'].toString(),
            ),
            _overviewRow(
              Icons.fact_check_outlined,
              'Source checked',
              '${widget.verifiedData!['verified_at']} · Hours in America/New_York',
            ),
            if ((widget.verifiedData!['notes'] ??
                    widget.verifiedData!['verification_notes'] ??
                    '')
                .toString()
                .isNotEmpty)
              _overviewRow(
                Icons.info_outline,
                'Before you visit',
                (widget.verifiedData!['notes'] ??
                        widget.verifiedData!['verification_notes'])
                    .toString(),
              ),
            const SizedBox(height: 12),
            const CornerText(
              'Official website',
              style: CornerTypography.headlineSm,
            ),
            const SizedBox(height: 8),
            SelectableText(
              widget.verifiedData!['website_url'].toString(),
              style: CornerTypography.bodySm,
            ),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: widget.verifiedData!['website_url'].toString(),
                  ),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: CornerText('Official website link copied.'),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const CornerText('Copy website link'),
            ),
          ],
          const SizedBox(height: 24),
          CornerText(
            'A place for your next chapter.',
            style: CornerTypography.headlineSm,
          ),
          const SizedBox(height: 8),
          CornerText(
            'Save this place to revisit it, or share the map link with your circle.',
            style: CornerTypography.bodyMd,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: FilledButton.icon(
            onPressed: _saving ? null : _toggleSavedState,
            icon: Icon(
              _isSaved
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined,
            ),
            label: CornerText(
              _saving
                  ? 'Saving…'
                  : (_isSaved ? 'In Your Corner' : 'Save to My Corner'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: CornerColors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ),
    );
  }

  Widget _overviewRow(IconData icon, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: CornerColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CornerText(
                label.toUpperCase(),
                style: CornerTypography.labelCaps,
              ),
              const SizedBox(height: 6),
              CornerText(value, style: CornerTypography.bodyMd),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isEavesdrop = widget.name.toLowerCase().contains('eavesdrop');
    if (widget.verifiedData != null || !isEavesdrop) {
      return _buildPlaceOverview();
    }
    final heroImage = isEavesdrop
        ? 'assets/images/img_35.jpg'
        : widget.imageAsset;
    final priceTier = widget.neighborhoodAndPrice.contains('·')
        ? widget.neighborhoodAndPrice.split('·').last.trim()
        : '\$\$\$';
    final headerSubtitle = isEavesdrop
        ? 'HI-FI LISTENING BAR · GREENPOINT, BK'
        : '${widget.categoryBadge.toUpperCase()} · ${widget.neighborhoodAndPrice.toUpperCase()}';

    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Top Spacing for Sticky Header
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.paddingOf(context).top + 60),
              ),

              // 1. Atmospheric Gallery: Visual Lead + Sub-strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(heroImage, fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.60),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.12),
                                    ],
                                  ),
                                ),
                              ),
                              // Top floating badge
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CornerColors.surface.withValues(
                                      alpha: 0.92,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: CornerText(
                                    isEavesdrop
                                        ? 'VINYL SELECTOR'
                                        : widget.categoryBadge.toUpperCase(),
                                    style: CornerTypography.labelCaps.copyWith(
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom-right Atmosphere Sound Sample Pill
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: _toggleAudioPreview,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CornerColors.surface.withValues(
                                        alpha: 0.95,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.graphic_eq_rounded,
                                          size: 16,
                                          color:
                                              CornerColors.onTertiaryContainer,
                                        ),
                                        const SizedBox(width: 6),
                                        CornerText(
                                          'Atmosphere · Preview',
                                          style: CornerTypography.labelSm,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Gallery Sub-strip (2 columns)
                      Row(
                        children: [
                          Expanded(
                            child: _SubGalleryFrame(
                              imageAsset: 'assets/images/img_36.jpg',
                              badge: 'GARRARD 301',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SubGalleryFrame(
                              imageAsset: 'assets/images/img_37.jpg',
                              badge: 'APERTIFS',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Header & Essence + Social Proof Stack
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CornerText(
                              headerSubtitle,
                              style: CornerTypography.labelCaps.copyWith(
                                color: CornerColors.secondary,
                                letterSpacing: 1.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: CornerColors.onTertiaryContainer,
                              ),
                              const SizedBox(width: 3),
                              CornerText(
                                widget.rating,
                                style: CornerTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              CornerText(
                                '(142 saves)',
                                style: CornerTypography.labelSm.copyWith(
                                  color: CornerColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CornerText(
                              widget.name,
                              style: CornerTypography.headlineLgMobile,
                            ),
                          ),
                          CornerText(
                            priceTier,
                            style: CornerTypography.labelMd.copyWith(
                              color: CornerColors.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CornerText(
                        isEavesdrop
                            ? 'Dimly lit wood-paneled sanctuary tuned for pristine acoustic fidelity, low-intervention natural wines, and Japanese highballs.'
                            : widget.description,
                        style: CornerTypography.titleEditorial.copyWith(
                          color: CornerColors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Social Proof / Taste Network Stack
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 28,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: _CircleInitial(
                                      label: 'CV',
                                      bg: CornerColors.surfaceVariant,
                                      fg: CornerColors.onSurface,
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    child: _CircleInitial(
                                      label: 'JT',
                                      bg: CornerColors.surfaceContainerHigh,
                                      fg: CornerColors.onSurface,
                                    ),
                                  ),
                                  Positioned(
                                    left: 36,
                                    child: _CircleInitial(
                                      label: 'AL',
                                      bg: CornerColors.tertiaryFixed,
                                      fg: CornerColors.tertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: CornerTypography.bodySm.copyWith(
                                    color: CornerColors.onSurfaceVariant,
                                  ),
                                  children: [
                                    TextSpan(text: 'Saved by '),
                                    TextSpan(
                                      text: 'Clara Vance',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CornerColors.onSurface,
                                      ),
                                    ),
                                    TextSpan(text: ', '),
                                    TextSpan(
                                      text: 'Jake Turner',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CornerColors.onSurface,
                                      ),
                                    ),
                                    TextSpan(text: ', and '),
                                    TextSpan(
                                      text: '24 others',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: CornerColors.onSurface,
                                      ),
                                    ),
                                    TextSpan(text: ' in your circle.'),
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
              ),

              // 3. Acoustic Architecture Module
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CornerText(
                            'Acoustic Architecture',
                            style: CornerTypography.headlineSm,
                          ),
                          CornerText(
                            'FIELD TESTED',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _AcousticMetricRow(
                              icon: Icons.speaker_rounded,
                              label: 'SOUND RIG',
                              title:
                                  widget.acousticNote ??
                                  'Custom Master Sound & Altec Lansing A7s',
                              subtitle: 'Tuned specifically for analog micro-dynamics and uncompressed vinyl playback.',
                            ),
                            const SizedBox(height: 16),
                            // Sound Decibels with progress bar
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: CornerColors.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.volume_down_rounded,
                                    size: 18,
                                    color: CornerColors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CornerText(
                                            'SOUND DECIBELS',
                                            style: CornerTypography.labelCaps
                                                .copyWith(
                                                  color: CornerColors.secondary,
                                                ),
                                          ),
                                          CornerText(
                                            '65–72 dB',
                                            style: CornerTypography.labelSm
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      CornerText(
                                        'Intimate Conversational',
                                        style: CornerTypography.bodyMd.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: 0.48,
                                          minHeight: 6,
                                          backgroundColor:
                                              CornerColors.surfaceContainerHigh,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                CornerColors.onSurface,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _AcousticMetricRow(
                              icon: Icons.chair_outlined,
                              label: 'PRIME LISTENING POSITION',
                              title: 'Back banquette corner (Seat 12)',
                              subtitle: 'Perfect focal apex for stereo imaging without conversational spillover.',
                            ),
                            const SizedBox(height: 16),
                            const _AcousticMetricRow(
                              icon: Icons.light_mode_outlined,
                              label: 'ATMOSPHERIC HUE',
                              title: '2200K Warm Tungsten Glow',
                              subtitle: 'Gentle diffused wall sconces; feels like an uninterrupted midnight salon.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Field Advisory Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CornerColors.secondaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: CornerColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CornerText(
                                'FIELD ADVISORY',
                                style: CornerTypography.labelCaps.copyWith(
                                  color: CornerColors.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CornerText(
                                'Reservations strictly recommended after 8 PM on Fri–Sun. Walk-ins best between 5:15 PM and 6:30 PM on weeknights to secure front listening banquettes.',
                                style: CornerTypography.bodySm,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. What to Order / Signature Pairings
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CornerText(
                            'What to Order',
                            style: CornerTypography.headlineSm,
                          ),
                          CornerText(
                            'Bar & Cellar',
                            style: CornerTypography.labelSm.copyWith(
                              color: CornerColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _MenuItemCard(
                        title: 'Yuzu Highball',
                        badge: 'SIGNATURE',
                        description: 'Japanese malt, crisp mineral soda, cold-pressed yuzu zest, carved block ice.',
                        price: '\$19',
                      ),
                      const SizedBox(height: 8),
                      const _MenuItemCard(
                        title: 'Meinklang Foam Pet-Nat',
                        badge: 'BIO-DYNAMIC',
                        description: 'Austria 2022. Cloudy orchard peach, wild elderflower, crisp high acidity.',
                        price: '\$17',
                      ),
                      const SizedBox(height: 8),
                      const _MenuItemCard(
                        title: 'Sesame Toast & Whipped Ricotta',
                        description: 'Thick sourdough, hot honey drip, toasted white sesame, sea salt flakes.',
                        price: '\$15',
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Vibe Checks from Taste Circle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CornerText(
                            'From the Circle',
                            style: CornerTypography.headlineSm,
                          ),
                          CornerText(
                            'View All 18',
                            style: CornerTypography.labelSm.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _CircleQuoteCard(
                        initials: 'CV',
                        author: 'Clara Vance',
                        timeAgo: '3 days ago',
                        quote: '“The soundstage makes conversation effortless without having to yell over the bass. Order the highball and ask the DJ about their ambient Japanese jazz catalog.”',
                      ),
                      const SizedBox(height: 8),
                      const _CircleQuoteCard(
                        initials: 'JT',
                        author: 'Jake Turner',
                        timeAgo: 'Last week',
                        quote: '“Remarkably civilized. A haven for slow evenings when you want to actually hear the texture of a needle in the groove.”',
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Location & Hours
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CornerText(
                        'Location & Hours',
                        style: CornerTypography.headlineSm,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          height: 176,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/img_38.jpg',
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.10),
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
                                      Icon(
                                        Icons.pin_drop_outlined,
                                        size: 16,
                                        color: CornerColors.onSurface,
                                      ),
                                      const SizedBox(width: 6),
                                      CornerText(
                                        '674 Manhattan Ave, Brooklyn',
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'Transit',
                                  style: CornerTypography.bodySm.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: CornerColors.surfaceVariant,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const CornerText(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    CornerText(
                                      'Nassau Ave (3 min walk)',
                                      style: CornerTypography.bodySm.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: CornerColors.surfaceContainer,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'Hours',
                                  style: CornerTypography.bodySm.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                CornerText(
                                  widget.hours ??
                                      'Tues – Sun · 5:00 PM – 1:00 AM',
                                  style: CornerTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                color: CornerColors.surfaceContainer,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'Seating',
                                  style: CornerTypography.bodySm.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                CornerText(
                                  'Listening Bar & Courtyard',
                                  style: CornerTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w500,
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
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CornerPageHeader(
              title: 'Place Detail View',
              onBack: () => Navigator.pop(context, _isSaved),
              onShare: _handleShareInvite,
            ),
          ),

          // Sticky Bottom Companion Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.paddingOf(context).bottom + 12,
              ),
              decoration: BoxDecoration(
                color: CornerColors.surface.withValues(alpha: 0.92),
                border: Border(top: BorderSide(color: CornerColors.hairline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleSavedState,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isSaved
                              ? CornerColors.tertiaryContainer
                              : CornerColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSaved
                                  ? Icons.bookmark_added_rounded
                                  : Icons.bookmark_add_outlined,
                              size: 18,
                              color: _isSaved
                                  ? CornerColors.onTertiaryContainer
                                  : CornerColors.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            CornerText(
                              _saving
                                  ? 'Saving…'
                                  : (_isSaved
                                        ? 'In Your Corner'
                                        : 'Save to My Corner'),
                              style: CornerTypography.labelMd.copyWith(
                                color: _isSaved
                                    ? CornerColors.onTertiaryContainer
                                    : CornerColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _handleShareInvite,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: CornerColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: CornerColors.hairline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _inviteCopied
                                ? Icons.check_rounded
                                : Icons.group_add_outlined,
                            size: 18,
                            color: CornerColors.onSurface,
                          ),
                          const SizedBox(width: 6),
                          CornerText(
                            _inviteCopied ? 'Copied' : 'Invite',
                            style: CornerTypography.labelMd,
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
    );
  }
}

class _SubGalleryFrame extends StatelessWidget {
  final String imageAsset;
  final String badge;

  const _SubGalleryFrame({required this.imageAsset, required this.badge});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imageAsset, fit: BoxFit.cover),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: CornerText(
                  badge,
                  style: CornerTypography.labelCaps.copyWith(
                    color: CornerColors.onPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleInitial extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _CircleInitial({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: CornerColors.surface, width: 2),
      ),
      child: CornerText(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _AcousticMetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  const _AcousticMetricRow({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CornerColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: CornerColors.onSurface),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CornerText(
                label,
                style: CornerTypography.labelCaps.copyWith(
                  color: CornerColors.secondary,
                ),
              ),
              const SizedBox(height: 2),
              CornerText(
                title,
                style: CornerTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              CornerText(
                subtitle,
                style: CornerTypography.bodySm.copyWith(
                  color: CornerColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String title;
  final String? badge;
  final String description;
  final String price;

  const _MenuItemCard({
    required this.title,
    this.badge,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CornerColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CornerText(
                        title,
                        style: CornerTypography.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CornerText(
                          badge!,
                          style: CornerTypography.labelCaps.copyWith(
                            fontSize: 9.5,
                            color: CornerColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                CornerText(
                  description,
                  style: CornerTypography.bodySm.copyWith(
                    color: CornerColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CornerText(
            price,
            style: CornerTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleQuoteCard extends StatelessWidget {
  final String initials;
  final String author;
  final String timeAgo;
  final String quote;

  const _CircleQuoteCard({
    required this.initials,
    required this.author,
    required this.timeAgo,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CornerColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CornerColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: CornerText(
                      initials,
                      style: CornerTypography.labelCaps.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CornerText(
                    author,
                    style: CornerTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: CornerColors.onTertiaryContainer,
                  ),
                ],
              ),
              CornerText(
                timeAgo,
                style: CornerTypography.bodySm.copyWith(
                  color: CornerColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CornerText(
            quote,
            style: CornerTypography.titleEditorial.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
