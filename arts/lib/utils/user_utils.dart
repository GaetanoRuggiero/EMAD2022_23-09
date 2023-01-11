import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/user_api.dart';
import 'package:email_validator/email_validator.dart';
import '../model/POI.dart';
import '../model/user.dart';

class UserUtils {
  static const String tokenKey = "authToken";
  static const String emailKey = "email";

  static Future<User?> isLogged (String email, String token) async {
    User? user = await checkIfLogged(email, token);
    return user;
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

  static deleteEmailAndToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: UserUtils.tokenKey);
    await storage.delete(key: UserUtils.emailKey);
  }

  static Future<String?> readEmail() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: emailKey);
  }

  static Future<String?> readToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: tokenKey);
  }

  static Map<String, int> getBadgePerRegion(Map<POI,String> visitedPoi) {
    Map<String, int> badgeMap = {};
    visitedPoi.forEach((poi, timestamp) {
      badgeMap.update(poi.region!, (value) => value + 1, ifAbsent: () => 1);
    });
    return Map.fromEntries(badgeMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

}