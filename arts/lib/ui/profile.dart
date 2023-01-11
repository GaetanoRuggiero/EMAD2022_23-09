import 'package:arts/model/POI.dart';
import 'package:arts/ui/seasonrewards.dart';
import 'package:arts/ui/settings.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'rewards.dart';

const int badgeDiamond = 50, badgePlatinum = 25, badgeGold = 10, badgeSilver = 3, badgeBronze = 1;
class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
        ),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Column(
                          children: [
                            const Icon(size: 100, Icons.account_circle),
                            Text("${userProvider.name} ${userProvider.surname}", style: const TextStyle(fontSize: 20)),
                            const SeasonCard(),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 30, 5, 0),
                          child: Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const SettingsScreen()),
                                    );
                                  },
                                  icon: const Icon(size: 35, Icons.settings)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const RewardsPage()));
                                  },
                                  icon: const Icon(size: 35, Icons.redeem_rounded)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: BadgeWidget(visitedPoi: userProvider.visited)),
                ]);
          },
        ));
  }
}

class SeasonCard extends StatelessWidget {
  const SeasonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().add(const Duration(days: 30));
    String day = now.day.toString();
    String month = now.month.toString();
    String year = now.year.toString();
    return Card(
      margin: const EdgeInsets.only(top: 20, bottom: 30),
      elevation: 4,
      color: const Color(0xFFEB9E5C),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${AppLocalizations.of(context)!.seasonMex} $day/$month/$year", style: const TextStyle(fontSize: 15),),
            IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SeasonRewardsPage()),
                  );
                },
                icon: const Icon(Icons.navigate_next)),
          ],
        ),
      ),
    );
  }
}

class BadgeWidget extends StatelessWidget {
  const BadgeWidget({Key? key, required this.visitedPoi}) : super(key: key);
  final Map<POI, String> visitedPoi;

  List<Widget> displayBadgePerRegion(BuildContext context, int count){
    List<Widget> badges = [];
    int countBadges = 0;
    if (count >= badgeDiamond) {
      countBadges = 5;
    } else if (count < badgeDiamond && count >= badgePlatinum) {
      countBadges = 4;
    } else if (count < badgePlatinum && count >= badgeGold) {
      countBadges = 3;
    } else if (count < badgeGold && count >= badgeSilver) {
      countBadges = 2;
    } else if (count < badgeSilver && count >= badgeBronze) {
      countBadges = 1;
    }
    for (var i = 1; i <= countBadges; i++) {
      badges.add(
        IconButton(
          iconSize: 50,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  debugPrint(count.toString());
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius:BorderRadius.circular(30.0)),
                    content: Text("${AppLocalizations.of(context)!.numberVisitedPoi} $count POI ${AppLocalizations.of(context)!.xRegion}"),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          },
          icon: const Icon(Icons.stars)
        )
      );
    }
    for (var i = countBadges+1; i <= 5; i++) {
      badges.add(
          const IconButton(
              iconSize: 50,
              onPressed: null,
              icon: Icon(Icons.stars_outlined)
          )
      );
    }
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> badgePerRegion = UserUtils.getBadgePerRegion(visitedPoi);
    int regionCount = badgePerRegion.keys.length;
    const int maxRegionCount = 3;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: regionCount < maxRegionCount ? regionCount : maxRegionCount,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20),
              alignment: Alignment.bottomLeft,
              child: Text(style: const TextStyle(fontSize: 15), badgePerRegion.keys.elementAt(index)),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              elevation: 3,
              child: Container(
                height: 90,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: displayBadgePerRegion(context, badgePerRegion.values.elementAt(index)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      },
    );
  }
}


