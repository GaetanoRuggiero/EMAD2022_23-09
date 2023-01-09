import 'dart:async';
import 'package:arts/api/user_api.dart';
import 'package:arts/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../exception/exceptions.dart';
import '../model/POI.dart';
import './homepage.dart';
import './login.dart';
import '../utils/user_utils.dart';
import '../utils/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<User?> _startingScreenFuture;
  late Map<POI, String> _visitedPOI;

  Future<User?> initializeUser() async {
    try {
      String? email = await UserUtils.readEmail();
      String? token = await UserUtils.readToken();
      if (email != null && token != null) {
        User? user = await UserUtils.isLogged(email, token);
        if (user != null) {
          _visitedPOI = await getVisitedPOI(email, token);
        }
        return user;
      } else {
        UserUtils.deleteEmailAndToken();
      }
    } on ConnectionErrorException catch(e) {
      return Future.error(e);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    _startingScreenFuture = initializeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _startingScreenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                Future.delayed(const Duration(seconds: 2), () {
                  Future.microtask(() {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen())
                    );
                  });
                });
                return Center(
                  child: Column(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.connectionError, textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Theme.of(context).textTheme.bodyText1?.color)),
                        const Icon(
                          Icons.error_outline_outlined,
                          color: Colors.red,
                          size: 40,
                        ),
                      ]
                  ),
                );
              }
              User? user = snapshot.data;
              return Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (user == null) {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()));
                    });
                  } else {
                    userProvider.isLogged = true;
                    userProvider.name = user.name!;
                    userProvider.surname = user.surname!;
                    userProvider.visited = _visitedPOI;
                    Future.delayed(const Duration(seconds: 2), () {
                      Future.microtask(() {
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