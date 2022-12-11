import 'package:arts/ui/homepage.dart';
import 'package:arts/ui/registration.dart';
import 'package:arts/ui/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                  margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyText1?.color),
                      children: <TextSpan>[
                        TextSpan(
                          text: AppLocalizations.of(context)!.welcomeLog,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.appName,
                          style: const TextStyle(fontFamily: "DaVinci", fontSize: 25),
                        ),
                        TextSpan(
                          text: ", \n${AppLocalizations.of(context)!.welcomeLog1}\n",
                        ),
                        TextSpan(
                            text: AppLocalizations.of(context)!.welcomeLog2,
                            style: const TextStyle(fontSize: 30))
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
                          Navigator.pushReplacement(
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              RichText(
                  text: TextSpan(
                      text: AppLocalizations.of(context)!.logLater,
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        }))
            ]),
          )),
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
                    child:
                         Text("${AppLocalizations.of(context)!.email}: ", style: const TextStyle(fontSize: 20))),
                TextFormField(
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: AppLocalizations.of(context)!.emailExm,
                        hintStyle: const TextStyle(fontSize: 15)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.mandatoryField;
                      }
                      return null;
                    }),
                Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Text("${AppLocalizations.of(context)!.password}: ",
                        style: const TextStyle(fontSize: 20))),
                TextFormField(
                  obscureText: isPasswordVisible ? false : true,
                  decoration: InputDecoration(
                      suffixIconConstraints: const BoxConstraints(
                          minWidth: 45, maxWidth: 46),
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
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              ?.color,
                          size: 22,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!.password,
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.color,
                          fontSize: 15)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.mandatoryField;
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
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
          ),
        ],
      ),
    );
  }
}
