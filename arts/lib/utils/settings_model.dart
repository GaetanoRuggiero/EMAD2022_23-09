import 'package:flutter/material.dart';
import './theme_preferences.dart';
import 'language_preferences.dart';

class SettingsModel extends ChangeNotifier {

  static const light = 0;
  static const dark = 1;
  static const system = 2;

  static const italian = "it_IT";
  static const english = "en_US";

  int? _themeMode;
  String? _languageMode;

  ThemePreferences _themePreferences = ThemePreferences();
  LanguagePreferences _languagePreferences = LanguagePreferences();

  int? get themeMode => _themeMode;
  String? get languageMode => _languageMode;

  set themeMode(int? value) {
    _themeMode = value;
    _themePreferences.setTheme(value);
    notifyListeners();
  }

  Future<int?> getThemePreferences() async {
    _themeMode = (await _themePreferences.getTheme())!;
    notifyListeners();
    return _themeMode;
  }

  set languageMode(String? value) {
    _languageMode = value;
    _languagePreferences.setLanguage(value);
    notifyListeners();
  }

  Future<String?> getLanguagePreferences() async {
    _languageMode = (await _languagePreferences.getLanguage())!;
    notifyListeners();
    return _languageMode;
  }

  SettingsModel() {
    _themePreferences = ThemePreferences();
    getThemePreferences();
    _languagePreferences = LanguagePreferences();
    getLanguagePreferences();
  }

}