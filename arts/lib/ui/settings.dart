import 'package:arts/ui/login.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/theme_preferences.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../utils/settings_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'languagescreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:arts/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  ThemeMode? _filter = ThemeMode.light;

  getThemePreferences () async {
    int? themeMode = await ThemePreferences().getTheme();

    if (themeMode != null && themeMode == SettingsModel.dark) {
      _filter = ThemeMode.dark;
    }
    else if (themeMode != null && themeMode == SettingsModel.light){
      _filter = ThemeMode.light;
    }
    else {
      _filter = ThemeMode.system;
    }
  }

  @override
  void initState() {
    getThemePreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, SettingsModel settingsNotifier, child) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(AppLocalizations.of(context)!.settings),
              actions: <Widget>[
                IconButton(onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                    icon: const Icon(Icons.home_rounded)),
              ],
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(AppLocalizations.of(context)!.languageAndTheme,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LanguageScreen()),
                                );
                              },
                              child: SettingsTile(
                                  rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                                  leftIcon: Ionicons.language,
                                  title: AppLocalizations.of(context)!.language),
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              onTap: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      title: Text(AppLocalizations.of(context)!.chooseTheTheme),
                                      content: StatefulBuilder(
                                          builder: (context, setState) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [

                                                ListTile(
                                                  title: Text(AppLocalizations.of(context)!.light),
                                                  leading: Radio<ThemeMode>(
                                                      value: ThemeMode.light,
                                                      groupValue: _filter,
                                                      onChanged: (ThemeMode? value) {
                                                        setState(() {
                                                          settingsNotifier.themeMode = SettingsModel.light;
                                                          _filter = value;
                                                        });
                                                      }
                                                  ),
                                                ),

                                                ListTile(
                                                  title: Text(AppLocalizations.of(context)!.dark),
                                                  leading: Radio<ThemeMode>(
                                                      value: ThemeMode.dark,
                                                      groupValue: _filter,
                                                      onChanged: (ThemeMode? value) {
                                                        setState(() {
                                                          settingsNotifier.themeMode = SettingsModel.dark;
                                                          _filter = value;
                                                        });
                                                      }
                                                  ),
                                                ),

                                                ListTile(
                                                  title: Text(AppLocalizations.of(context)!.system),
                                                  leading: Radio<ThemeMode>(
                                                      value: ThemeMode.system,
                                                      groupValue: _filter,
                                                      onChanged: (ThemeMode? value) {
                                                        setState(() {
                                                          settingsNotifier.themeMode = SettingsModel.system;
                                                          _filter = value;
                                                        });
                                                      }
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                      ),
                                    );
                                  },
                                );

                              },
                              child: SettingsTile(
                                leftIcon: Ionicons.color_palette_outline,
                                title: AppLocalizations.of(context)!.theme,
                                rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        //color: Theme.of(context)!.shadowColor,
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(AppLocalizations.of(context)!.account,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              onTap: () {},
                              child: SettingsTile(
                                  rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                                  leftIcon: Icons.account_circle,
                                  title: AppLocalizations.of(context)!.infoAccount
                              ),
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              onTap: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          title: Text(AppLocalizations.of(context)!.logout),
                                          actions: [
                                            TextButton(
                                              child: Text(AppLocalizations.of(context)!.ok),
                                              onPressed: () async {
                                                const storage = FlutterSecureStorage();
                                                await storage.delete(key: tokenKey);
                                                if (!mounted) return;
                                                debugPrint("Logout");
                                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                                    builder: (context) => const LoginScreen()), (Route route) => false);
                                              },
                                            ),
                                          ],
                                          content: StatefulBuilder(
                                              builder: (context, setState) {
                                                return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(AppLocalizations.of(context)!.logoutCompleted, textAlign: TextAlign.center,)
                                                    ]
                                                );
                                              }
                                          )
                                      );
                                    }
                                );
                              },
                              child: SettingsTile(
                                  rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                                  leftIcon: Ionicons.log_out_outline,
                                  title: AppLocalizations.of(context)!.logout
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(AppLocalizations.of(context)!.info,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              onTap: () {},
                              child: SettingsTile(
                                  rightIcon:  Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                                  leftIcon: Ionicons.information_circle_sharp,
                                  title: AppLocalizations.of(context)!.infoAndRecognitions
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}

class SettingsTile extends StatelessWidget {

  final IconData leftIcon;
  final String title;
  final Widget rightIcon;

  const SettingsTile({
    Key? key,
    required this.leftIcon,
    required this.title,
    required this.rightIcon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.transparent,
          ),
          child: Icon(leftIcon),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),

        const Spacer(),

        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: rightIcon,
        ),
      ],
    );
  }
}