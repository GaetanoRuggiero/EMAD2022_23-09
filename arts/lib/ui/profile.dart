import 'package:arts/model/POI.dart';
import 'package:arts/ui/seasonrewards.dart';
import 'package:arts/ui/settings.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/widget_utils.dart';
import 'editprofilescreen.dart';
import 'rewards.dart';
import 'package:percent_indicator/percent_indicator.dart';

const int poiCountForLevel=5, firstStep=1, secondStep=2, thirdStep=3, fourthStep=4, fifthStep=5;
class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              String level = (userProvider.visited.length ~/ poiCountForLevel).toString();
              int levelProgress = (userProvider.visited.length % poiCountForLevel);
              String formattedDate = Localizations.localeOf(context).languageCode == "en" ? DateFormat('yyyy/MM/dd').format(DateTime.parse(userProvider.registrationDate)).toString()
                  : DateFormat('dd/MM/yyyy').format(DateTime.parse(userProvider.registrationDate)).toString();
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: CircularPercentIndicator(
                                radius: 60,
                                lineWidth: 15.0,
                                backgroundWidth: 13,
                                animation: true,
                                center: Text(level, style: const TextStyle(fontSize: 50,fontFamily: "JosefinSans")),
                                percent: levelProgress*0.2,
                                circularStrokeCap: CircularStrokeCap.round,
                                linearGradient: const LinearGradient(colors: [Colors.deepPurpleAccent, Colors.blueAccent, Colors.cyan]),
                                backgroundColor: Colors.transparent,
                                footer: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child: Text("${userProvider.name} ${userProvider.surname}", style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: 180,
                                child: Image.asset("assets/icon/avatar_border.png", fit: BoxFit.fitWidth,)
                            ),
                            //const SeasonCard(),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 8,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [BoxShadow(
                                  offset: Offset(0, 0.75),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                )],
                                color: Theme.of(context).colorScheme.onTertiary,
                                shape: BoxShape.circle,
                              ),
                              child: Tooltip(
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
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [BoxShadow(
                                  offset: Offset(0, 0.75),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                )],
                                color: Theme.of(context).colorScheme.onTertiary,
                                shape: BoxShape.circle,
                              ),
                              child: Tooltip(
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
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: const [BoxShadow(
                                  offset: Offset(0, 0.75),
                                  spreadRadius: 0,
                                  blurRadius: 1,
                                )],
                                color: Theme.of(context).colorScheme.onTertiary,
                                shape: BoxShape.circle,
                              ),
                              child: Tooltip(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Theme.of(context).colorScheme.tertiary),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 70),
                          child: Text(AppLocalizations.of(context)!.registrationDate),
                        ),
                        Text(formattedDate,style: TextStyle(color: Theme.of(context).textTheme.titleSmall!.color)),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Image.asset("assets/icon/ribbon.png", fit: BoxFit.fitWidth,),
                      ),
                      const Positioned(top: 7, child: Text("Badge",style: TextStyle(fontSize: 18,color: Colors.white),))
                    ],
                  ),
                  Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: BadgeWidget(visitedPoi: userProvider.visited),
                      )
                  ),
                ]
              );
            },
          ),
        ));
  }
}
//not implemented yet!
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

  @override
  Widget build(BuildContext context) {
    String assets="";
    switch(element.key.toLowerCase()) {
      case italia : {assets = 'assets/icon/italy.png';}
        break;
      case francia : {assets = 'assets/icon/france.png';}
        break;
      case spagna : {assets = 'assets/icon/spain.png';}
        break;
    }

    return GridTile(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onTertiary,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 0.75),
              blurRadius: 0.5,
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 35),
              child: Image.asset(assets),
            ),
            Positioned(
              bottom: -120,
              child: Container(
                width: 100,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: darkBlue
                )
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              )
            ),
            Positioned(
              bottom: 2,
              child: Text(element.value.toString(),style: const TextStyle(fontSize: 23, color: Colors.white)),
            )
          ],
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
      return ScrollConfiguration(
        behavior: NoGlow(),
        child: GridView.count(
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
        ),
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


