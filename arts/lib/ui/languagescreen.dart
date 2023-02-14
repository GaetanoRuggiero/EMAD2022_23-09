import 'package:arts/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/settings_model.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Locale _languageMode = settingsModel.languageMode;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settingsNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.selectLanguage),
            actions: [
              IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ]
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: StatefulBuilder(
              builder: (context, setState) {
                List<Widget> radioTiles = localeToNation.entries.map((element) {
                  return RadioListTile(
                    title: Text(getLanguage(element.value)),
                    value: element.key,
                    groupValue: _languageMode,
                    onChanged: (Locale? value) {
                      settingsNotifier.languageMode = element.key;
                      _languageMode = value!;
                    },
                    secondary: Text(getCountryEmoji(getNationByLanguage(element.key))),
                  );
                }).toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: radioTiles
                );
              }
            )
          )
        );
      }
    );
  }
}
