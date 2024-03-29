import 'package:arts/model/reward.dart';
import 'package:arts/model/user.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../api/user_api.dart';
import '../exception/exceptions.dart';
import '../utils/user_utils.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';


class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  String? email, token, idUser;
  late Future _couponsFuture;
  bool _showConnectionError = false;
  int _currentIndex = 0;

  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    _couponsFuture = Future.delayed(Duration.zero, () async {
      email = await UserUtils.readEmail();
      token = await UserUtils.readToken();
      idUser = await getIdUser(email!);
      try {
        Map<Reward, Coupon>? couponMap = await getCoupon(email!, token!);
        setState(() {
          _couponsFuture = Future.value(couponMap);
        });
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
        setState(() {
          _showConnectionError = true;
        });
      }
    });
  }

  Future<void> refreshTab() async {
    if (email != null && token != null) {
      try {
        Map<Reward, Coupon>? couponMap = await getCoupon(email!, token!);
          setState(() {
            _couponsFuture = Future.value(couponMap);
          });
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
        setState(() {
          _showConnectionError = true;
          _couponsFuture= Future.value();
        });
      }
    }
    return _couponsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.rewards),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home))
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (newIndex) {
              _pageController.animateToPage(
                newIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
            },
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.savings),
                  activeIcon: Container(
                    height: 30,
                    decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    margin: const EdgeInsets.only(bottom: 3),
                    child: Icon(
                        Icons.savings,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.available
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.event_busy),
                  activeIcon: Container(
                    height: 30,
                    decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    margin: const EdgeInsets.only(bottom: 3),
                    child: Icon(
                      Icons.event_busy,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.expired
              ),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long),
                  activeIcon: Container(
                    height: 30,
                    decoration: BoxDecoration(
                        color: lightOrange,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    margin: const EdgeInsets.only(bottom: 3),
                    child: Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                  label: AppLocalizations.of(context)!.all
              )
            ],
          ),
          body: FutureBuilder(
            future: _couponsFuture,
            builder: (context, snapshot) {
              Map<Reward, Coupon> couponMapAvailable ={};
              Map<Reward, Coupon> couponMapExpired ={};
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  Map<Reward, Coupon> couponMap = snapshot.data;
                  if (couponMap.isNotEmpty) {
                    couponMap.forEach((reward, coupon) {
                      DateTime expiredDate = DateTime.parse(reward.expiryDate!);
                      if (DateTime.now().isAfter(expiredDate)) {
                        couponMapExpired.putIfAbsent(reward, () => coupon);
                      } else if (!coupon.used) {
                        couponMapAvailable.putIfAbsent(reward, () => coupon);
                      }
                    });
                  }
                  return PageView(
                    controller: _pageController,
                    onPageChanged: (value) {
                        setState(() {
                          _currentIndex = value;
                        });
                    },
                    children: [
                      AvailableCoupon(couponMap: couponMapAvailable),
                      ExpiredCoupon(couponMap: couponMapExpired),
                      AllCoupon(couponMap: couponMap)
                    ],
                  );
                } else if (_showConnectionError) {
                  // Connection with server has failed (or timed out)
                  return showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab());
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    showDisconnectedDialog(context);
                  });
                  return Container();
                }
              } else {
                // Showing a loading screen until future is complete
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(AppLocalizations.of(context)!.loading),
                          ),
                        ]
                    )
                );
              }
            }
          )
      ),
    );
  }
}

class AvailableCoupon extends StatefulWidget {
  const AvailableCoupon({Key? key, required this.couponMap}) : super(key: key);
  final Map<Reward, Coupon> couponMap;

  @override
  State<AvailableCoupon> createState() => _AvailableCouponState();
}

class _AvailableCouponState extends State<AvailableCoupon> with AutomaticKeepAliveClientMixin {
  late Map<Reward, Coupon> _couponMap;
  bool _showConnectionError = false;

  static Route<void> _fullscreenDialogRoute(BuildContext context, Reward reward, String qrUrl) {
    return MaterialPageRoute<void>(
      builder: (context) => _FullScreenDialogCoupon(reward: reward, qrUrl: qrUrl),
      fullscreenDialog: true,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _couponMap = widget.couponMap;
  }

  Future<void> refreshTab() {
    Map<Reward, Coupon>? couponMap = {};

    return Future.delayed(Duration.zero, () async {
      String? email = await UserUtils.readEmail();
      String? token = await UserUtils.readToken();
      try {
        couponMap = await getCoupon(email!, token!);
        if (couponMap != null) {
          if (couponMap!.isNotEmpty) {
            couponMap!.forEach((reward, coupon) {
              DateTime expiredDate = DateTime.parse(reward.expiryDate!);
              if (DateTime.now().isAfter(expiredDate) || coupon.used) {
                _couponMap.remove(reward);
              } else {
                _couponMap.update(reward, (value) => coupon, ifAbsent: () => coupon);
              }
            });
          }
        } else {
          _couponMap = {};
        }
        setState(() {
          _showConnectionError = false;
        });
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
        setState(() {
          _showConnectionError = true;
        });
      }
      debugPrint(_couponMap.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_showConnectionError) {
      return showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab());
    }
    if (_couponMap.isNotEmpty) {
      return RefreshIndicator(
          onRefresh: refreshTab,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: ListView.builder(
                itemCount: _couponMap.length,
                itemBuilder: (context, index) {
                  Reward reward = _couponMap.keys.elementAt(index);
                  String rewardType = reward.type == "ticket" ? AppLocalizations.of(context)!.ticketDiscount
                      : AppLocalizations.of(context)!.coupon;
                  String formattedDate = Localizations.localeOf(context).languageCode == "en" ? DateFormat('yyyy-MM-dd').format(DateTime.parse(reward.expiryDate!)).toString()
                  : DateFormat('dd-MM-yyyy').format(DateTime.parse(reward.expiryDate!)).toString();
                  return Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: reward.type == "ticket" ? const Icon(Icons.local_activity_outlined,)
                              : const Icon(Icons.sell,),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  _fullscreenDialogRoute(context, reward, _couponMap.values.elementAt(index).qrUrl!)
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(wordSpacing: 3.0,fontWeight: FontWeight.w500, color: Colors.white, fontFamily: "JosefinSans"),
                                  children: <TextSpan> [
                                    TextSpan(text: ("$rewardType ${reward.discountAmount}% ${AppLocalizations.of(context)!.at}")),
                                    TextSpan(text: " ${reward.placeEvent}", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                                    TextSpan(text: (" ${AppLocalizations.of(context)!.availableUpTo}")),
                                    TextSpan(text: " $formattedDate.", style: TextStyle(color: Theme.of(context).iconTheme.color,)),
                                  ],
                                ),
                              ),
                            )
                          ),
                        ),
                      ]
                    ),
                  );
                }),
          )
      );
    } else {
      return RefreshIndicator(
          onRefresh: refreshTab,
        child: NoCoupon(errorMessage : AppLocalizations.of(context)!.noCouponAvaible, expired: false),
      );
    }
  }
}

class ExpiredCoupon extends StatefulWidget {
  const ExpiredCoupon({Key? key, required this.couponMap}) : super(key: key);
  final Map<Reward, Coupon> couponMap;

  @override
  State<ExpiredCoupon> createState() => _ExpiredCouponState();
}

class _ExpiredCouponState extends State<ExpiredCoupon> with AutomaticKeepAliveClientMixin {
  late Map<Reward, Coupon> _couponMap;
  bool _showConnectionError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _couponMap = widget.couponMap;
  }

  Future<void> refreshTab() {
    Map<Reward, Coupon>? couponMap = {};

    return Future.delayed(Duration.zero, () async {
      String? email = await UserUtils.readEmail();
      String? token = await UserUtils.readToken();
      try {
        couponMap = await getCoupon(email!, token!);
        if (couponMap != null) {
          if (couponMap!.isNotEmpty) {
            couponMap!.forEach((reward, coupon) {
              DateTime expiredDate = DateTime.parse(reward.expiryDate!);
              if (DateTime.now().isAfter(expiredDate)) {
                _couponMap.update(reward, (value) => coupon, ifAbsent: () => coupon);
              } else {
                _couponMap.remove(reward);
              }
            });
          }
        } else {
          _couponMap = {};
        }
        setState(() {
          _showConnectionError = false;
        });
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
        setState(() {
          _showConnectionError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_showConnectionError) {
      return showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab());
    }
    if (_couponMap.isNotEmpty) {
      return RefreshIndicator(
          onRefresh: refreshTab,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: ListView.builder(
                itemCount: _couponMap.length,
                itemBuilder: (context, index) {
                  Reward reward = _couponMap.keys.elementAt(index);
                  String rewardType = reward.type == "ticket" ? AppLocalizations.of(context)!.ticketDiscount
                      : AppLocalizations.of(context)!.coupon;
                  String formattedDate = Localizations.localeOf(context).languageCode == "en" ? DateFormat('yyyy-MM-dd').format(DateTime.parse(reward.expiryDate!)).toString()
                      : DateFormat('dd-MM-yyyy').format(DateTime.parse(reward.expiryDate!)).toString();
                  return Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: reward.type == "ticket" ? const Icon(Icons.local_activity_outlined)
                              : const Icon(Icons.sell),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(wordSpacing: 3.0,fontWeight: FontWeight.w500, color: Colors.white, fontFamily: "JosefinSans"),
                                children: <TextSpan> [
                                  TextSpan(text: ("$rewardType ${reward.discountAmount}% ${AppLocalizations.of(context)!.at}")),
                                  TextSpan(text: " ${reward.placeEvent}", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                                  TextSpan(text: (" ${AppLocalizations.of(context)!.availableUpTo}")),
                                  TextSpan(text: " $formattedDate.", style: TextStyle(color: Theme.of(context).iconTheme.color,)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]
                    ),
                  );
                }),
          )
      );
    } else {
      return RefreshIndicator(
        onRefresh: refreshTab,
        child: NoCoupon(errorMessage: AppLocalizations.of(context)!.noCouponExpired, expired: true),
      );
    }
  }
}


class AllCoupon extends StatefulWidget {
  const AllCoupon({Key? key, required this.couponMap}) : super(key: key);
  final Map<Reward, Coupon> couponMap ;

  @override
  State<AllCoupon> createState() => _AllCouponState();
}

class _AllCouponState extends State<AllCoupon> with AutomaticKeepAliveClientMixin {
  late Map<Reward, Coupon> _couponMap;
  bool _showConnectionError = false;

  static Route<void> _fullscreenDialogRoute(BuildContext context, Reward reward, String qrUrl) {
    return MaterialPageRoute<void>(
      builder: (context) => _FullScreenDialogCoupon(reward: reward, qrUrl: qrUrl),
      fullscreenDialog: true,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _couponMap = widget.couponMap;
  }

  Future<void> refreshTab() {
    Map<Reward, Coupon>? couponMap = {};

    return Future.delayed(Duration.zero, () async {
      String? email = await UserUtils.readEmail();
      String? token = await UserUtils.readToken();
      try {
        couponMap = await getCoupon(email!, token!);
        if (couponMap != null) {
          _couponMap = couponMap!;
          setState(() {
            _showConnectionError = false;
          });
        }
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
        setState(() {
          _showConnectionError = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_showConnectionError) {
      return showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab());
    }
    if (_couponMap.isNotEmpty) {
      return RefreshIndicator(
          onRefresh: refreshTab,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
            child: ListView.builder(
                itemCount: _couponMap.length,
                itemBuilder: (context, index) {
                  Reward reward = _couponMap.keys.elementAt(index);
                  DateTime expiredDate = DateTime.parse(reward.expiryDate!);
                  String rewardType = reward.type == "ticket" ? AppLocalizations.of(context)!.ticketDiscount
                      : AppLocalizations.of(context)!.coupon;
                  String formattedDate = Localizations.localeOf(context).languageCode == "en" ? DateFormat('yyyy-MM-dd').format(DateTime.parse(reward.expiryDate!)).toString()
                      : DateFormat('dd-MM-yyyy').format(DateTime.parse(reward.expiryDate!)).toString();
                  return Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: _couponMap.values.elementAt(index).used ? Colors.grey.shade800
                            : DateTime.now().isAfter(expiredDate) ? Colors.red.shade900
                            : darkBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: reward.type == "ticket" ? const Icon(Icons.local_activity_outlined)
                                : const Icon(Icons.sell),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: (!_couponMap.values.elementAt(index).used) && DateTime.now().isBefore(expiredDate) ? () {
                                Navigator.push(context, _fullscreenDialogRoute(
                                    context,
                                    reward,
                                    _couponMap.values.elementAt(index).qrUrl!));
                              } : null,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      wordSpacing: 3.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontFamily: "JosefinSans"
                                    ),
                                    children: <TextSpan> [
                                      TextSpan(text: ("$rewardType ${reward.discountAmount}% ${AppLocalizations.of(context)!.at}")),
                                      TextSpan(text: " ${reward.placeEvent}", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                                      TextSpan(text: (" ${AppLocalizations.of(context)!.availableUpTo}")),
                                      TextSpan(text: " $formattedDate.", style: TextStyle(color: Theme.of(context).iconTheme.color,)),
                                    ],
                                  ),
                                ),
                              )
                            ),
                          ),
                        ]),
                  );
                }),
          )
      );
    } else {
      return RefreshIndicator(
        onRefresh: refreshTab,
        child: NoCoupon(errorMessage: AppLocalizations.of(context)!.noCouponObtained, expired: false),
      );
    }
  }
}

class _FullScreenDialogCoupon extends StatelessWidget {
  const _FullScreenDialogCoupon({Key? key, required this.reward, required this.qrUrl}) : super(key: key);
  final Reward reward;
  final String qrUrl;

  @override
  Widget build(BuildContext context) {
    String formattedDate = Localizations.localeOf(context).languageCode == "en" ? DateFormat('yyyy/MM/dd').format(DateTime.parse(reward.expiryDate!)).toString()
        : DateFormat('dd/MM/yyyy').format(DateTime.parse(reward.expiryDate!)).toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(reward.type![0].toUpperCase() + reward.type!.substring(1).toLowerCase()),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home))
        ],
      ),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.all(20),
              child: Text.rich(
                  TextSpan(
                      style: const TextStyle(fontSize: 22),
                      text: "${AppLocalizations.of(context)!.goTo} ",
                      children: <TextSpan>[
                        TextSpan(text: "${reward.placeEvent}", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                        TextSpan(text: " ${AppLocalizations.of(context)!.redeem}."),
                        TextSpan(text: "\n${AppLocalizations.of(context)!.remember} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "$formattedDate!", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).iconTheme.color))
                      ]
                  )
              )
          ),
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: PrettyQr(
                  image: const AssetImage('assets/icon/icon_big.png'),
                  size: MediaQuery.of(context).size.width - 90,
                  data: qrUrl,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}

class NoCoupon extends StatelessWidget {
  const NoCoupon({Key? key, required this.errorMessage, required this.expired}) : super(key: key);
  final String errorMessage;
  final bool expired;

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(expired ? Icons.sentiment_satisfied_outlined : Icons.sentiment_dissatisfied_outlined,size: 40),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(textAlign: TextAlign.center,style: const TextStyle(fontSize: 15, color: lightOrange), errorMessage),
                  ),
                ],
              ),
            ),
          ),
          ListView(), //Pull to refresh needs at least a scrollable list to work
        ]
    );
  }
}