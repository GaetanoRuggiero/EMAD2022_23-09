import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'serverIP', obfuscate: true)
  static String serverIP = _Env.serverIP;
  @EnviedField(varName: 'serverPort', obfuscate: true)
  static int serverPort = _Env.serverPort;
  @EnviedField(varName: 'apiKey', obfuscate: true)
  static String apiKey = _Env.apiKey;
}