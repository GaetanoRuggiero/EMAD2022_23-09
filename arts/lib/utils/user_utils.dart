import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/user_api.dart';
import 'package:email_validator/email_validator.dart';

class UserUtils {
  static const String tokenKey = "authToken";
  static const String emailKey = "email";

  static Future<bool?> isLogged () async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: tokenKey);
    String? email = await storage.read(key: emailKey);
    if (token != null && email != null) {
      bool? logged = await checkIfLogged(email, token);
      if (logged == false) {
        await storage.delete(key: UserUtils.tokenKey);
        await storage.delete(key: UserUtils.emailKey);
      }
      return logged;
    }
    return null;
  }

  static bool validateEmail(String val) {
    return EmailValidator.validate(val, true);
  }

  static bool validatePass(String val) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
    if (!regex.hasMatch(val)) {
      return false;
    }
    return true;
  }

  static Future<String?> readEmail() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: emailKey);
  }

  static Future<String?> readToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: tokenKey);
  }
}