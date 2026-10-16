import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/corner_l10n.dart';
import '../settings/app_settings.dart';

import '../screens/spot_detail_screen.dart';
import '../screens/taste_onboarding_screen.dart';
import '../services/corner_library.dart';

String cornerCopy(BuildContext context, String source) =>
    CornerL10n.translate(context, source);

/// Keeps existing text styling while translating app-owned interface copy.
class CornerText extends Text {
  const CornerText(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.semanticsIdentifier,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final source = data;
    if (source == null) return super.build(context);
    final translated = CornerL10n.translate(context, source);
    if (translated == source) return super.build(context);
    return Text(
      translated,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel == null
          ? null
          : CornerL10n.translate(context, semanticsLabel!),
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

/// Design tokens and typography from "Warm Editorial Sanctuary" (DESIGN.md)
class CornerColors {
  CornerColors._();

  static bool get _mono => appSettings.appearance == AppAppearance.monochrome;
  static Color get surface =>
      _mono ? const Color(0xFFFFFFFF) : const Color(0xFFFBF9F5);
  static Color get surfaceDim =>
      _mono ? const Color(0xFFD9D9D9) : const Color(0xFFDBDAD6);
  static Color get surfaceBright => surface;
  static Color get surfaceContainerLowest => const Color(0xFFFFFFFF);
  static Color get surfaceContainerLow =>
      _mono ? const Color(0xFFF5F5F5) : const Color(0xFFF5F3EF);
  static Color get surfaceContainer =>
      _mono ? const Color(0xFFEEEEEE) : const Color(0xFFEFEEEA);
  static Color get surfaceVariant =>
      _mono ? const Color(0xFFE2E2E2) : const Color(0xFFE4E2DE);
  static Color get surfaceContainerHigh =>
      _mono ? const Color(0xFFE8E8E8) : const Color(0xFFEAE8E4);
  static Color get surfaceContainerHighest => surfaceVariant;

  static Color get onSurface =>
      _mono ? const Color(0xFF161616) : const Color(0xFF1B1C1A);
  static Color get onSurfaceVariant =>
      _mono ? const Color(0xFF444444) : const Color(0xFF474741);
  static Color get inverseSurface =>
      _mono ? const Color(0xFF222222) : const Color(0xFF30312E);
  static Color get inverseOnSurface =>
      _mono ? const Color(0xFFFFFFFF) : const Color(0xFFF2F0ED);

  static Color get outline =>
      _mono ? const Color(0xFF777777) : const Color(0xFF777771);
  static Color get outlineVariant =>
      _mono ? const Color(0xFFC7C7C7) : const Color(0xFFC8C7BF);
  static Color get hairline =>
      _mono ? const Color(0xFFE3E3E3) : const Color(0xFFE6E2DA);

  static Color get primary =>
      _mono ? const Color(0xFF111111) : const Color(0xFF1A1A18);
  static Color get onPrimary => const Color(0xFFFFFFFF);
  static Color get primaryContainer =>
      _mono ? const Color(0xFF222222) : const Color(0xFF1C1C1A);
  static Color get onPrimaryContainer =>
      _mono ? const Color(0xFFBBBBBB) : const Color(0xFF858481);

  static Color get secondary =>
      _mono ? const Color(0xFF555555) : const Color(0xFF615E58);
  static Color get onSecondary => const Color(0xFFFFFFFF);
  static Color get secondaryContainer =>
      _mono ? const Color(0xFFE5E5E5) : const Color(0xFFE7E2DA);
  static Color get onSecondaryContainer =>
      _mono ? const Color(0xFF555555) : const Color(0xFF67645E);

  static Color get tertiaryContainer =>
      _mono ? const Color(0xFF292929) : const Color(0xFF390C00);
  static Color get onTertiaryContainer =>
      _mono ? const Color(0xFF555555) : const Color(0xFFD3623A);
  static Color get terracotta =>
      _mono ? const Color(0xFF444444) : const Color(0xFFC85A32);
  static Color get tertiaryFixed =>
      _mono ? const Color(0xFFE0E0E0) : const Color(0xFFFFDBCF);
  static Color get tertiaryFixedDim =>
      _mono ? const Color(0xFFC0C0C0) : const Color(0xFFFFB59C);
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
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: serifFamily,
    fontSize: 30,
    fontWeight: FontWeight.w400,
    height: 38 / 30,
    letterSpacing: -0.3,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: serifFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: serifFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 30 / 22,
    letterSpacing: -0.11,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle titleEditorial = TextStyle(
    fontFamily: serifFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 28 / 20,
    letterSpacing: 0,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 28 / 17,
    letterSpacing: -0.17,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    letterSpacing: -0.075,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 20 / 13,
    letterSpacing: 0,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.14,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.24,
    color: Color(0xFF1B1B1B),
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    letterSpacing: 0.88,
    color: Color(0xFF1B1B1B),
  );
}

/// Top Frosted Editorial App Bar shared across all 4 tabs
class CornerTopBar extends StatelessWidget {
  final String sectionLabel;
  final VoidCallback onProfileTap;
  final VoidCallback? onPalateCompleted;

  const CornerTopBar({
    super.key,
    required this.sectionLabel,
    required this.onProfileTap,
    this.onPalateCompleted,
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
                      const CornerText(
                        'Corner',
                        style: CornerTypography.titleEditorial,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context)
                              .push<List<String>>(
                                MaterialPageRoute(
                                  builder: (_) => const TasteOnboardingScreen(),
                                ),
                              );
                          if (context.mounted && result != null) {
                            onPalateCompleted?.call();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CornerColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 14,
                                color: CornerColors.onSurface,
                              ),
                              const SizedBox(width: 4),
                              CornerText(
                                'Palate',
                                style: CornerTypography.labelSm.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onProfileTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 36,
                          height: 36,
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
            border: Border(
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
            Icon(isActive ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 4),
            CornerText(
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

/// Compact detail header that keeps the title within narrow phone widths.
class CornerPageHeader extends StatelessWidget {
  const CornerPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onShare,
  });
  final String title;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
    decoration: BoxDecoration(
      color: CornerColors.surface.withValues(alpha: 0.94),
      border: Border(bottom: BorderSide(color: CornerColors.hairline)),
    ),
    child: SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              tooltip: cornerCopy(context, 'Back'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
            Expanded(
              child: CornerText(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CornerTypography.titleEditorial,
              ),
            ),
            IconButton(
              tooltip: cornerCopy(context, 'Copy link'),
              onPressed: onShare,
              icon: const Icon(Icons.ios_share_rounded, size: 20),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: CornerColors.primary,
              child: Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: CornerColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Opens the full Stitch Place Detail View (`SpotDetailScreen`)
Future<bool?> showSpotDetailModal(
  BuildContext context, {
  required String name,
  required String neighborhoodAndPrice,
  required String rating,
  required String description,
  required String imageAsset,
  required String categoryBadge,
  String? spotId,
  bool initialSaved = false,
  Map<String, dynamic>? verifiedData,
  String acousticNote = '72 dB · Warm Vinyl & Low Conversation',
  String hours = 'Open today · 5:00 PM – 1:00 AM',
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      builder: (_) => SpotDetailScreen(
        spotId: spotId ?? apiSpotIdForName(name),
        initialSaved: initialSaved,
        verifiedData: verifiedData,
        name: name,
        neighborhoodAndPrice: neighborhoodAndPrice,
        rating: rating,
        description: description,
        imageAsset: imageAsset,
        categoryBadge: categoryBadge,
        acousticNote: verifiedData == null ? acousticNote : '',
        hours: verifiedData?['hours_text']?.toString() ?? hours,
      ),
    ),
  );
}
