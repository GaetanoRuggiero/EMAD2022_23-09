import 'package:flutter/material.dart';
import './language_preferences.dart';
import './theme_preferences.dart';

class SettingsModel extends ChangeNotifier {

  static const int light = 0;
  static const int dark = 1;
  static const int system = 2;

  static const Locale italian = Locale("it", "IT");
  static const Locale english = Locale("en", "US");
  static const Locale espanol = Locale("es", "ES");

  late ThemeMode _themeMode;
  late Locale _languageMode;

  late ThemePreferences _themePreferences;
  late LanguagePreferences _languagePreferences;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    _themeMode = value;
    if (_themeMode == ThemeMode.dark) {
      _themePreferences.setTheme(dark);
    } else if (_themeMode == ThemeMode.system) {
      _themePreferences.setTheme(system);
    } else {
      _themePreferences.setTheme(light);
    }
    debugPrint("[App Settings] Setting theme to: ${_themeMode.name}");
    notifyListeners();
  }

  Locale get languageMode => _languageMode;

  set languageMode(Locale value) {
    _languageMode = value;
    if (_languageMode == italian) {
      debugPrint("[App Settings] Setting locale to: ${italian.toLanguageTag()}");
      _languagePreferences.setLanguage(italian.toLanguageTag());
    } else if (_languageMode == english) {
      debugPrint("[App Settings] Setting locale to: ${english.toLanguageTag()}");
      _languagePreferences.setLanguage(english.toLanguageTag());
    } else {
      debugPrint("[App Settings] Setting locale to: ${italian.toLanguageTag()}");
      _languagePreferences.setLanguage(italian.toLanguageTag());
    }
    notifyListeners();
  }

  Future<ThemeMode> getThemePreferences() async {
    int? value = await _themePreferences.getTheme();
    if (value == null) {
      _themeMode = ThemeMode.light;
    }
    else if (value == dark) {
      _themeMode = ThemeMode.dark;
    } else if (value == system) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    debugPrint("[App Settings] Current theme: ${_themeMode.name}");
    notifyListeners();
    return _themeMode;
  }

  Future<Locale> getLanguagePreferences() async {
    String? value = await _languagePreferences.getLanguage();
    if (value == null) {
      _languageMode = italian;
    } else if (value == english.toLanguageTag()) {
      _languageMode = english;
    } else {
      _languageMode = italian;
    }
    debugPrint("[App Settings] Current locale: ${_languageMode.toLanguageTag()}");
    notifyListeners();
    return _languageMode;
  }

  SettingsModel() {
    _themePreferences = ThemePreferences();
    _languagePreferences = LanguagePreferences();
  }
}