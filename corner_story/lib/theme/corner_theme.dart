import 'dart:ui';
import 'package:flutter/material.dart';

/// Design tokens and typography from "Warm Editorial Sanctuary" (DESIGN.md)
class CornerColors {
  CornerColors._();

  static const Color surface = Color(0xFFFBF9F5);
  static const Color surfaceDim = Color(0xFFDBDAD6);
  static const Color surfaceBright = Color(0xFFFBF9F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EF);
  static const Color surfaceContainer = Color(0xFFEFEEEA);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E4);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DE);

  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color onSurfaceVariant = Color(0xFF474741);
  static const Color inverseSurface = Color(0xFF30312E);
  static const Color inverseOnSurface = Color(0xFFF2F0ED);

  static const Color outline = Color(0xFF777771);
  static const Color outlineVariant = Color(0xFFC8C7BF);
  static const Color hairline = Color(0xFFE6E2DA);

  static const Color primary = Color(0xFF1A1A18);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C1C1A);
  static const Color onPrimaryContainer = Color(0xFF858481);

  static const Color secondary = Color(0xFF615E58);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE7E2DA);
  static const Color onSecondaryContainer = Color(0xFF67645E);

  static const Color tertiaryContainer = Color(0xFF390C00);
  static const Color onTertiaryContainer = Color(0xFFD3623A);
  static const Color terracotta = Color(0xFFC85A32);
  static const Color tertiaryFixed = Color(0xFFFFDBCF);
  static const Color tertiaryFixedDim = Color(0xFFFFB59C);
}

class CornerTypography {
  CornerTypography._();

  static const String serifFamily = 'Newsreader';
  static const String sansFamily = 'PlusJakartaSans';

  static const TextStyle displayMobile = TextStyle(
    fontFamily: serifFamily,
    fontSize: 40,
    fontWeight: FontWeight.w400,
    height: 48 / 40,
    letterSpacing: -0.6,
    color: CornerColors.onSurface,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: serifFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 38 / 30,
    letterSpacing: -0.3,
    color: CornerColors.onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: serifFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: CornerColors.onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: serifFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 30 / 22,
    letterSpacing: -0.11,
    color: CornerColors.onSurface,
  );

  static const TextStyle titleEditorial = TextStyle(
    fontFamily: serifFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 28 / 20,
    letterSpacing: 0,
    color: CornerColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 28 / 17,
    letterSpacing: -0.17,
    color: CornerColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    letterSpacing: -0.075,
    color: CornerColors.onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    letterSpacing: 0,
    color: CornerColors.onSurface,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.14,
    color: CornerColors.onSurface,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.24,
    color: CornerColors.onSurface,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    letterSpacing: 0.88,
    color: CornerColors.onSurface,
  );
}

/// Top Frosted Editorial App Bar shared across all 4 tabs
class CornerTopBar extends StatelessWidget {
  final String sectionLabel;
  final VoidCallback onProfileTap;

  const CornerTopBar({
    super.key,
    required this.sectionLabel,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: CornerColors.surface.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/img_01.jpg',
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Corner',
                        style: CornerTypography.titleEditorial,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onProfileTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.centerRight,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/img_02.jpg',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Frosted Navigation Bar with 4 Editorial Tabs
class CornerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CornerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: CornerColors.surface.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B1C1A).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
            border: const Border(
              top: BorderSide(color: CornerColors.hairline, width: 0.8),
            ),
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'EXPLORE',
                  isActive: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on,
                  label: 'MAP',
                  isActive: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'VIBES',
                  isActive: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.bookmark_border_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'SAVED',
                  isActive: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? CornerColors.primary : CornerColors.secondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: CornerTypography.labelCaps.copyWith(
                fontSize: 10.5,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Spot Detail Modal Sheet (Phase 3 Spec)
void showSpotDetailModal(
  BuildContext context, {
  required String name,
  required String neighborhoodAndPrice,
  required String rating,
  required String description,
  required String imageAsset,
  required String categoryBadge,
  String acousticNote = '72 dB · Warm Vinyl & Low Conversation',
  String hours = 'Open today · 5:00 PM – 1:00 AM',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      bool isSaved = true;
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            margin: const EdgeInsets.only(top: 72),
            decoration: const BoxDecoration(
              color: CornerColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.asset(
                          imageAsset,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: CornerColors.surfaceContainerLowest
                                  .withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              neighborhoodAndPrice.toUpperCase(),
                              style: CornerTypography.labelCaps,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: CornerTypography.headlineMd,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CornerColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: CornerColors.onSurface,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating,
                              style: CornerTypography.labelCaps,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: CornerTypography.bodyMd.copyWith(
                      color: CornerColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CornerColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: CornerColors.hairline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.graphic_eq_rounded,
                              size: 18,
                              color: CornerColors.terracotta,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Acoustic Index: $acousticNote',
                                style: CornerTypography.bodySm,
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 20,
                          color: CornerColors.hairline,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: CornerColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                hours,
                                style: CornerTypography.bodySm,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: CornerColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                categoryBadge.toUpperCase(),
                                style: CornerTypography.labelCaps.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => isSaved = !isSaved);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? CornerColors.secondaryContainer
                                  : CornerColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: CornerColors.hairline),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: CornerColors.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSaved ? 'Saved to Corner' : 'Save Spot',
                                  style: CornerTypography.labelMd,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added $name to your weekend plan'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: CornerColors.primary,
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: CornerColors.primary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.near_me_outlined,
                                  size: 17,
                                  color: CornerColors.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Plan Visit',
                                  style: CornerTypography.labelMd.copyWith(
                                    color: CornerColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
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
      );
    },
  );
}
