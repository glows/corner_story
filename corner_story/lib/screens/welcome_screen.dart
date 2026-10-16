import 'package:flutter/material.dart';

import '../theme/corner_theme.dart';
import 'taste_onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onSignIn});
  final VoidCallback onSignIn;

  Future<void> _calibrate(BuildContext context) async {
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(builder: (_) => const TasteOnboardingScreen()),
    );
    if (result != null) onSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CornerColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          children: [
            CornerText(
              'corner',
              style: CornerTypography.headlineSm.copyWith(fontSize: 25),
            ),
            const SizedBox(height: 1),
            const CornerText(
              'EST. 2024 · AN IRL ATLAS',
              style: CornerTypography.labelCaps,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 270,
              child: Row(
                children: [
                  Expanded(flex: 7, child: _photo('assets/images/img_01.jpg')),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Expanded(child: _photo('assets/images/img_05.jpg')),
                        const SizedBox(height: 10),
                        Expanded(child: _photo('assets/images/img_08.jpg')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            const CornerText(
              '—  ISSUE NO. 01 · THE MANIFESTO',
              style: CornerTypography.labelCaps,
            ),
            const SizedBox(height: 14),
            CornerText(
              'Real palates.',
              style: CornerTypography.headlineLgMobile.copyWith(fontSize: 34),
            ),
            CornerText(
              'More time in the real world.',
              style: CornerTypography.displayMobile.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 39,
              ),
            ),
            const SizedBox(height: 22),
            const CornerText(
              'An intimate sanctuary away from sponsored hype, TikTok queues, and tourist traps. Curate quiet wine bars, hidden listening lounges, and sunlit corners with the people whose taste you trust.',
              style: CornerTypography.bodyLg,
            ),
            const SizedBox(height: 24),
            const _ManifestoCard(
              number: '01',
              title: 'Zero Paid Ads & Noise',
              detail: 'Places cataloged and reviewed only by real friends—never sponsored, never boosted.',
            ),
            const _ManifestoCard(
              number: '02',
              title: 'Vibe & Acoustic First',
              detail: 'Find spaces for conversations, warm light, and a pace that feels like yours.',
            ),
            const _ManifestoCard(
              number: '03',
              title: 'Privacy by Design',
              detail: 'You choose who can see your places and your circle.',
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => _calibrate(context),
              style: FilledButton.styleFrom(
                backgroundColor: CornerColors.primary,
                minimumSize: const Size.fromHeight(52),
              ),
              child: const CornerText('Begin Taste Calibration  →'),
            ),
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: CornerColors.surfaceContainerLow,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const CornerText('I already have a Corner · Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photo(String asset) => ClipRRect(
    borderRadius: BorderRadius.circular(25),
    child: Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    ),
  );
}

class _ManifestoCard extends StatelessWidget {
  const _ManifestoCard({
    required this.number,
    required this.title,
    required this.detail,
  });
  final String number;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    color: CornerColors.surfaceContainerLowest,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CornerText(
          number,
          style: CornerTypography.headlineMd.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CornerText(title, style: CornerTypography.labelMd),
              const SizedBox(height: 3),
              CornerText(detail, style: CornerTypography.bodySm),
            ],
          ),
        ),
      ],
    ),
  );
}
