import 'package:arts/main.dart';
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
  String close = AppLocalizations.of(context)!.close.toUpperCase();
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        backgroundColor: backgroundColor,
        content: Text(message, style: const TextStyle(color: Colors.white),),
        action: SnackBarAction(
          label: close,
          textColor: Colors.white,
          onPressed: () {
            // Click to close
          },
        )
      )
  );
}

class NoGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

String getCountryEmoji(String country) {
  String emoji = '❔';
  switch (country.toLowerCase()) {
    case italia : return '🇮🇹';
    case francia : return '🇫🇷';
    case germania: return '🇩🇪';
    case regnoUnito : return '🇬🇧';
    case spagna : return '🇪🇸';
    default: return emoji;
  }
}

String getLanguage(String country) {
  String language = '';
  switch (country.toLowerCase()) {
    case italia : return 'Italiano';
    case francia : return 'Français';
    case germania: return 'Deutsch';
    case regnoUnito : return 'English';
    case spagna : return 'Español';
    default: return language;
  }
}

String getNationByLanguage(Locale language) {
  String nation = localeToNation.entries.firstWhere((element) => element.key == language).value;
  return nation;
}
