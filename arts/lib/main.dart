import 'package:arts/ui/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'artS',
      theme: ThemeData(
        // This is the theme of your application.
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff113197),
              actionsIconTheme: IconThemeData(color: Color(0xffE68532)),
              iconTheme: IconThemeData(color: Color(0xffE68532))
          )
      ),
      home: const LoginScreen(),
    );
  }
}