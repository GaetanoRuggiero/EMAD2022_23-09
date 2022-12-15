import '../utils/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {

  static const prefKey = 'theme';

  setTheme (int? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(value!=null) {
      sharedPreferences.setInt(prefKey, value);
    }
    else {
      sharedPreferences.setInt(prefKey, SettingsModel.light);
    }
  }

  Future<int?> getTheme () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? value = sharedPreferences.getInt(prefKey);
    if (value != null) {
      return sharedPreferences.getInt(prefKey);
    }
    else {
      return SettingsModel.light;
    }
  }
}