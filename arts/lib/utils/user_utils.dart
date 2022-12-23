import 'package:flutter/cupertino.dart';
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
      bool? logSucc = await checkIfLogged(email, token);
      debugPrint("$logSucc");
      return logSucc;
    }
    debugPrint("return null");
    return null;
  }

  static bool validateEmail(String val) {
    return EmailValidator.validate(val, true);
  }

  static bool validatePass(String val) {
    //TODO: add regex
    if (val.length < 8) {
      return false;
    }
    return true;
  }

}