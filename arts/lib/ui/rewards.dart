import 'package:arts/model/reward.dart';
import 'package:arts/model/user.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  String? email;
  String? token;
  String? idUser;
  late Future _couponsFuture;
  bool _showConnectionError = false;

  static Route<void> _fullscreenDialogRoute(
      BuildContext context,
      Reward reward,
      String qrUrl
      ) {
    return MaterialPageRoute<void>(
      builder: (context) => _FullScreenDialogDemo(reward: reward, qrUrl: qrUrl),
      fullscreenDialog: true,
    );
  }

  @override
  void initState() {
    super.initState();

    /* The first time we load this widget we get visited POI's by using
    *  Provider/Consumer, so for now we give an empty map as value to this
    *  future. This future is useful when the user wants to refresh the widget.
    *  Only in that case we make calls to database.*/
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
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.rewards),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home))
          ],
        ),
        body: FutureBuilder(
          future: _couponsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                Map<Reward, Coupon> couponMap = snapshot.data;
                if (couponMap.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: refreshTab,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.fromLTRB(5, 20, 5, 0),
                      //constraints: const BoxConstraints.expand(),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: ListView.builder(
                          itemCount: couponMap.length,
                          itemBuilder: (context, index) {
                            Reward reward = couponMap.keys.elementAt(index);
                            DateTime expiredData = DateTime.parse(reward.expiryDate!);
                            String rewardType = reward.type == "ticket" ? AppLocalizations.of(context)!.ticketDiscount : AppLocalizations.of(context)!.coupon;
                            return Container(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: reward.type == "ticket" ? const Icon(Icons.local_activity_outlined) : const Icon(Icons.sell),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: !couponMap.values.elementAt(index).used && DateTime.now().isBefore(expiredData) ? () {
                                          Navigator.push(context, _fullscreenDialogRoute(context, reward, couponMap.values.elementAt(index).qrUrl!));
                                        }
                                        : null,
                                        child: Text("$rewardType ${reward.discountAmount}%"
                                            " ${AppLocalizations.of(context)!.at} ${reward.placeEvent}"
                                            " ${AppLocalizations.of(context)!.availableUpTo} ${reward.expiryDate}",
                                        style: const TextStyle(fontSize: 15)),
                                      ),
                                    ),
                              ]),
                            );
                          }),
                    )
                  );
                }
                else {
                  // No Coupon obtained yet
                  return RefreshIndicator(
                    onRefresh: refreshTab,
                    child: Stack(
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
                                  const Icon(Icons.sentiment_dissatisfied_outlined,size: 40,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(textAlign: TextAlign.center,style: const TextStyle(fontSize: 15, color: lightOrange), AppLocalizations.of(context)!.noCoupon),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ListView(), //Pull to refresh needs at least a scrollable list to work
                        ]
                    ),
                  );
                }
              }
              else if (_showConnectionError) {
                // Connection with server has failed (or timed out)
                return RefreshIndicator(
                  onRefresh: refreshTab,
                  child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                              Text(textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                                  AppLocalizations.of(context)!.connectionError
                              ),
                            ],
                          ),
                        ),
                        ListView(), //Pull to refresh needs at least a scrollable list to work
                      ]
                  ),
                );
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
    );
  }
}

class _FullScreenDialogDemo extends StatelessWidget {
  const _FullScreenDialogDemo({Key? key, required this.reward, required this.qrUrl}) : super(key: key);
  final Reward reward;
  final String qrUrl;

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 22),
                text: "${AppLocalizations.of(context)!.goTo} ${reward.placeEvent} ${AppLocalizations.of(context)!.redeem} ",
                children: <TextSpan>[
                  TextSpan(text: "\n${AppLocalizations.of(context)!.remember} ${reward.expiryDate}", style: const TextStyle(fontWeight: FontWeight.bold))
                ]
              )
            )
          ),
          Center(
            child: PrettyQr(
                  image: const AssetImage('assets/icon/icon.png'),
                  size: 350,
                  data: qrUrl,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  roundEdges: true,
                ),
          ),

        ],
      )
    );
  }
}
