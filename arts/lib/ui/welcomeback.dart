import 'dart:async';
import 'package:arts/ui/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {

  @override
  Widget build(BuildContext context) {
    final Future<String> greetings = Future<String>.delayed(
      const Duration(seconds: 3),
          () => AppLocalizations.of(context)!.loggedSuccessfully,
    );
    return Scaffold(
      body: Column(
        mainAxisAlignment:  MainAxisAlignment.center,
        children: [
          FutureBuilder<String>(
            future: greetings,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = [
                  Text(AppLocalizations.of(context)!.welcomeLog2, style: TextStyle(fontSize: 30, color: Theme.of(context).textTheme.bodyText1?.color)),
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('${snapshot.data}'),
                  ),
                ];
                Future.microtask(() => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePage())));
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('${AppLocalizations.of(context)!.errorGeneric}: ${snapshot.error}'),
                  ),
                ];
              } else {
                children = <Widget>[
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(AppLocalizations.of(context)!.loading),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          )
      ]),
    );
  }
}
