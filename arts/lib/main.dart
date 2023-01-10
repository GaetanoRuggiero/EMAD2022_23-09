import 'package:arts/utils/user_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';
import './ui/splashscreen.dart';
import './ui/styles.dart';
import './utils/settings_model.dart';

late final CameraDescription camera;
late SettingsModel settingsModel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requesting latest Google Maps renderer (on Android)
  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    try {
      await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
    } catch(e) {
      debugPrint("The renderer can be requested only once!");
    }
  }

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  camera = cameras.first;

  // Initializing app's locale and theme by reading from SharedPreferences
  settingsModel = SettingsModel();
  await settingsModel.getThemePreferences();
  await settingsModel.getLanguagePreferences();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsModel),
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: Consumer<SettingsModel>(
        builder: (context, settingsNotifier, child) {
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
            locale: settingsNotifier.languageMode,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: settingsNotifier.themeMode,
            home: const SplashScreen()
          );
        }
      )
    );
  }
}