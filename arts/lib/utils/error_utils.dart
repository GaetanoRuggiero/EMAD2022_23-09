import 'package:arts/ui/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showDisconnectedDialog(BuildContext context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.disconnected),
        content: Text(AppLocalizations.of(context)!.mustLoginAgain),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              },
              child: Text(AppLocalizations.of(context)!.login)
          )
        ],
      );
    },
  );
}
