import 'package:flutter/material.dart';
import './theme_preferences.dart';

class ThemeModel extends ChangeNotifier {

  static const light = 0;
  static const dark = 1;
  static const system = 2;

  int? _themeMode;

  ThemePreferences _preferences = ThemePreferences();

  int? get themeMode => _themeMode;

  set themeMode(int? value) {
    _themeMode = value;
    _preferences.setTheme(value);
    notifyListeners();
  }

  Future<int?> getPreferences() async {
    _themeMode = (await _preferences.getTheme())!;
    notifyListeners();
    return _themeMode;
  }

  ThemeModel() {
    _preferences = ThemePreferences();
    getPreferences();
  }
}