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

RefreshIndicator showConnectionError(String errorMessage, Future<void> Function() onRefresh) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
              Text(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                errorMessage
              ),
            ],
          ),
        ),
        SizedBox(height: 100, child: ListView()), //Pull to refresh needs at least a scrollable list to work
      ]
    ),
  );
}

Text textOrLoading(String plannedText) {
  return Text(
      plannedText,
      style: TextStyle(
        color: Colors.white.withOpacity(.8),
        fontSize: 18,
        fontFamily: "JosefinSans",
      )
  );
}

void showSnackBar(BuildContext context, Color backgroundColor, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        backgroundColor: backgroundColor,
        content: Text(message),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.close,
          onPressed: () {
            // Click to close
          },
        )
      )
  );
}