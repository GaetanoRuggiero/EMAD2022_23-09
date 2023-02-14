import 'package:arts/api/user_api.dart';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/model/reward.dart';
import 'package:arts/ui/settings.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/widget_utils.dart';
import 'editprofilescreen.dart';
import 'package:palette_generator/palette_generator.dart';

class ProfilePartner extends StatelessWidget {
  const ProfilePartner({Key? key}) : super(key: key);
  static const Map<String, String> imagesByCategory = {
    bakery:"", iceCreamShop:"", restaurant:"", pizzeria:"",
    museum:"", theater:"", sandwich:"", bar:""
  };

  static Route<void> _fullscreenDialogRoute(BuildContext context) {
    return MaterialPageRoute<void>(
      builder: (context) => const _FullScreenDialogAddReward(),
      fullscreenDialog: true,
    );
  }

  // Calculate dominant color from ImageProvider
  Future<Color> getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    Color? color = paletteGenerator.dominantColor?.color;
    color ??= Colors.white;
    return color;
  }

  String getImageByCategory (String category) {
    String pathImage= "defaultImage";
    //imagesByCategory.entries.firstWhere((element) => element.key == category, orElse: "defaultImage");
    return pathImage;
  }

  @override
  Widget build(BuildContext context) {
    double mobilesWidth = MediaQuery.of(context).size.width;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return FutureBuilder(
          future: getImagePalette(const AssetImage("assets/partner_images/ice_cream_shop.png")),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                        center: Alignment.center,
                        focalRadius: 10,
                        radius: 10,
                        colors: [snapshot.data!, Colors.black87]),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                        child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: mobilesWidth/3 > 125 ? 20 : 10),
                                alignment: Alignment.center,
                                child: Text(userProvider.name,
                                    style: TextStyle(fontSize: mobilesWidth/3 > 125 ? 30 : 20, color: Colors.white)),
                              ),
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  SizedBox(
                                    width: mobilesWidth,
                                    height: 300,
                                  ),
                                  SizedBox(
                                      width: mobilesWidth,
                                      height: 300,
                                      child: Image.asset("assets/partner_images/ice_cream_shop.png",
                                        fit: BoxFit.fitHeight,
                                      ),
                                  ),
                                  Positioned(
                                    top: 70,
                                    right: 8,
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [BoxShadow(
                                              offset: Offset(0, 0.75),
                                              spreadRadius: 0,
                                              blurRadius: 1,
                                            )],
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Tooltip(
                                            message: AppLocalizations.of(context)!
                                                .modifyPassword,
                                            child: IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const EditProfileScreen()),
                                                  );
                                                },
                                                icon:
                                                const Icon(size: 30, Icons.edit)),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            boxShadow: [BoxShadow(
                                              offset: Offset(0, 0.75),
                                              spreadRadius: 0,
                                              blurRadius: 1,
                                            )],
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Tooltip(
                                            message: AppLocalizations.of(context)!
                                                .settings,
                                            child: IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const SettingsScreen()),
                                                );
                                              },
                                              icon: const Icon(
                                                  size: 30, Icons.settings)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              userProvider.rewardsAdded > 0 ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                          "${AppLocalizations.of(context)!.congratsPartner} ${userProvider.rewardsAdded} ${userProvider.rewardsAdded == 1 ? AppLocalizations.of(context)!.reward : AppLocalizations.of(context)!.rewards.toLowerCase()}",
                                          style: TextStyle(fontSize: mobilesWidth/3 > 125 ? 25 : 15, color: Colors.white), textAlign: TextAlign.center,)),
                                  ],
                                ),
                              ) : Container(),

                              SizedBox(height: mobilesWidth/3 > 125 ? 20 : 10,),

                              DecoratedBox(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black12.withOpacity(.2),
                                          offset: const Offset(2, 2))
                                    ],
                                    gradient: const LinearGradient(
                                        colors: [lightOrange, darkOrange])
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                      shadowColor: Colors.transparent,
                                      textStyle: const TextStyle(fontSize: 25, color: Colors.white, fontFamily: "JosefinSans"),
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                      minimumSize: const Size(310, 50)
                                  ),
                                  onPressed: userProvider.ongoingRewards <= 3 ? () {
                                    Navigator.push(
                                        context, _fullscreenDialogRoute(context));
                                  }: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .rewardsLimitReached),
                                          content: Expanded(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .rewardsLimitReachedText)),
                                          actions: [
                                            TextButton(
                                                child: const Text("OK"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                })
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.note_add,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  label: Text(AppLocalizations.of(context)!.addReward, style: const TextStyle(color: Colors.white),),
                                ),
                              ),

                              const SizedBox(height: 20),

                              DecoratedBox(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black12.withOpacity(.2),
                                          offset: const Offset(2, 2))
                                    ],
                                    gradient: const LinearGradient(
                                        colors: [lightOrange, darkOrange])
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                                      shadowColor: Colors.transparent,
                                      textStyle: const TextStyle(fontSize: 25, color: Colors.white, fontFamily: "JosefinSans"),
                                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                      minimumSize: const Size(310, 50)
                                  ),
                                  onPressed:  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const CameraQRScreen()),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.qr_code_2_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  label: Text(AppLocalizations.of(context)!.scanQR, style: const TextStyle(color: Colors.white)),
                                ),
                              ),
                            ]
                        )

                    ),
                  )
              );
            }
            return Container();
          },
        );
      },

    );
  }
}

class _FullScreenDialogAddReward extends StatefulWidget {
  const _FullScreenDialogAddReward({Key? key}) : super(key: key);

  @override
  State<_FullScreenDialogAddReward> createState() => _FullScreenDialogAddRewardState();
}

class _FullScreenDialogAddRewardState extends State<_FullScreenDialogAddReward> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerPlaceEvents = TextEditingController(),
  _controllerDiscountAmount = TextEditingController(),
  _controllerExpiryDate = TextEditingController(),
      _controllerType = TextEditingController();
  final String coupon = "Coupon", ticket = "Ticket";
  late String _snackBarMessage;
  late Color _colorSnackbar;
  bool _showConnectionError = false;

  TextEditingController getControllerType(String category) {
    List<String> foodCategories = [
      bakery,
      iceCreamShop,
      restaurant,
      pizzeria,
      sandwich,
      bar
    ];
    List<String> artsCategories = [
      museum,
      theater
    ];
    if (artsCategories.contains(category)) {
      _controllerType.text = ticket;
    } else if (foodCategories.contains(category)) {
      _controllerType.text = coupon;
    }
    return _controllerType;
  }

  String getControllerCategory(BuildContext context, String category) {
    return category == bakery ? AppLocalizations.of(context)!.bakery
        : category == iceCreamShop ? AppLocalizations.of(context)!.iceCreamShop
        : category == restaurant ? AppLocalizations.of(context)!.restourant
        : category == pizzeria ? AppLocalizations.of(context)!.pizzeria
        : category == museum ? AppLocalizations.of(context)!.museum
        : category == theater ? AppLocalizations.of(context)!.theater
        : category == bar ? AppLocalizations.of(context)!.bar
        :  AppLocalizations.of(context)!.sandwichBar;
  }

  Icon getIcon(String category) {
    return  category == bakery ? const Icon(Icons.bakery_dining, color: darkOrange, size: 22)
        : category == iceCreamShop ? const Icon(Icons.icecream, color: darkOrange, size: 22)
        : category == restaurant ? const Icon(Icons.restaurant, color: darkOrange, size: 22)
        : category == pizzeria ? const Icon(Icons.local_pizza, color: darkOrange, size: 22)
        : category == museum ? const Icon(Icons.museum, color: darkOrange, size: 22)
        : category == theater ? const Icon(Icons.theater_comedy, color: darkOrange, size: 22)
        : category == bar ? const Icon(Icons.local_bar, color: darkOrange, size: 22)
        : category == sandwich ? const Icon(Icons.lunch_dining, color: darkOrange, size: 22)
        : const Icon(Icons.food_bank);
  }

  Future<void> refreshTab() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const _FullScreenDialogAddReward()));
  }

  @override
  Widget build(BuildContext context) {
    double mobilesHeight = MediaQuery.of(context).size.height;
    double mobilesWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: mobilesWidth/3 > 125 ? mobilesWidth/6 : mobilesWidth/9),
                      child: Text(AppLocalizations.of(context)!.addReward, style: TextStyle(fontSize: mobilesWidth/3 > 135 ? 35 : mobilesWidth/3 > 95 ? 30 : 25, fontWeight: FontWeight.bold),),
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: mobilesHeight/40),
                        padding: EdgeInsets.only(top: mobilesWidth/3 > 125 ? mobilesWidth/10 : mobilesWidth/9),
                        child: Column(
                          children: [
                            Container(
                              margin : const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.store),
                                          labelText: AppLocalizations.of(context)!.placeEvent,
                                        ),
                                        initialValue: userProvider.name,
                                        //style: const TextStyle(color: Colors.blueGrey),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return AppLocalizations.of(context)!.mandatoryField;
                                          } else {
                                            _controllerPlaceEvents.text = value;
                                            return null;
                                          }
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                     flex: 3,
                                    child: TextFormField(
                                        controller: _controllerExpiryDate,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.calendar_today),
                                          labelText: AppLocalizations.of(context)!.expiryDate,
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          int futureYear = DateTime.now().year + 47;
                                          DateTime? pickedDate = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(), //get today's date
                                              firstDate:DateTime.now(),
                                              lastDate: DateTime(futureYear)
                                          );
                                          if (pickedDate != null ) {
                                            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                            setState(() {
                                              _controllerExpiryDate.text = formattedDate; //set foratted date to TextField value.
                                            });
                                          } else {
                                            debugPrint("Date is not selected");
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)!.mandatoryField;
                                          } else {
                                            return null;
                                          }
                                        }
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        controller: _controllerDiscountAmount,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(Icons.percent),
                                            labelText: AppLocalizations.of(context)!.discountAmount,
                                            hintText: AppLocalizations.of(context)!.valueDiscountAmount
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)!.mandatoryField;
                                          } else {
                                            int valueParsed = int.parse(value);
                                            if (valueParsed > 0 && valueParsed<= 100) {
                                              return null;
                                            } else {
                                              return AppLocalizations.of(context)!.properValue;
                                            }
                                          }
                                        }
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: mobilesWidth/6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        prefixIcon: getIcon(userProvider.category),
                                        labelText: AppLocalizations.of(context)!.category,
                                      ),
                                      initialValue: getControllerCategory(context, userProvider.category),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: TextFormField(
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        prefixIcon: _controllerType.text == "ticket" ? const Icon(Icons.local_activity)
                                                    : const Icon(Icons.sell),
                                        labelText: AppLocalizations.of(context)!.type,
                                      ),
                                      initialValue: getControllerType(userProvider.category).text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  String? email = await UserUtils.readEmail();
                                  String? token = await UserUtils.readToken();
                                  if (email == null && token == null){
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      showDisconnectedDialog(context);
                                    });
                                  } else {
                                    try {
                                      int? discountAmount = int.parse(_controllerDiscountAmount.text);
                                      String? expiryDate = DateTime.parse(_controllerExpiryDate.text).toIso8601String();
                                      Reward reward = Reward(
                                          category: userProvider.category, discountAmount: discountAmount, expiryDate: expiryDate,
                                          placeEvent: _controllerPlaceEvents.text, type: _controllerType.text, email: email
                                      );
                                      bool addedSidequest = await addSidequest(reward, email!, token!);
                                      if (addedSidequest) {
                                        userProvider.incrementRewardCount();
                                        setState(() {
                                          _snackBarMessage = AppLocalizations.of(context)!.addedSidequestSucc;
                                          _colorSnackbar = Colors.green;
                                        });
                                        if (!mounted) return;
                                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                                            builder: (context) => const ProfilePartner()), (Route route) => false);
                                      } else {
                                        setState(() {
                                          _snackBarMessage = AppLocalizations.of(context)!.addedSidequestFailed;
                                          _colorSnackbar = Colors.red;
                                        });
                                        setState(() {
                                          _showConnectionError = false;
                                        });
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                      }
                                      if (!mounted) return;
                                      showSnackBar(context,_colorSnackbar,_snackBarMessage                                    );
                                    } on ConnectionErrorException catch(e) {
                                      debugPrint(e.cause);
                                      setState(() {
                                        _showConnectionError = true;
                                      });
                                    }
                                  }
                                }
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: mobilesWidth/8),
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
                                        colors: [lightOrange, darkOrange])
                                ),
                                child: Text(AppLocalizations.of(context)!.addReward,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.8),
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            _showConnectionError ? showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab()) : Container()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
      )
    );
  }
}

class CameraQRScreen extends StatefulWidget {
  const CameraQRScreen({Key? key}) : super(key: key);

  @override
  State<CameraQRScreen> createState() => _CameraQRScreenState();
}

class _CameraQRScreenState extends State<CameraQRScreen> {


  @override
  Widget build(BuildContext context) {
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.frameQR),
          actions: [
            IconButton(
              color: Theme.of(context).iconTheme.color,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return Icon(Icons.flash_off, color: Theme.of(context).iconTheme.color);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return Icon(Icons.camera_front, color:Theme.of(context).iconTheme.color);
                    case CameraFacing.back:
                      return Icon(Icons.camera_rear, color:Theme.of(context).iconTheme.color);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ],
        ),
        body: MobileScanner(
          controller: cameraController,
          onDetect: (barcode, args) async {
            if (barcode.rawValue == null) {
              debugPrint('Failed to scan Barcode');
            } else {
              final String code = barcode.rawValue!;
              debugPrint('Barcode found! $code');
              bool valid = true;
              Reward? scannedReward;
              String? email = await UserUtils.readEmail();
              String? token = await UserUtils.readToken();
              if (email == null && token == null){
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  showDisconnectedDialog(context);
                });
              } else {
                  try {
                    scannedReward = await scanQr(code, email!, token!);
                  } on QrException catch (e) {
                    debugPrint(e.cause);
                    valid = false;
                  }
                }
                if (!mounted) return;
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return QrDialog(scannedReward: scannedReward, isValid: valid,);
                  },
                );

            }
          }
        )
    );
  }
}

class QrDialog extends StatelessWidget {
  const QrDialog({Key? key, required this.scannedReward, required this.isValid}) : super(key: key);
  final Reward? scannedReward;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    String title;
    Widget message;
    Icon icon;
    if (isValid) {
      if (scannedReward != null) {
        icon = const Icon(Icons.check_circle, size: 65, color: Colors.green);
        title = AppLocalizations.of(context)!.qrPositive;
        String at = AppLocalizations.of(context)!.at[0].toUpperCase() + AppLocalizations.of(context)!.at.substring(1).toLowerCase();
        message = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.qrPositiveMessage,textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(wordSpacing: 3.0,fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.titleLarge!.color, fontFamily: "JosefinSans", fontSize: 18),
                  children: <TextSpan> [
                    TextSpan(text: ("\n$at: ")),
                    TextSpan(text: "${scannedReward!.placeEvent}", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                    TextSpan(text: "\n${AppLocalizations.of(context)!.discountAmount}: "),
                    TextSpan(text: "${scannedReward!.discountAmount}%", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        title = AppLocalizations.of(context)!.qrNegative;
        icon = const Icon(Icons.error, size: 65, color: Colors.red);
        message = Text(AppLocalizations.of(context)!.qrNegativeMessage, style: const TextStyle(fontSize: 18),textAlign: TextAlign.center,);
      }
    } else {
      icon = const Icon(Icons.help, size: 65, color: Colors.red);
      title = AppLocalizations.of(context)!.qrNegative;
      message = Text(AppLocalizations.of(context)!.invalidQRMessage, style: const TextStyle(fontSize: 18),textAlign: TextAlign.center,);
    }
    return TopIconDialog(
      title: Center(child: Text(title,style: const TextStyle(fontSize: 20),)),
      content: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
        child: message,
      ),
      icon: icon,
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(AppLocalizations.of(context)!.backToHomepage, style: const TextStyle(fontSize: 15),)
        )
      ]
    );
  }
}
