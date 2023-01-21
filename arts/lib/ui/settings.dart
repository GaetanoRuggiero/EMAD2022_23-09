import 'package:arts/utils/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './languagescreen.dart';
import './login.dart';
import '../api/user_api.dart';
import '../main.dart';
import '../utils/user_utils.dart';
import '../utils/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = settingsModel.themeMode;
  late String _snackBarMessage;
  late Color _colorSnackbar;

  //snackBar of Success/Error logout
  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _colorSnackbar,
        content: Text(_snackBarMessage),
        action: SnackBarAction(
          label: 'X',
          onPressed: () {
            // Click to close
          },
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          )
        ]
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LanguageScreen()),
                          );
                        },
                        child: SettingsTile(
                          rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                          leftIcon: Icons.translate_outlined,
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
                                    return Consumer<SettingsModel>(
                                      builder: (context, settingsNotifier, child) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: Text(AppLocalizations.of(context)!.light),
                                              leading: Radio<ThemeMode>(
                                                value: ThemeMode.light,
                                                groupValue: _themeMode,
                                                onChanged: (ThemeMode? value) {
                                                  setState(() {
                                                    settingsNotifier.themeMode = ThemeMode.light;
                                                    _themeMode = value!;
                                                  });
                                                }
                                              )
                                            ),

                                            ListTile(
                                              title: Text(AppLocalizations.of(context)!.dark),
                                              leading: Radio<ThemeMode>(
                                                value: ThemeMode.dark,
                                                groupValue: _themeMode,
                                                onChanged: (ThemeMode? value) {
                                                  setState(() {
                                                    settingsNotifier.themeMode = ThemeMode.dark;
                                                    _themeMode = value!;
                                                  });
                                                }
                                              )
                                            ),

                                            ListTile(
                                              title: Text(AppLocalizations.of(context)!.system),
                                              leading: Radio<ThemeMode>(
                                                value: ThemeMode.system,
                                                groupValue: _themeMode,
                                                onChanged: (ThemeMode? value) {
                                                  setState(() {
                                                    settingsNotifier.themeMode = ThemeMode.system;
                                                    _themeMode = value!;
                                                  });
                                                }
                                              )
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                  }
                                ),
                              );
                            },
                          );
                        },
                        child: SettingsTile(
                          leftIcon: Icons.palette_outlined,
                          title: AppLocalizations.of(context)!.theme,
                          rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                        ),
                      )
                    ]
                  )
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
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

                      SettingsTile(
                        rightIcon: Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            return Switch(
                              value: userProvider.isDeveloperModeOn,
                              onChanged: (bool value) {
                                debugPrint("[App Settings] Developer mode: $value");
                                setState(() {
                                  userProvider.isDeveloperModeOn = value;
                                });
                              },
                            );
                          },
                        ),
                        leftIcon: Icons.code,
                        title: AppLocalizations.of(context)!.developerMode
                      ),

                      const SizedBox(height: 10),

                      Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                            return Container(
                              child: userProvider.isLogged
                                  ? InkWell(
                                onTap: () {
                                  showDialog<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                            title: Text(AppLocalizations.of(context)!.logout),
                                            actions: [
                                              TextButton(
                                                child: Text(AppLocalizations.of(context)!.yes),
                                                onPressed: () async {
                                                  String? token = await UserUtils.readToken();
                                                  String? email = await UserUtils.readEmail();
                                                  bool deleted = await deleteToken(email!, token!);
                                                  if (deleted) {
                                                    setState(() {
                                                      _snackBarMessage = AppLocalizations.of(context)!.logoutCompleted;
                                                      _colorSnackbar = Colors.green;
                                                    });
                                                    UserUtils.deleteEmailAndToken();
                                                    userProvider.logout();
                                                    if (!mounted) return;
                                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                                        builder: (context) => const LoginScreen()), (Route route) => false);
                                                  } else {
                                                    setState(() {
                                                      _snackBarMessage = AppLocalizations.of(context)!.logoutFailed;
                                                      _colorSnackbar = Colors.red;
                                                    });
                                                    if (!mounted) return;
                                                    Navigator.pop(context);
                                                  }
                                                  showSnackBar();
                                                },
                                              ),
                                              TextButton(onPressed: () {Navigator.of(context).pop();}, child: const Text("No"))
                                            ],
                                            content: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(AppLocalizations.of(context)!.askForLogout, textAlign: TextAlign.left,)
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
                                    leftIcon: Icons.logout_outlined,
                                    title: AppLocalizations.of(context)!.logout
                                ),
                              )
                                  : InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const LoginScreen()
                                        )
                                    );
                                  },
                                  child: SettingsTile(
                                      rightIcon: Icon(Icons.arrow_forward_ios, color: Theme.of(context).textTheme.headline1?.color),
                                      leftIcon: Icons.login_outlined,
                                      title: AppLocalizations.of(context)!.redirectLog
                                  )
                              )
                          );
                        }
                      ),

                    ]
                  )
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
                          leftIcon: Icons.info_outlined,
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