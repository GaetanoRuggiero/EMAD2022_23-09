import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:arts/utils/language_preferences.dart';

import '../utils/settings_model.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {

  String? _languagemode;

  getLanguagePreferences () async {

    String? languageMode = await LanguagePreferences().getLanguage();
    debugPrint("SharedRead${languageMode!}");

    if (languageMode == SettingsModel.italian)
    {
      setState(() {
        _languagemode = SettingsModel.italian;
      });
    }
    else {
      setState(() {
        _languagemode = SettingsModel.english;
      });
    }
  }

  @override
  void initState() {
    getLanguagePreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, SettingsModel settingsNotifier, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(AppLocalizations.of(context)!.selectLanguage),
              actions: <Widget>[
                IconButton(onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                    icon: const Icon(Icons.home_rounded)),
              ],
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
                          leading: Radio<String?>(
                              value: SettingsModel.italian,
                              groupValue: _languagemode,
                              onChanged: (String? value) {
                                debugPrint("Italianoo "+ value!);
                                settingsNotifier.languageMode = SettingsModel.italian;
                                _languagemode = value;
                              }
                          ),
                        ),

                        const SizedBox(height: 10),

                        ListTile(
                          title: const Text("Inglese"),
                          leading: Radio<String?>(
                              value: SettingsModel.english,
                              groupValue: _languagemode,
                              onChanged: (String? value) {
                                debugPrint("Inglesee "+ value!);
                                settingsNotifier.languageMode = SettingsModel.english;
                               _languagemode = value;
                              }
                          ),
                        ),
                      ],
                    );
                  }
              ),
            ),
          );
        }
    );
  }
}