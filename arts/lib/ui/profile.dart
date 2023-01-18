import 'package:arts/model/POI.dart';
import 'package:arts/ui/seasonrewards.dart';
import 'package:arts/ui/settings.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'editprofilescreen.dart';
import 'rewards.dart';
import 'package:percent_indicator/percent_indicator.dart';

const int poiCountForLevel=5, firstStep=1, secondStep=2, thirdStep=3, fourthStep=4, fifthStep=5;
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
            String level = (userProvider.visited.length~/poiCountForLevel).toString();
            int levelProgress = (userProvider.visited.length%poiCountForLevel);
            return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Column(
                          children: [
                            CircularPercentIndicator(
                              radius: 60,
                              lineWidth: 13.0,
                              animation: true,
                              center: Text(level, style: TextStyle(fontSize: 40, color: Theme.of(context).backgroundColor, /*TODO: SET FONT fontFamily:*/ )),
                              percent: levelProgress*0.2,
                              circularStrokeCap: CircularStrokeCap.round,
                              //TODO: GRADIENT OR DINAMIC COLOR? progressColor: levelProgress == firstStep ? Theme ,
                              footer: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text("${userProvider.name} ${userProvider.surname}", style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SeasonCard(),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 20, 5, 0),
                          child: Column(
                            children: [
                              Tooltip(
                                message: AppLocalizations.of(context)!.modifyPassword,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const EditProfileScreen()),
                                      );
                                    },
                                    icon: const Icon(size: 30, Icons.edit)),
                              ),
                              Tooltip(
                                message: AppLocalizations.of(context)!.settings,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const SettingsScreen()),
                                      );
                                    },
                                    icon: const Icon(size: 30, Icons.settings)),
                              ),
                              Tooltip(
                                message: AppLocalizations.of(context)!.rewards,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const RewardsPage()));
                                    },
                                    icon: const Icon(size: 30, Icons.redeem_rounded)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 20),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Divider()
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Badge"),
                        ),
                        Expanded(
                          child: Divider()
                        ),
                      ]
                    ),
                  ),
                  Flexible(
                      child: BadgeWidget(visitedPoi: userProvider.visited)
                  ),
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
      margin: const EdgeInsets.only(top: 30, bottom: 10),
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

class GridBadgeItem extends StatelessWidget {
  const GridBadgeItem({Key? key, required this.element}) : super(key: key);
  final MapEntry<String, int> element;
  static const String italia = "Italia", francia = "Francia", spagna = "Spagna";

  @override
  Widget build(BuildContext context) {
    String assets="";
    switch(element.key) {
      case italia :{assets = 'assets/icon/italy.png';}
        break;
      case francia :{assets = 'assets/icon/france.png';}
      break;
      case spagna :{assets = 'assets/icon/spain.png';}
      break;
    }

    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(assets)),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
                border: Border.all()
            ),
            child: Text(element.value.toString(),style: const TextStyle(fontSize: 25),),
          ),
        ),
      )
    );
  }
}


class BadgeWidget extends StatelessWidget {
  const BadgeWidget({Key? key, required this.visitedPoi}) : super(key: key);
  final Map<POI, String> visitedPoi;

  @override
  Widget build(BuildContext context) {
    Map<String, int> badgePerCountry = UserUtils.getBadgePerCountry(visitedPoi);
    int countryCount = badgePerCountry.keys.length;
    if (countryCount > 0) {
      return GridView.count(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          padding: const EdgeInsets.all(10),
          childAspectRatio: 1,
          children: badgePerCountry.entries.map((element) {
            return GridBadgeItem(element: element);
          }).toList()
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(20,  0, 20, 0),
        padding: const EdgeInsets.all(20),
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
              child: Text(textAlign: TextAlign.center,style: const TextStyle(fontSize: 15, color: lightOrange), AppLocalizations.of(context)!.noBadge),
            ),
          ],
        ),
      );
    }
  }
}


