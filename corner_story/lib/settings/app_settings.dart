import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../services/corner_library.dart';

enum AppAppearance { warm, monochrome }

enum AppLanguage { device, english, simplifiedChinese, traditionalChinese }

AppSettingsController appSettings = AppSettingsController();

class AppSettingsController extends ChangeNotifier with WidgetsBindingObserver {
  AppSettingsController({CornerLibrary? storage})
    : _storage = storage ?? CornerLibrary.instance;

  final CornerLibrary _storage;
  AppAppearance _appearance = AppAppearance.warm;
  AppLanguage _language = AppLanguage.device;
  bool _observing = false;

  AppAppearance get appearance => _appearance;
  AppLanguage get language => _language;

  Locale get locale => switch (_language) {
    AppLanguage.english => const Locale('en'),
    AppLanguage.simplifiedChinese => const Locale('zh', 'CN'),
    AppLanguage.traditionalChinese => const Locale('zh', 'TW'),
    AppLanguage.device => resolveDeviceLocale(
      PlatformDispatcher.instance.locale,
    ),
  };

  static Locale resolveDeviceLocale(Locale device) {
    if (device.languageCode != 'zh') return const Locale('en');
    if (device.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(device.countryCode)) {
      return const Locale('zh', 'TW');
    }
    return const Locale('zh', 'CN');
  }

  Future<void> load() async {
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    try {
      final values = await _storage.read();
      _appearance = AppAppearance.values.firstWhere(
        (value) => value.name == values['appearance'],
        orElse: () => AppAppearance.warm,
      );
      _language = AppLanguage.values.firstWhere(
        (value) => value.name == values['language'],
        orElse: () => AppLanguage.device,
      );
    } catch (_) {
      _appearance = AppAppearance.warm;
      _language = AppLanguage.device;
    }
    notifyListeners();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (_language == AppLanguage.device) notifyListeners();
  }

  @override
  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> setAppearance(AppAppearance value) async {
    if (_appearance == value) return;
    _appearance = value;
    notifyListeners();
    await _storage.put('appearance', value.name);
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    await _storage.put('language', value.name);
  }
}
