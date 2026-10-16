import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:corner_story/settings/app_settings.dart';
import 'package:corner_story/services/corner_library.dart';
import 'package:corner_story/theme/corner_theme.dart';
import 'package:corner_story/l10n/app_localizations.dart';
import 'package:corner_story/screens/app_settings_screen.dart';

class MemoryLibrary extends CornerLibrary {
  final values = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> read() async => Map.of(values);

  @override
  Future<void> put(String key, Object value) async => values[key] = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'settings restore preferences and reject unknown stored values',
    () async {
      final storage = MemoryLibrary();
      final settings = AppSettingsController(storage: storage);
      await settings.load();
      expect(settings.appearance, AppAppearance.warm);
      expect(settings.language, AppLanguage.device);

      await settings.setAppearance(AppAppearance.monochrome);
      await settings.setLanguage(AppLanguage.traditionalChinese);
      final restored = AppSettingsController(storage: storage);
      await restored.load();
      expect(restored.appearance, AppAppearance.monochrome);
      expect(restored.locale, const Locale('zh', 'TW'));

      storage.values['appearance'] = 'unknown';
      storage.values['language'] = 'unknown';
      await restored.load();
      expect(restored.appearance, AppAppearance.warm);
      expect(restored.language, AppLanguage.device);
      settings.dispose();
      restored.dispose();
    },
  );

  test('device locale fallback is English', () {
    expect(
      AppSettingsController.resolveDeviceLocale(const Locale('fr')),
      const Locale('en'),
    );
    expect(
      AppSettingsController.resolveDeviceLocale(const Locale('zh', 'HK')),
      const Locale('zh', 'TW'),
    );
  });

  testWidgets('interface text changes for both Chinese locales', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'CN'),
        supportedLocales: [
          Locale('en'),
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: CornerText('Appearance & Language')),
      ),
    );
    expect(find.text('外观与语言'), findsOneWidget);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh', 'TW'),
        supportedLocales: [
          Locale('en'),
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: CornerText('Appearance & Language')),
      ),
    );
    expect(find.text('外觀與語言'), findsOneWidget);
  });

  testWidgets('settings screen switches palette and language', (tester) async {
    final oldSettings = appSettings;
    final storage = MemoryLibrary();
    appSettings = AppSettingsController(storage: storage);
    addTearDown(() {
      appSettings.dispose();
      appSettings = oldSettings;
    });
    await appSettings.load();
    await tester.pumpWidget(
      AnimatedBuilder(
        animation: appSettings,
        builder: (context, _) => MaterialApp(
          locale: appSettings.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('zh', 'CN'),
            Locale('zh', 'TW'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AppSettingsScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Monochrome'));
    await tester.pumpAndSettle();
    expect(CornerColors.surface, const Color(0xFFFFFFFF));
    await tester.tap(find.text('繁體中文'));
    await tester.pumpAndSettle();
    expect(find.text('外觀與語言'), findsOneWidget);
    expect(storage.values['appearance'], 'monochrome');
    expect(storage.values['language'], 'traditionalChinese');
  });
}
