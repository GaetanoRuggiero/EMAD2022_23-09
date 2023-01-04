import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {

  static const prefKey = 'theme';

  setTheme (int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(prefKey, value);
  }

  Future<int?> getTheme () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? value = sharedPreferences.getInt(prefKey);
    return value;
  }

}