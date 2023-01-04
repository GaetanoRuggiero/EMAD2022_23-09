import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './login.dart';
import './welcomeback.dart';
import '../utils/user_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<Widget> _startingScreenFuture;

  Widget setStartingScreen(bool? isLogged) {
    if (isLogged == null) {
      //TODO: we should pass parameter to show "token expired message"
      return const LoginScreen();
    } else if (isLogged) {
      return const WelcomeBackScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _startingScreenFuture = Future.delayed(const Duration(seconds: 1), () {
      return UserUtils.isLogged().then((value) {
        debugPrint("isLogged == $value");
        return setStartingScreen(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startingScreenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!;
        }
        else {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(AppLocalizations.of(context)!.loading),
                    ),
                  ]
                )
              ),
            ),
          );
        }
      }
    );
  }
}