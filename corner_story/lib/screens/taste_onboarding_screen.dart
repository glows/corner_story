import 'package:flutter/material.dart';

import '../theme/corner_theme.dart';
import '../services/corner_library.dart';

/// Screen: Taste Onboarding & Palate Calibration
/// Implements `stitch_ui_style_redesign/taste_onboarding_palate_calibration/code.html`
class TasteOnboardingScreen extends StatefulWidget {
  const TasteOnboardingScreen({super.key});

  @override
  State<TasteOnboardingScreen> createState() => _TasteOnboardingScreenState();
}

class _TasteOnboardingScreenState extends State<TasteOnboardingScreen> {
  final Set<String> _selectedMoods = {
    'Vinyl & Hi-Fi Lounges',
    'Natural Wine Cellars',
    'Sunlit Quiet Cafes',
  };

  String _selectedTempo = 'Tuned / Quiet';
  final bool _contactsLinked = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final library = await CornerLibrary.instance.read();
      final palate = library['palate'] as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        if (palate != null) {
          _selectedMoods
            ..clear()
            ..addAll((palate['moods'] as List).cast<String>());
          _selectedTempo = palate['tempo'] as String;
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePreferences() async {
    if (_loading || _saving) return;
    setState(() => _saving = true);
    try {
      await CornerLibrary.instance.put('palate', {
        'moods': _selectedMoods.toList(),
        'tempo': _selectedTempo,
      });
      if (mounted) Navigator.pop(context, _selectedMoods.toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CornerText('Could not save your palate. Please try again.'),
        ),
      );
    }
  }

  static const List<_MoodArchetype> _moods = [
    _MoodArchetype(
      title: 'Vinyl & Hi-Fi Lounges',
      subtitle: 'Analog soundscapes',
      imageAsset: 'assets/images/img_49.jpg',
    ),
    _MoodArchetype(
      title: 'Natural Wine Cellars',
      subtitle: 'Pet-nat & terroir',
      imageAsset: 'assets/images/img_50.jpg',
    ),
    _MoodArchetype(
      title: 'Sunlit Quiet Cafes',
      subtitle: 'Focus & linen light',
      imageAsset: 'assets/images/img_51.jpg',
    ),
    _MoodArchetype(
      title: 'Hidden Courtyards',
      subtitle: 'Walled gravel gardens',
      imageAsset: 'assets/images/img_52.jpg',
    ),
    _MoodArchetype(
      title: 'Brutalist Bakeries',
      subtitle: 'Sourdough & concrete',
      imageAsset: 'assets/images/img_53.jpg',
    ),
    _MoodArchetype(
      title: 'Counter Dining',
      subtitle: 'Late-night intimacy',
      imageAsset: 'assets/images/img_54.jpg',
    ),
  ];

  static const List<String> _tempos = [
    'Tuned / Quiet',
    'Conversational',
    'Lively Buzz',
  ];

  @override
  Widget build(BuildContext context) {
    final tunedPercent =
        (45 + (_selectedMoods.length * 8) + (_contactsLinked ? 15 : 0)).clamp(
          35,
          100,
        );

    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
                    children: [
                      // Top Step Indicator + Close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CornerText(
                            'STEP 2 OF 3 · TASTE RADAR CALIBRATION',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.secondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Row(
                            children: [
                              CornerText(
                                '$tunedPercent% Tuned',
                                style: CornerTypography.labelSm.copyWith(
                                  color: CornerColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: CornerColors.surfaceContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: CornerColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: tunedPercent / 100.0,
                          minHeight: 4,
                          backgroundColor: CornerColors.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CornerColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Headline & Description
                      const CornerText(
                        'Calibrate your palate.',
                        style: CornerTypography.headlineLgMobile,
                      ),
                      const SizedBox(height: 8),
                      CornerText(
                        'Corner has no algorithmic feed or paid ads. Tell us what atmospheres resonate with you so we can tune your city map.',
                        style: CornerTypography.bodyMd.copyWith(
                          color: CornerColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Atmosphere & Archetype Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CornerText(
                            'ATMOSPHERE & ARCHETYPE',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.secondary,
                              letterSpacing: 0.9,
                            ),
                          ),
                          CornerText(
                            '${_selectedMoods.length} selected',
                            style: CornerTypography.labelSm.copyWith(
                              color: CornerColors.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2x3 Mood Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.94,
                            ),
                        itemCount: _moods.length,
                        itemBuilder: (context, index) {
                          final mood = _moods[index];
                          final isSelected = _selectedMoods.contains(
                            mood.title,
                          );
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedMoods.remove(mood.title);
                                } else {
                                  _selectedMoods.add(mood.title);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? CornerColors.surfaceContainerLowest
                                    : CornerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            mood.imageAsset,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 180,
                                              ),
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? CornerColors.primary
                                                    : CornerColors
                                                          .surfaceContainerHigh
                                                          .withValues(
                                                            alpha: 0.80,
                                                          ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check_rounded,
                                                size: 15,
                                                color: isSelected
                                                    ? CornerColors.onPrimary
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  CornerText(
                                    mood.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CornerTypography.headlineSm.copyWith(
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  CornerText(
                                    mood.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CornerTypography.labelSm.copyWith(
                                      color: CornerColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Acoustic Preference (Decibel mood)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CornerText(
                            'ACOUSTIC PREFERENCE',
                            style: CornerTypography.labelCaps.copyWith(
                              color: CornerColors.secondary,
                            ),
                          ),
                          CornerText(
                            'Decibel mood',
                            style: CornerTypography.labelSm.copyWith(
                              color: CornerColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: _tempos.map((tempo) {
                            final isActive = tempo == _selectedTempo;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTempo = tempo),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? CornerColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  alignment: Alignment.center,
                                  child: CornerText(
                                    tempo,
                                    style: CornerTypography.labelSm.copyWith(
                                      color: isActive
                                          ? CornerColors.onPrimary
                                          : CornerColors.onSurfaceVariant,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Find your friends in the real world (Contacts Card)
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: CornerColors.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.contacts_outlined,
                                size: 20,
                                color: CornerColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CornerText(
                                    'Find your friends in the real world',
                                    style: CornerTypography.headlineSm,
                                  ),
                                  const SizedBox(height: 4),
                                  CornerText(
                                    'See spots curated by friends in your contacts. No mutuals are notified without your permission.',
                                    style: CornerTypography.bodySm.copyWith(
                                      color: CornerColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: CornerText(
                                                'Address book matching is not available yet. No contacts have been accessed.',
                                              ),
                                            ),
                                          );
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _contactsLinked
                                            ? CornerColors.surfaceContainerHigh
                                            : CornerColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _contactsLinked
                                                ? Icons.check_circle_rounded
                                                : Icons.sync_alt_rounded,
                                            size: 18,
                                            color: CornerColors.onSurface,
                                          ),
                                          const SizedBox(width: 8),
                                          CornerText(
                                            _contactsLinked
                                                ? 'Contacts Linked'
                                                : 'Connect Address Book',
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
                    ],
                  ),

                  // Sticky Bottom CTA Bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            CornerColors.surface,
                            CornerColors.surface.withValues(alpha: 0.96),
                            CornerColors.surface.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CornerColors.primary,
                                foregroundColor: CornerColors.onPrimary,
                                shape: const StadiumBorder(),
                                elevation: 2,
                              ),
                              onPressed: _saving ? null : _savePreferences,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CornerText(
                                    _saving
                                        ? 'Saving your palate…'
                                        : 'Continue to My City Map',
                                    style: CornerTypography.labelMd.copyWith(
                                      color: CornerColors.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: CornerColors.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: CornerText(
                                'Skip for now, explore as guest',
                                style: CornerTypography.labelSm.copyWith(
                                  color: CornerColors.secondary,
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
    );
  }
}

class _MoodArchetype {
  final String title;
  final String subtitle;
  final String imageAsset;

  const _MoodArchetype({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}
