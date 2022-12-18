import 'package:arts/main.dart';
import 'package:arts/ui/homepage.dart';
import 'package:arts/ui/login.dart';
import 'package:arts/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  final storage = const FlutterSecureStorage();
  late String _token;
  late Future<bool> isLoggedFuture;

  Future<bool> checkIfLogged() async {
    String? token = await storage.read(key: authToken);
    if (token == null) {
      //TODO:create token
      return false;
    } else {
      //TODO:check validity of token
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    isLoggedFuture = checkIfLogged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
          child: RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context)!.welcomeLog2,
                  style: const TextStyle(fontSize: 30))),
        ),
        FutureBuilder(
            future: isLoggedFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  Future.microtask(() => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage())));
                } else {
                  Future.microtask(() => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen())));
                }
                return Container();
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ]),
    );
  }
}
