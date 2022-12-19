import 'package:arts/ui/welcomeback.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/ui/login.dart';
import 'package:arts/utils/settings_model.dart';

import 'api/user_api.dart';

late final CameraDescription camera;
const String tokenKey = "authToken";
const String emailKey = "email";
bool? isLogged = false;

Future<void> main() async {
  /* Ensure that plugin services are initialized so that 'availableCameras()'
    can be called before 'runApp()'*/
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  camera = cameras.first;

  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: tokenKey);
  String? email = await storage.read(key: emailKey);
  if (token != null && email != null) {
    isLogged = await checkIfLogged(email, token);
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsModel(),
      child: Consumer(
          builder: (context, SettingsModel settingsNotifier, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'artS',
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('it', 'IT'),
                Locale('en', 'US')
              ],
              locale: setAppLanguage(settingsNotifier),
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: setAppThemeMode(settingsNotifier),
              home: setStartingPoint(isLogged) ,
            );
          }
      ),
    );
  }

  ThemeMode setAppThemeMode(SettingsModel settingsNotifier) {

    if (settingsNotifier.themeMode == SettingsModel.dark) {
      return ThemeMode.dark;
    }
    else if (settingsNotifier.themeMode == SettingsModel.system) {
      return ThemeMode.system;
    }
    else {
      return ThemeMode.light;
    }
  }

  Locale setAppLanguage(SettingsModel settingsNotifier) {

    String languageCode, countryCode;

    if (settingsNotifier.languageMode == SettingsModel.italian) {
      languageCode = SettingsModel.italian.substring(0,2);
      countryCode = SettingsModel.italian.substring(3,5);
      debugPrint("LanguageCode: $languageCode\n CountryCode: $countryCode");
      return Locale.fromSubtags(languageCode: languageCode, countryCode: countryCode);
    }

    languageCode = SettingsModel.english.substring(0,2);
    countryCode = SettingsModel.english.substring(3,5);
    debugPrint("LanguageCode: $languageCode\n CountryCode: $countryCode");
    return Locale.fromSubtags(languageCode: languageCode, countryCode: countryCode);
  }

  Widget setStartingPoint(bool? isLogged) {
    if (isLogged == null) {
      debugPrint("islogged==null");
      //TODO: we should pass parameter to show "token expired message"
      return const LoginScreen();
    } else if (isLogged) {
      debugPrint("islogged==true");
      return const WelcomeBackScreen();
    } else {
      debugPrint("islogged==false");
      return const LoginScreen();
    }
  }

}