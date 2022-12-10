import 'package:arts/ui/login.dart';
import 'package:arts/utils/theme_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arts/ui/styles.dart';

late final CameraDescription camera;

Future<void> main() async {
  /* Ensure that plugin services are initialized so that 'availableCameras()'
    can be called before 'runApp()'*/
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  camera = cameras.first;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer(
          builder: (context, ThemeModel themeNotifier, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'artS',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: setAppThemeMode(themeNotifier),
              home: const LoginScreen(),
            );
          }
      ),
    );
  }

  ThemeMode setAppThemeMode(ThemeModel themeNotifier) {

    if (themeNotifier.themeMode == ThemeModel.dark) {
      return ThemeMode.dark;
    }
    else if (themeNotifier.themeMode == ThemeModel.system) {
      return ThemeMode.system;
    }
    else {
      return ThemeMode.light;
    }
  }
}