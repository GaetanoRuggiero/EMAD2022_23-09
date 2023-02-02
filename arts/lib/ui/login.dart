import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:arts/ui/profile_partner.dart';
import 'package:arts/ui/registration.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animations/loading_animations.dart';
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

  int numberOfPhoto = 1;
  String imageNumber = "assets/background/background_${Random().nextInt(1)}.jpg";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final Iterable<String> images = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/background'));
      setState(() {
        numberOfPhoto = images.length;
        imageNumber = "assets/background/background_${Random().nextInt(numberOfPhoto)}.jpg";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(imageNumber),
              fit: BoxFit.cover
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 4,
              sigmaY: 4
          ),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Opacity(
                    opacity: 0.4,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                          gradient: RadialGradient(
                              radius: 4,
                              center: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                darkBlue
                              ]
                          )
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                          children: [

                            Container(
                              margin: const EdgeInsets.only(bottom: 20, top: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  Image.asset("assets/icon/icon_big.png", width: 150),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Container(

                                margin: const EdgeInsets.all(10),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                                  child: Column(
                                    children: [

                                      const LoginForm(),

                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: RichText(
                                            text: TextSpan(
                                                style: const TextStyle(fontFamily: 'JosefinSans', fontWeight: FontWeight.bold, fontSize: 18),
                                                children: [
                                                  TextSpan(
                                                      text: "${AppLocalizations.of(context)!.notHaveAnAcc} ",
                                                      style: const TextStyle(color: Colors.white)),
                                                  TextSpan(
                                                      text: AppLocalizations.of(context)!.notHaveAnAcc_2,
                                                      style: const TextStyle(color: Colors.lightBlueAccent),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => const RegisterPage()));
                                                        })
                                                ])),
                                      ),

                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(AppLocalizations.of(context)!.or,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontFamily: "JosefinSans", color: Colors.white)),
                                        ),
                                      ),

                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: RichText(
                                            text: TextSpan(
                                                text: AppLocalizations.of(context)!.logLater,
                                                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "JosefinSans"),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => const HomePage()));
                                                  })),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              )),
        ),
      ),
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
  Widget loadingOrText = const Text("");
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  final TextEditingController _controllerEmail = TextEditingController(),
      _controllerPass = TextEditingController();
  bool? _showLoginError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      loadingOrText = (Text(AppLocalizations.of(context)!.login,
          style: TextStyle(
            color: Colors.white.withOpacity(.8),
            fontSize: 18,
            fontFamily: "JosefinSans",
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextFormField(
              controller: _controllerEmail,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.grey)),
                fillColor: Colors.black.withOpacity(0.8),
                filled: true,
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                labelText: AppLocalizations.of(context)!.emailExm_2,
                labelStyle: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
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

            const SizedBox(height: 10),

            TextFormField(
              controller: _controllerPass,
              obscureText: isPasswordVisible ? false : true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.grey)),
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
                      size: 22,
                    ),
                  ),
                  fillColor: Colors.black.withOpacity(0.8),
                  filled: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  labelText: AppLocalizations.of(context)!.password,
                  labelStyle: const TextStyle(fontSize: 15, color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.mandatoryField;
                } else {
                  return null;
                }
              },
            ),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return GestureDetector(
                  onTap: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loadingOrText = LoadingJumpingLine.circle(size: 40, backgroundColor: Colors.white);
                      });
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
                          userProvider.isLogged = true;
                          userProvider.isPartner = user.partner!;
                          userProvider.name = user.name!;
                          if (!userProvider.isPartner) {
                            Map<POI, String> visited = await getVisitedPOI(
                                _controllerEmail.text, newToken);
                            userProvider.surname = user.surname!;
                            userProvider.visited = visited;
                            if (!mounted) return;
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          } else {
                            userProvider.ongoingRewards = await countReward(_controllerEmail.text);
                            userProvider.rewardsAdded = user.rewardsAdded!;
                            userProvider.category = user.category!;
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
                      height: 40,
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
                          loadingOrText
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