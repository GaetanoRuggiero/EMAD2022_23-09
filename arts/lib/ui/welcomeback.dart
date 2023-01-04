import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './homepage.dart';

class WelcomeBackScreen extends StatelessWidget {
  const WelcomeBackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      });
    });
    return Scaffold(
      body: SafeArea(
        child: Center(
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
        ),
      ),
    );
  }
}