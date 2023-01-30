import 'dart:math';
import 'package:arts/ui/profile_partner.dart';
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
import '../utils/user_utils.dart';
import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String imageNumber = "assets/background/background_${Random().nextInt(5)}.jpg";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height),
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInQuint,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(imageNumber),
                        opacity: 0.2,
                        fit: BoxFit.fill
                    ),
                  ),
                  child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 20, top: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.welcomeLog, style: const TextStyle(fontSize: 30, fontFamily: "JosefinSans")),
                              const SizedBox(height: 20),
                              Image.asset("assets/icon/icon_16-9.png", width: 260),
                            ],
                          ),
                        ),

                        const LoginForm(),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: AppLocalizations.of(context)!.notHaveAnAcc,
                                      style: const TextStyle(color: Colors.blue, fontSize: 18, fontFamily: "JosefinSans"),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const RegisterPage()));
                                        })
                                ])),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Text(AppLocalizations.of(context)!.or,
                                textAlign: TextAlign.center,
                                style:
                                const TextStyle(fontSize: 18, fontFamily: "JosefinSans")),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(top: 10, bottom: 15),
                            child: RichText(
                                text: TextSpan(
                                    text: AppLocalizations.of(context)!.logLater,
                                    style: const TextStyle(fontSize: 18, color: Colors.blue, fontFamily: "JosefinSans"),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const HomePage()));
                                      })),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
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
  final TextEditingController _controllerEmail = TextEditingController(),
      _controllerPass = TextEditingController();
  bool? _showLoginError = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(10))
              ),
              child: TextFormField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color, size: 20),
                    hintText: AppLocalizations.of(context)!.emailExm_2,
                    hintStyle: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontFamily: "JosefinSans")),
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
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.all(Radius.circular(10))
              ),
              child: TextFormField(
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        size: 22,
                      ),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color, size: 20),
                    hintText: AppLocalizations.of(context)!.password,
                    hintStyle: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, fontFamily: "JosefinSans")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.mandatoryField;
                  } else {
                    return null;
                  }
                },
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
                          Map<POI, String> visited = await getVisitedPOI(
                              _controllerEmail.text, newToken);
                          userProvider.isLogged = true;
                          userProvider.isPartner = user.partner!;
                          userProvider.name = user.name!;
                          if (!userProvider.isPartner) {
                            userProvider.surname = user.surname!;
                            userProvider.visited = visited;
                            if (!mounted) return;
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          } else {
                            if (!mounted) return;
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfilePartner()));
                          }
                        }
                      } on ConnectionErrorException catch(e) {
                        debugPrint(e.cause);
                        setState(() {
                          _showLoginError = null;
                        });
                      }
                    }
                  },
                  child: Center(
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.login,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                  fontSize: 20,
                                  fontFamily: "JosefinSans",
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward_sharp, color: Colors.white30.withOpacity(0.8))
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            setLoginOutput(_showLoginError),
          ],
        ),
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