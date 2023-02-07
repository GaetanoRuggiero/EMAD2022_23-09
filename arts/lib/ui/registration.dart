import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:arts/api/user_api.dart';
import 'package:arts/ui/login.dart';
import 'package:arts/ui/profile_partner.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../exception/exceptions.dart';
import '../main.dart';
import '../utils/debouncer.dart';
import '../utils/user_utils.dart';
import '../env/env.dart';
import 'homepage.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geocoding/geocoding.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false, isConfirmPasswordVisible = false, _isPartner= false;
  final TextEditingController
      _controllerName = TextEditingController(),
      _controllerSurname = TextEditingController(),
      _controllerEmail = TextEditingController(),
      _controllerPass = TextEditingController(),
      _controllerPassVal = TextEditingController(),
      _controllerAddress = TextEditingController();
  String errorPassword = "";
  String? _controllerCategory;
  bool? _showRegError = false;
  late List<DropdownMenuItem<String>> _dropdownItemsCategory;
  late final FlutterGooglePlacesSdk _places;
  List<AutocompletePrediction> _predictions = [];
  final _debouncer = Debouncer(milliseconds: 500);
  String _selectedAddress = "";
  bool _tapped = false;
  double latitude = 0, longitude = 0;

  int numberOfPhoto = 0;
  String imageNumber  = "assets/background/background_0.jpg";

  List<DropdownMenuItem<String>> dropdownItemsCategory(){
    List<DropdownMenuItem<String>> menuItems;
    menuItems = [
      DropdownMenuItem(
          value: bakery,
          child: Text(AppLocalizations.of(context)!.bakery)),
      DropdownMenuItem(
          value: iceCreamShop,
          child: Text(AppLocalizations.of(context)!.iceCreamShop)),
      DropdownMenuItem(
          value: restaurant,
          child: Text(AppLocalizations.of(context)!.restourant)),
      DropdownMenuItem(
          value: pizzeria,
          child: Text(AppLocalizations.of(context)!.pizzeria)),
      DropdownMenuItem(
          value: museum,
          child: Text(AppLocalizations.of(context)!.museum)),
      DropdownMenuItem(
          value: theater,
          child: Text(AppLocalizations.of(context)!.theater)),
      DropdownMenuItem(
          value: sandwich,
          child: Text(AppLocalizations.of(context)!.sandwichBar)),
      DropdownMenuItem(
          value: bar,
          child: Text(AppLocalizations.of(context)!.bar)),
    ];
    return menuItems;
  }

  Future<void> _searchAddress(String address) async {
    _debouncer.run(() async {
      if (address.length > 5 && address != _selectedAddress) {
        final predictions = await _places.findAutocompletePredictions(address);
        setState(() {
          _predictions = predictions.predictions;
          _selectedAddress = address;
        });
      } else if(address.length <= 5) {
        setState(() {
          _predictions = [];
          _tapped = false;
        });
      }
    });
  }

  Future<double> getLatitude(List<Location> locations) async {
    return locations.first.latitude;    
  }
  
  Future<double> getLongitude(List<Location> locations) async {
    return locations.first.longitude;
  }

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

    _places = FlutterGooglePlacesSdk(Env.apiKey, locale: const Locale('it','IT'));

    _controllerAddress.addListener(() async {
      await _searchAddress(_controllerAddress.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _dropdownItemsCategory = dropdownItemsCategory();
  }

  @override
  Widget build(BuildContext context) {
    Size mobileMeasures = MediaQuery.of(context).size;
    double mobilesWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Container(
          height: mobileMeasures.height,
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
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: 20,
                                bottom: mobilesWidth/3 > 125 ? mobilesWidth/3 : mobilesWidth/10
                            ),
                            child: Text(
                                textAlign: TextAlign.center,
                                AppLocalizations.of(context)!.welcomeReg,
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  color: Colors.white
                                )
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                            controller: _controllerName,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  borderSide: const BorderSide(color: Colors.grey)),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.7),
                                              prefixIcon: Icon(_isPartner ? Icons.store : Icons.person),
                                              labelText: _isPartner ? AppLocalizations.of(context)!.partnerName : AppLocalizations.of(context)!.name,
                                              floatingLabelStyle: const TextStyle(color: lightOrange),
                                              labelStyle: const TextStyle(color: Colors.white54),
                                              hintStyle: const TextStyle(color: Colors.white54),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return AppLocalizations.of(context)!.mandatoryField;
                                              }
                                              return null;
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _isPartner ? Container() : Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                            controller: _controllerSurname,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  borderSide: const BorderSide(color: Colors.grey)),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.7),
                                              prefixIcon: const Icon(Icons.person),
                                              labelText: AppLocalizations.of(context)!.surname,
                                              floatingLabelStyle: const TextStyle(color: lightOrange),
                                              labelStyle: const TextStyle(color: Colors.white54),
                                              hintStyle: const TextStyle(color: Colors.white54),
                                            ),
                                            style: const TextStyle(color: Colors.white),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return AppLocalizations.of(context)!.mandatoryField;
                                              }
                                              return null;
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                            controller: _controllerEmail,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  borderSide: const BorderSide(color: Colors.grey)),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.7),
                                              prefixIcon: const Icon(Icons.email),
                                              labelText: AppLocalizations.of(context)!.email,
                                              floatingLabelStyle: const TextStyle(color: lightOrange),
                                              labelStyle: const TextStyle(color: Colors.white54),
                                              hintStyle: const TextStyle(color: Colors.white54),
                                            ),
                                            style: const TextStyle(color: Colors.white),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return AppLocalizations.of(context)!
                                                    .mandatoryField;
                                              } else if (!UserUtils.validateEmail(value)) {
                                                return AppLocalizations.of(context)!.invalidEmail;
                                              } else {
                                                return null;
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                            controller: _controllerPass,
                                            obscureText: isPasswordVisible ? false : true,
                                            decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(25.0),
                                                    borderSide: const BorderSide(color: Colors.grey)),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.7),
                                              prefixIcon: const Icon(Icons.lock),
                                              suffixIcon: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isPasswordVisible = !isPasswordVisible;
                                                  });
                                                },
                                                child: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                              ),
                                              labelText: AppLocalizations.of(context)!.password,
                                              floatingLabelStyle: const TextStyle(color: lightOrange),
                                              labelStyle: const TextStyle(color: Colors.white54),
                                              hintStyle: const TextStyle(color: Colors.white54),
                                            ),
                                            style: const TextStyle(color: Colors.white),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return AppLocalizations.of(context)!.mandatoryField;
                                              } else if (!UserUtils.validatePass(value)) {
                                                return AppLocalizations.of(context)!.formatPass;
                                              } else {
                                                return null;
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _controllerPassVal,
                                          obscureText: isConfirmPasswordVisible ? false : true,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25.0),
                                                borderSide: const BorderSide(color: Colors.grey)),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(0.7),
                                            prefixIcon: const Icon(Icons.lock),
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isConfirmPasswordVisible =
                                                      !isConfirmPasswordVisible;
                                                });
                                              },
                                              child: Icon(isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                            ),
                                            labelText: AppLocalizations.of(context)!.passConf,
                                            floatingLabelStyle: const TextStyle(color: lightOrange),
                                            labelStyle: const TextStyle(color: Colors.white54),
                                            hintStyle: const TextStyle(color: Colors.white54),
                                          ),
                                          style: const TextStyle(color: Colors.white),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return AppLocalizations.of(context)!.mandatoryField;
                                            } else if (_controllerPass.text != value) {
                                              setState(() {
                                                errorPassword = AppLocalizations.of(context)!.noMatchingPass;
                                              });
                                              return errorPassword;
                                            } else {
                                              setState(() {
                                                errorPassword = "";
                                              });
                                            }
                                            return null;
                                          }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _isPartner ? Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ButtonTheme(
                                          alignedDropdown: true,
                                          child: DropdownButtonFormField(
                                            menuMaxHeight: 200,
                                            dropdownColor: Colors.black.withOpacity(0.7),
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  borderSide: const BorderSide(color: Colors.grey)),
                                              prefixIcon: _controllerCategory == bakery ? const Icon(Icons.bakery_dining)
                                                  : _controllerCategory == iceCreamShop ? const Icon(Icons.icecream)
                                                  : _controllerCategory == restaurant ? const Icon(Icons.restaurant)
                                                  : _controllerCategory == pizzeria ? const Icon(Icons.local_pizza)
                                                  : _controllerCategory == museum ? const Icon(Icons.museum)
                                                  : _controllerCategory == theater ? const Icon(Icons.theater_comedy)
                                                  : _controllerCategory == bar ? const Icon(Icons.local_bar)
                                                  : _controllerCategory == sandwich ? const Icon(Icons.lunch_dining)
                                                  : const Icon(Icons.food_bank),
                                              hintText: AppLocalizations.of(context)!.insertCategory,
                                              contentPadding: const EdgeInsets.only(right: 7),
                                              filled: true,
                                              fillColor: Colors.black.withOpacity(0.7),
                                              floatingLabelStyle: const TextStyle(color: lightOrange),
                                              labelStyle: const TextStyle(color: Colors.white54),
                                              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                            ),
                                            items: _dropdownItemsCategory,
                                            value: _controllerCategory,
                                            onChanged: (String? newValue) {
                                              int indexClicked = 0;
                                              for (int i = 0; i < _dropdownItemsCategory.length; i++) {
                                                if (_dropdownItemsCategory[i].value == newValue) {
                                                  indexClicked = i;
                                                  break;
                                                }
                                              }
                                              var temp = _dropdownItemsCategory.first;
                                              _dropdownItemsCategory[0] = _dropdownItemsCategory[indexClicked];
                                              _dropdownItemsCategory[indexClicked] = temp;
                                              setState(() {
                                                _controllerCategory = newValue;
                                              });
                                            },
                                            validator: (value) => value == null ? AppLocalizations.of(context)!.mandatoryField : null,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ) : Container(),
                                _isPartner ? Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: SearchField<AutocompletePrediction>(
                                          searchStyle: const TextStyle(color: Colors.white),
                                          maxSuggestionsInViewPort: 4,
                                          suggestionsDecoration: BoxDecoration(
                                            //borderRadius: BorderRadius.circular(30),
                                            color: Colors.black.withOpacity(0.9),
                                          ),
                                          searchInputDecoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25.0),
                                                borderSide: const BorderSide(color: Colors.grey)),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(0.7),
                                            prefixIcon: const Icon(Icons.home),
                                            floatingLabelStyle: const TextStyle(color: lightOrange),
                                            labelStyle: const TextStyle(color: Colors.white54),
                                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                          ),
                                          hint: AppLocalizations.of(context)!.insertAddress,
                                          onSuggestionTap: (prediction) async {
                                            setState(() {
                                              _predictions = [];
                                              _selectedAddress = prediction.item!.fullText;
                                              _controllerAddress.text = prediction.item!.fullText;
                                              _tapped = true;
                                            });
                                          },
                                          controller: _controllerAddress,
                                          suggestions: _predictions.map((prediction) => SearchFieldListItem<AutocompletePrediction>(
                                            prediction.fullText,
                                            item: prediction,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text(prediction.fullText, style: const TextStyle(color: Colors.white),)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ).toList(),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return AppLocalizations.of(context)!.mandatoryField;
                                            } else if (!_tapped) {
                                              FocusScope.of(context).unfocus();
                                              return AppLocalizations.of(context)!.addressNotTapped;
                                            } else {
                                            return null;
                                            }
                                          })
                                        ),
                                      ]
                                  ),
                                ) : Container(),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.store),
                                      Container(
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.only(bottom: 10, top: 10),
                                          child: Text("${AppLocalizations.of(context)!.partner}: ",
                                              style: const TextStyle(fontSize: 18, color: Colors.white)
                                          )
                                      ),
                                      Switch(
                                        value: _isPartner,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _isPartner = value;
                                            _controllerCategory = null;
                                            _selectedAddress = "";
                                            _controllerAddress.text = "";
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, child) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(100),
                                        onTap: () async {
                                          if (_formKey.currentState!.validate()) {
                                            String newToken = generateToken();
                                            _controllerCategory ??= "";
                                            if (_controllerAddress.text.isNotEmpty) {
                                              List<Location> locations =
                                                  await locationFromAddress(
                                                      _controllerAddress.text);
                                              latitude = await getLatitude(locations);
                                              longitude = await getLongitude(locations);
                                            }
                                            try {
                                              bool? reg = await signUpUser(
                                                  _controllerName.text,
                                                  _controllerSurname.text,
                                                  _controllerEmail.text,
                                                  _controllerPass.text,
                                                  newToken,
                                                  _isPartner,
                                                _controllerCategory!,
                                                  latitude,
                                                  longitude
                                              );
                                              if (reg) {
                                                UserUtils.writeEmail(_controllerEmail.text);
                                                UserUtils.writeToken(newToken);
                                                userProvider.isLogged = true;
                                                userProvider.name = _controllerName.text;
                                                userProvider.isPartner = _isPartner;
                                                if (userProvider.isPartner) {
                                                  userProvider.category = _controllerCategory!;
                                                  if (!mounted) return;
                                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                                      builder: (context) => const ProfilePartner()), (Route route) => false);
                                                  return;
                                                }
                                                userProvider.surname = _controllerSurname.text;
                                                if (!mounted) return;
                                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                                    builder: (context) => const HomePage()), (Route route) => false);
                                              } else {
                                                setState(() {
                                                  _showRegError = true;
                                                });
                                              }
                                            } on ConnectionErrorException catch(e) {
                                              debugPrint(e.cause);
                                              setState(() {
                                                _showRegError = null;
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: 50,
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
                                          child: Text(AppLocalizations.of(context)!.signUp,
                                              style: TextStyle(
                                                  color: Colors.white.withOpacity(.8),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                setRegistrationOutput(_showRegError),
                                Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: AppLocalizations.of(context)!.haveAnAcc,
                                        style: const TextStyle(
                                          fontFamily: "JosefinSans",
                                            color: Colors.white,
                                            fontSize: 20)),
                                    TextSpan(
                                        text: " ${AppLocalizations.of(context)!.clickH}\n",
                                        style:
                                            const TextStyle(color: Colors.lightBlueAccent, fontSize: 20, fontFamily: "JosefinSans"),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen()));
                                          })
                                  ])),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget setRegistrationOutput(bool? showRegError) {
    if (showRegError == null || showRegError == true) {
      String text;
      if (showRegError == null) {
        text = AppLocalizations.of(context)!.connectionError;
      } else {
        text = AppLocalizations.of(context)!.regFailed4Email;
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
