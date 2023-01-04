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
            centerTitle: true,
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("Italiano"),
                      leading: Radio<Locale>(
                        value: SettingsModel.italian,
                        groupValue: _languageMode,
                        onChanged: (Locale? value) {
                          settingsNotifier.languageMode = SettingsModel.italian;
                          _languageMode = value!;
                        }
                      )
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      title: const Text("English"),
                      leading: Radio<Locale>(
                        value: SettingsModel.english,
                        groupValue: _languageMode,
                        onChanged: (Locale? value) {
                          settingsNotifier.languageMode = SettingsModel.english;
                          _languageMode = value!;
                        }
                      )
                    )
                  ]
                );
              }
            )
          )
        );
      }
    );
  }
}