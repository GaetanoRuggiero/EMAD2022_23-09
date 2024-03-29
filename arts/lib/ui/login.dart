import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:arts/ui/profile_partner.dart';
import 'package:arts/ui/registration.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/widget_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  String imageNumber = "assets/background/background_0.jpg";

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
    double mobilesHeight = MediaQuery.of(context).size.height;
    double mobilesWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: mobilesHeight,
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

                  SizedBox(
                    height: mobilesHeight,
                    child: Column(
                        children: [

                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                top: mobilesWidth/10,
                                bottom: mobilesWidth/5
                            ),
                            child: Image.asset(
                                "assets/icon/icon_big.png",
                                width: mobilesWidth/3 > 125 ? mobilesWidth/2 : mobilesWidth/3 ),
                          ),

                          Expanded(
                            child: Container(

                              margin: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [

                                      const LoginForm(),

                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: RichText(
                                            text: TextSpan(
                                                style: const TextStyle(fontFamily: 'JosefinSans', fontSize: 18),
                                                children: [
                                                  TextSpan(
                                                      text: "${AppLocalizations.of(context)!.notHaveAnAcc} ",
                                                      style: const TextStyle(color: Colors.white)),
                                                  TextSpan(
                                                      text: AppLocalizations.of(context)!.notHaveAnAcc_2,
                                                      style: const TextStyle(color: Colors.lightBlueAccent),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () {
                                                          Navigator.pushReplacement(
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
                                                style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 18, fontFamily: "JosefinSans"),
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
                          ),
                        ]),
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
  Widget _loadingOrText = textOrLoading("");
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  final TextEditingController _controllerEmail = TextEditingController(),
      _controllerPass = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _loadingOrText = textOrLoading(AppLocalizations.of(context)!.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
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
                prefixIcon: const Icon(Icons.email_outlined),
                labelText: AppLocalizations.of(context)!.emailExm_2,
                floatingLabelStyle: const TextStyle(color: lightOrange),
                labelStyle: const TextStyle(color: Colors.white54),
                hintStyle: const TextStyle(color: Colors.white54),
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
                  borderSide: const BorderSide(color: Colors.grey)
                ),
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
                labelStyle: const TextStyle(color: Colors.white54),
                floatingLabelStyle: const TextStyle(color: lightOrange),
                hintStyle: const TextStyle(color: Colors.white54),
              ),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _loadingOrText = LoadingJumpingLine.circle(size: 40, backgroundColor: Colors.white);
                        });
                        String newToken = generateToken();
                        String email = _controllerEmail.text.toLowerCase();
                        try {
                          User? user = await loginUser(
                              email, _controllerPass.text,
                              newToken);
                          if (user == null) {
                            //in this case user entered wrong credentials

                            setState(() {
                              _loadingOrText = textOrLoading(AppLocalizations.of(context)!.login);
                            });

                            _controllerEmail.text = "";
                            _controllerPass.text = "";

                            if (!mounted) return;
                            showSnackBar(context, Colors.red, AppLocalizations.of(context)!.loginFailed);
                          } else {
                            UserUtils.writeEmail(email);
                            UserUtils.writeToken(newToken);
                            userProvider.isLogged = true;
                            userProvider.isPartner = user.partner!;
                            userProvider.name = user.name!;
                            userProvider.registrationDate = user.registrationDate!;
                            if (!userProvider.isPartner) {
                              Map<POI, String> visited = await getVisitedPOI(
                                  email, newToken);
                              userProvider.surname = user.surname!;
                              userProvider.visited = visited;
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            } else {
                              userProvider.ongoingRewards = await countReward(email);
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
                            _loadingOrText = textOrLoading(AppLocalizations.of(context)!.login);
                          });

                          _controllerEmail.text = "";
                          _controllerPass.text = "";

                          showSnackBar(context, Colors.red, AppLocalizations.of(context)!.connectionError);
                        }
                      }
                    },
                    child: Center(
                      child: Container(
                        height: 40,
                        width: double.infinity,
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
                            _loadingOrText
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}