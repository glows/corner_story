import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../services/corner_api_client.dart';
import '../services/corner_library.dart';
import '../theme/corner_theme.dart';

/// Screen: Drop a Vibe Check / Editorial Field Note Composer
/// Implements `stitch_ui_style_redesign/drop_a_vibe_check_editorial_note/code.html`
class DropVibeNoteScreen extends StatefulWidget {
  final String initialSpotName;
  final String initialSpotSubtitle;

  const DropVibeNoteScreen({
    super.key,
    this.initialSpotName = 'Radio Bakery',
    this.initialSpotSubtitle = 'Greenpoint, Brooklyn • Franklin St',
  });

  @override
  State<DropVibeNoteScreen> createState() => _DropVibeNoteScreenState();
}

class _DropVibeNoteScreenState extends State<DropVibeNoteScreen> {
  final CornerApiClient _api = CornerApiClient();
  late final TextEditingController _noteController;
  late String _spotName;
  late String _spotSubtitle;

  bool _isDispatched = false;
  bool _nonSponsoredIntegrity = true;
  String _selectedScope = 'Taste Network';
  final List<String> _frames = [
    'assets/images/img_33.jpg',
    'assets/images/img_34.jpg',
  ];
  final Map<String, String> _uploadedFrames = {};
  bool _pickingFrame = false;

  Future<void> _pickFrame() async {
    if (_pickingFrame || _isDispatched || _frames.length >= 3) return;
    _pickingFrame = true;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (mounted && file != null) setState(() => _frames.add(file.path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CornerText(
              'Could not open your photo library. Please try again.',
            ),
          ),
        );
      }
    } finally {
      _pickingFrame = false;
    }
  }

  Future<List<Map<String, String>>> _preparePhotos(List<String> frames) async {
    final photos = <Map<String, String>>[];
    for (var index = 0; index < frames.length; index++) {
      final frame = frames[index];
      var url = frame;
      if (!frame.startsWith('assets/')) {
        url =
            _uploadedFrames[frame] ??
            await _api
                .uploadPhoto(
                  await File(frame).readAsBytes(),
                  contentType: frame.toLowerCase().endsWith('.png')
                      ? 'image/png'
                      : 'image/jpeg',
                )
                .timeout(const Duration(seconds: 20));
        _uploadedFrames[frame] = url;
      }
      photos.add({'url': url, 'label': 'FRAME ${index + 1}'});
    }
    return photos;
  }

  static const List<String> _allTags = [
    'Courtyard',
    'Morning Ritual',
    '15 min wait',
    'Conversational',
    'Vinyl Only',
    'Late Night',
    'Solo Read',
    'Pet-Nat Focus',
  ];

  final Set<String> _activeTags = {
    'Courtyard',
    'Morning Ritual',
    '15 min wait',
    'Conversational',
  };

  @override
  void initState() {
    super.initState();
    _spotName = widget.initialSpotName;
    _spotSubtitle = widget.initialSpotSubtitle;
    _noteController = TextEditingController(
      text: 'The smoked salmon focaccia & Earl Grey pastry are genuinely worth the 15-minute queue. Go on a Thursday morning if you want quiet courtyard seating.',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _promptChangeSpot() {
    final ctrl = TextEditingController(text: _spotName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CornerColors.surface,
        title: const CornerText(
          'Select Geo-Verified Sanctuary',
          style: CornerTypography.headlineSm,
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: CornerTypography.bodyMd,
          decoration: InputDecoration(
            hintText: cornerCopy(
              context,
              'Spot name (e.g. Eavesdrop, Four Horsemen)',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const CornerText('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CornerColors.primary,
              foregroundColor: CornerColors.onPrimary,
            ),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  _spotName = ctrl.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
            child: const CornerText('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (_isDispatched) return;
    final quote = _noteController.text.trim();
    if (quote.isEmpty ||
        quote.characters.length > 280 ||
        !_nonSponsoredIntegrity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CornerText(
            'Write a note (1–280 characters) and confirm your non-sponsored visit.',
          ),
        ),
      );
      return;
    }
    if (apiSpotIdForName(_spotName) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CornerText(
            'Choose a known place, such as Radio Bakery or Eavesdrop.',
          ),
        ),
      );
      return;
    }
    setState(() => _isDispatched = true);
    final audience = _selectedScope;
    final tags = _activeTags.toList();
    final place = _spotName;
    final frames = List<String>.of(_frames);
    try {
      final photos = await _preparePhotos(frames);
      await _api
          .publishFieldNote(
            spotName: place,
            quote: quote,
            sensoryTags: tags,
            scope: audience,
            photos: photos,
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      Navigator.pop(context, {
        'spotName': place,
        'quote': quote,
        'tags': tags,
        'scope': audience,
        'photos': photos,
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isDispatched = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CornerText(
            'Could not publish. Your note is still here; please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _noteController.text.length;

    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: Column(
        children: [
          CornerPageHeader(
            title: 'Add Curated Place',
            onBack: () => Navigator.pop(context),
            onShare: () async {
              await Clipboard.setData(
                ClipboardData(text: _noteController.text),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: CornerText('Draft copied to clipboard.'),
                ),
              );
            },
          ),

          // Main Scrollable Editorial Composer Card
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.paddingOf(context).bottom + 32,
              ),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: CornerColors.surfaceContainerLowest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                      bottom: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tactile Drag Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 4),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: CornerColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),

                      // Editorial Header Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: CornerColors.surfaceContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: CornerColors.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CornerText(
                                      'DISPATCH NO. 04',
                                      style: CornerTypography.labelCaps
                                          .copyWith(
                                            color: CornerColors.secondary,
                                          ),
                                    ),
                                    const CornerText(
                                      'Field Note',
                                      style: CornerTypography.headlineSm,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _handlePublish,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDispatched
                                      ? CornerColors.onTertiaryContainer
                                      : CornerColors.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    CornerText(
                                      _isDispatched
                                          ? 'Publishing…'
                                          : 'Publish Note',
                                      style: CornerTypography.labelMd.copyWith(
                                        color: CornerColors.onPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      _isDispatched
                                          ? Icons.check_rounded
                                          : Icons.north_east_rounded,
                                      size: 16,
                                      color: CornerColors.onPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Detected Location Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'GEO-VERIFIED SANCTUARY',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: CornerColors.onTertiaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    CornerText(
                                      'Recent Visit (08:42 AM)',
                                      style: CornerTypography.labelSm.copyWith(
                                        color: CornerColors.onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CornerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: CornerColors.surfaceContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: CornerColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CornerText(
                                          _spotName,
                                          style: CornerTypography.bodyMd
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        CornerText(
                                          _spotSubtitle,
                                          style: CornerTypography.bodySm
                                              .copyWith(
                                                color: CornerColors.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _promptChangeSpot,
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: CornerColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            Row(
                              children: [
                                Expanded(
                                  child: CornerText(
                                    'FILM CAPTURES',
                                    style: CornerTypography.labelCaps,
                                  ),
                                ),
                                CornerText(
                                  '${_frames.length} of 3 loaded',
                                  style: CornerTypography.labelSm,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(
                                3,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index == 2 ? 0 : 8,
                                    ),
                                    child: index < _frames.length
                                        ? _FilmRollTile(
                                            imageAsset: _frames[index],
                                            label: '0${index + 1} / FRAME',
                                            onRemove: () {
                                              if (!_isDispatched) {
                                                setState(
                                                  () => _frames.removeAt(index),
                                                );
                                              }
                                            },
                                          )
                                        : index == _frames.length
                                        ? GestureDetector(
                                            onTap: _pickFrame,
                                            child: AspectRatio(
                                              aspectRatio: 4 / 5,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: CornerColors
                                                      .surfaceContainerLow,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      size: 24,
                                                      color: CornerColors
                                                          .secondary,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    CornerText(
                                                      'ADD FRAME\n(35MM)',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: CornerTypography
                                                          .labelCaps
                                                          .copyWith(
                                                            fontSize: 9.5,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : const AspectRatio(aspectRatio: 4 / 5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            CornerText(
                              'Natural lighting, uncurated tables, zero promotional overlay.',
                              style: CornerTypography.bodySm.copyWith(
                                color: CornerColors.secondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 3. The Honest Dispatch (Editorial Prose)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'THE HONEST DISPATCH',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                CornerText(
                                  'ANTI-HYPE CADENCE',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CornerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _noteController,
                                    maxLines: 3,
                                    maxLength: 280,
                                    onChanged: (_) => setState(() {}),
                                    style: CornerTypography.titleEditorial,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                      isDense: true,
                                      hintText: cornerCopy(
                                        context,
                                        'Write with restraint. What lingered after you left?',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CornerText(
                                        'Keep it truthful, concise & table-tested',
                                        style: CornerTypography.labelSm
                                            .copyWith(
                                              color: CornerColors.secondary,
                                            ),
                                      ),
                                      CornerText(
                                        '$charCount / 280',
                                        style: CornerTypography.labelSm
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 4. Sensory Markers (Micro-Tags)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CornerText(
                                  'SENSORY MARKERS',
                                  style: CornerTypography.labelCaps.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                                CornerText(
                                  'Tap to imprint',
                                  style: CornerTypography.labelSm.copyWith(
                                    color: CornerColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _allTags.map((tag) {
                                final isSelected = _activeTags.contains(tag);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _activeTags.remove(tag);
                                      } else {
                                        _activeTags.add(tag);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? CornerColors.primary
                                          : CornerColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: CornerColors.onPrimary,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        CornerText(
                                          tag,
                                          style: CornerTypography.labelSm
                                              .copyWith(
                                                color: isSelected
                                                    ? CornerColors.onPrimary
                                                    : CornerColors
                                                          .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 22),

                            // 5. Anti-Ad Integrity Toggle
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CornerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_rounded,
                                              size: 18,
                                              color: CornerColors
                                                  .onTertiaryContainer,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: CornerText(
                                                '100% Non-Sponsored IRL Experience',
                                                style: CornerTypography.labelMd
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        CornerText(
                                          'Corner strictly bars PR invites, comped pastries, and agency seeds to keep our neighborhood trust uncompromised.',
                                          style: CornerTypography.bodySm
                                              .copyWith(
                                                color: CornerColors.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch.adaptive(
                                    value: _nonSponsoredIntegrity,
                                    activeThumbColor: CornerColors.primary,
                                    onChanged: (v) {
                                      setState(
                                        () => _nonSponsoredIntegrity = v,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 6. Audience & Reach Scope Selector
                            CornerText(
                              'AUDIENCE & REACH',
                              style: CornerTypography.labelCaps.copyWith(
                                color: CornerColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ScopeOptionButton(
                                    icon: Icons.lock_outline_rounded,
                                    label: 'IRL Friends',
                                    isSelected: _selectedScope == 'IRL Friends',
                                    onTap: () => setState(
                                      () => _selectedScope = 'IRL Friends',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ScopeOptionButton(
                                    icon: Icons.travel_explore_rounded,
                                    label: 'Taste Network',
                                    isSelected:
                                        _selectedScope == 'Taste Network',
                                    onTap: () => setState(
                                      () => _selectedScope = 'Taste Network',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ScopeOptionButton(
                                    icon: Icons.bookmark_border_rounded,
                                    label: 'Private Book',
                                    isSelected:
                                        _selectedScope == 'Private Book',
                                    onTap: () => setState(
                                      () => _selectedScope = 'Private Book',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Bottom Human Note
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: CornerColors.onTertiaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: CornerText(
                                    'Your words guide real people to real tables.',
                                    textAlign: TextAlign.center,
                                    style: CornerTypography.titleEditorial
                                        .copyWith(
                                          color: CornerColors.secondary,
                                          fontSize: 16,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: CornerColors.onTertiaryContainer,
                                    shape: BoxShape.circle,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilmRollTile extends StatelessWidget {
  final String imageAsset;
  final String label;
  final VoidCallback onRemove;

  const _FilmRollTile({
    required this.imageAsset,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageAsset.startsWith('assets/')
                ? Image.asset(imageAsset, fit: BoxFit.cover)
                : Image.file(File(imageAsset), fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CornerText(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CornerTypography.labelCaps.copyWith(
                          color: CornerColors.onPrimary,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: CornerColors.onPrimary,
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
    );
  }
}

class _ScopeOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScopeOptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CornerColors.primary
              : CornerColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? CornerColors.onPrimary
                  : CornerColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            CornerText(
              label,
              textAlign: TextAlign.center,
              style: CornerTypography.labelSm.copyWith(
                color: isSelected
                    ? CornerColors.onPrimary
                    : CornerColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
