import 'package:arts/ui/registration.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../api/user_api.dart';
import '../exception/exceptions.dart';
import '../model/POI.dart';
import '../model/user.dart';
import 'homepage.dart';
import '../utils/user_utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: SafeArea(
              child: SingleChildScrollView(
        child: Column(children: [
          Container(
              margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyText1?.color),
                  children: <TextSpan>[
                    TextSpan(
                      text: AppLocalizations.of(context)!.welcomeLog,
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.appName,
                      style: const TextStyle(
                          fontFamily: "DaVinci",
                          fontSize: 35,
                          color: lightOrange),
                    ),
                    TextSpan(
                      text:
                          ", \n${AppLocalizations.of(context)!.welcomeLog1}\n",
                    )
                  ],
                ),
              )),
          const LoginForm(),
          Container(
            padding: const EdgeInsets.all(10),
            child: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: AppLocalizations.of(context)!.notHaveAnAcc,
                  style: const TextStyle(color: Colors.blue, fontSize: 20),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()));
                    })
            ])),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text("${AppLocalizations.of(context)!.or}\n",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          RichText(
              text: TextSpan(
                  text: AppLocalizations.of(context)!.logLater,
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
                    }))
        ]),
      ))),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPass = TextEditingController();
  bool? _showLoginError = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text("${AppLocalizations.of(context)!.email}: ",
                        style: const TextStyle(fontSize: 20))),
                TextFormField(
                  controller: _controllerEmail,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.emailExm,
                      hintStyle: const TextStyle(fontSize: 15)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.mandatoryField;
                    } else if (!UserUtils.validateEmail(value)) {
                      return AppLocalizations.of(context)!.invalidEmail;
                    } else {
                      return null;
                    }
                  },
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Text("${AppLocalizations.of(context)!.password}: ",
                        style: const TextStyle(fontSize: 20))),
                TextFormField(
                  controller: _controllerPass,
                  obscureText: isPasswordVisible ? false : true,
                  decoration: InputDecoration(
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 45, maxWidth: 46),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        child: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).textTheme.bodyText1?.color,
                          size: 22,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.password,
                      hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.headline1?.color,
                          fontSize: 15)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.mandatoryField;
                    } else {
                      return null;
                    }
                  },
                )
              ],
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return GestureDetector(
                onTap: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    String newToken = generateToken();
                    const storage = FlutterSecureStorage();
                    try {
                      User? user = await loginUser(
                          _controllerEmail.text, _controllerPass.text,
                          newToken);
                      if (user == null) {
                        //in this case user entered wrong credentials
                        setState(() {
                          _showLoginError = true;
                        });
                      } else {
                        await storage.write(
                            key: UserUtils.tokenKey, value: newToken);
                        await storage.write(
                            key: UserUtils.emailKey,
                            value: _controllerEmail.text);
                        Map<POI, String> visited = await getVisitedPOI(_controllerEmail.text, newToken);
                        userProvider.isLogged = true;
                        userProvider.name = user.name!;
                        userProvider.surname = user.surname!;
                        userProvider.visited = visited;
                        if (!mounted) return;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      }
                    } on ConnectionErrorException catch(e) {
                      debugPrint(e.cause);
                      setState(() {
                        _showLoginError = null;
                      });
                    }
                  }
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 4,
                            color: Colors.black12.withOpacity(.2),
                            offset: const Offset(2, 2))
                      ],
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                          colors: [lightOrange, darkOrange])),
                  child: Text(AppLocalizations.of(context)!.login,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
          setLoginOutput(_showLoginError),
        ],
      ),
    );
  }

  Widget setLoginOutput(bool? showLoginError) {
    if (showLoginError == null || showLoginError == true) {
      String text;
      if (showLoginError == null) {
        text = AppLocalizations.of(context)!.connectionError;
      } else {
        text = AppLocalizations.of(context)!.loginFailed;
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        color: Colors.red,
        child: Text(text,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
      );
    } else {
      return Container();
    }
  }
}
