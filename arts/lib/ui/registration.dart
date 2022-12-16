import 'package:arts/ui/login.dart';
import 'package:arts/ui/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPasswordVisible = false,
      isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(
                        textAlign: TextAlign.center,
                        AppLocalizations.of(context)!.welcomeReg,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyText1?.color))),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: const Icon(
                        Icons.person,
                        color: darkOrange,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: TextFormField(
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline1?.color,
                                fontSize: 15),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: AppLocalizations.of(context)!.name,
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.color,
                                  fontSize: 15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.mandatoryField;
                              }
                              return null;
                            }),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: TextFormField(
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline1?.color,
                                fontSize: 15),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: AppLocalizations.of(context)!.surname,
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline1
                                      ?.color,
                                  fontSize: 15),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.mandatoryField;
                              }
                              return null;
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                    child: const Icon(
                      Icons.email,
                      color: darkOrange,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                      child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).textTheme.headline1?.color,
                              fontSize: 15),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context)!.email,
                            hintStyle: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline1?.color,
                                fontSize: 15),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.mandatoryField;
                            }
                            return null;
                          }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                    child: const Icon(
                      Icons.lock,
                      color: darkOrange,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                        child: TextFormField(
                            style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.headline1?.color,
                                fontSize: 15),
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
                            })),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 5, 10),
                    child: const Icon(
                      Icons.lock,
                      color: darkOrange,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 20, 10),
                      child: TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).textTheme.headline1?.color,
                              fontSize: 15),
                          obscureText: isConfirmPasswordVisible ? false : true,
                          decoration: InputDecoration(
                              suffixIconConstraints: const BoxConstraints(
                                  minWidth: 45, maxWidth: 46),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isConfirmPasswordVisible =
                                        !isConfirmPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  isConfirmPasswordVisible
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
                              hintText: AppLocalizations.of(context)!.passConf,
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
                          }),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
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
                  child: Text(AppLocalizations.of(context)!.signUp,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: AppLocalizations.of(context)!.haveAnAcc,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1?.color,
                          fontSize: 20)),
                  TextSpan(
                      text: " ${AppLocalizations.of(context)!.clickH}\n",
                      style: const TextStyle(color: Colors.blue, fontSize: 20),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        })
                ])),
              )
            ],
          ),
        ),
      ),
    );
  }
}