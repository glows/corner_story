import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme/corner_theme.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appSettings,
    builder: (context, _) => Scaffold(
      backgroundColor: CornerColors.surface,
      appBar: AppBar(
        backgroundColor: CornerColors.surface,
        foregroundColor: CornerColors.onSurface,
        title: const CornerText('Appearance & Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const CornerText('Appearance', style: CornerTypography.headlineSm),
          const SizedBox(height: 8),
          _choice(
            context,
            'Warm Editorial',
            appSettings.appearance == AppAppearance.warm,
            () => appSettings.setAppearance(AppAppearance.warm),
          ),
          _choice(
            context,
            'Monochrome',
            appSettings.appearance == AppAppearance.monochrome,
            () => appSettings.setAppearance(AppAppearance.monochrome),
          ),
          const SizedBox(height: 24),
          const CornerText('Language', style: CornerTypography.headlineSm),
          const SizedBox(height: 8),
          _choice(
            context,
            'Follow Device',
            appSettings.language == AppLanguage.device,
            () => appSettings.setLanguage(AppLanguage.device),
          ),
          _choice(
            context,
            '简体中文',
            appSettings.language == AppLanguage.simplifiedChinese,
            () => appSettings.setLanguage(AppLanguage.simplifiedChinese),
          ),
          _choice(
            context,
            '繁體中文',
            appSettings.language == AppLanguage.traditionalChinese,
            () => appSettings.setLanguage(AppLanguage.traditionalChinese),
          ),
          _choice(
            context,
            'English',
            appSettings.language == AppLanguage.english,
            () => appSettings.setLanguage(AppLanguage.english),
          ),
        ],
      ),
    ),
  );

  Widget _choice(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) => ListTile(
    title: CornerText(label),
    trailing: selected
        ? Icon(Icons.check_rounded, color: CornerColors.onSurface)
        : null,
    selected: selected,
    onTap: onTap,
  );
}
