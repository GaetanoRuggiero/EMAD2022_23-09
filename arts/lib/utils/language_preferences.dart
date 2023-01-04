import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {

  static const languageKey = 'language';

  setLanguage (String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(languageKey, value);
  }

  Future<String?> getLanguage () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? value = sharedPreferences.getString(languageKey);
    return value;
  }

}