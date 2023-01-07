import 'dart:async';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import './login.dart';
import '../utils/user_utils.dart';
import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<bool?> _startingScreenFuture;

  @override
  void initState() {
    super.initState();

    _startingScreenFuture = Future.delayed(const Duration(seconds: 1), () {
      return UserUtils.isLogged().then((value) {
        return value;
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _startingScreenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              bool? isLogged = snapshot.data;
              return Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (isLogged == null) {
                    //TODO: we should pass parameter to show "token expired message"
                    Future.microtask(() {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()));
                    });
                  } else if (isLogged) {
                    Future.delayed(const Duration(seconds: 2), () {
                      Future.microtask(() {
                        userProvider.isLogged= isLogged;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomePage())
                        );
                      });
                    });
                    return Center(
                      child: Column(
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.welcomeLog2, style: TextStyle(fontSize: 30, color: Theme.of(context).textTheme.bodyText1?.color)),
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(AppLocalizations.of(context)!.loggedSuccessfully),
                            )
                          ]
                      ),
                    );
                  } else {
                    userProvider.isLogged= isLogged;
                    Future.microtask(() {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()));
                    });
                  }
                  return Container();
                });
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
        ),
      ),
    );
  }
}