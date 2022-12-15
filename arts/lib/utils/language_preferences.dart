import 'package:arts/utils/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {

  static const languageKey = 'language';

  setLanguage (String? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(value!=null) {
      sharedPreferences.setString(languageKey, value);
    }
    else {
      sharedPreferences.setString(languageKey, SettingsModel.italian);
    }
  }

  Future<String?> getLanguage () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? value = sharedPreferences.getString(languageKey);
    if (value != null) {
      return sharedPreferences.getString(languageKey);
    }
    else {
      return SettingsModel.italian;
    }
  }
}