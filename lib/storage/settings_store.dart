import 'package:flutter/material.dart';

import 'boxes.dart';

class SettingsStore extends ChangeNotifier {
  static const _kThemeMode = 'themeMode'; // system/light/dark
  static const _kLang = 'lang'; // en/de

  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'en';

  SettingsStore() {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;

  Future<void> _load() async {
    final b = Boxes.box(Boxes.settings);
    final theme = b.get(_kThemeMode, defaultValue: 'system') as String;
    final lang = b.get(_kLang, defaultValue: 'en') as String;

    _themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    const supported = {'en', 'de', 'es', 'fr', 'it'};
    _languageCode = supported.contains(lang) ? lang : 'en';

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final b = Boxes.box(Boxes.settings);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await b.put(_kThemeMode, value);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    const supported = {'en', 'de', 'es', 'fr', 'it'};
    _languageCode = supported.contains(code) ? code : 'en';
    await Boxes.box(Boxes.settings).put(_kLang, _languageCode);
    notifyListeners();
  }
}
