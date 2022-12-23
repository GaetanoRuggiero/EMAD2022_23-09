import 'package:arts/ui/login.dart';
import 'package:arts/ui/seasonrewards.dart';
import 'package:arts/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'rewards.dart';

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
        body: Column(children: [
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    const Icon(size: 70, Icons.account_circle),
                    Text(AppLocalizations.of(context)!.name),
                    const SeasonCard(),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    children: [
                      IconButton(
                          color: const Color(0xFFEB9E5C),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SettingsScreen()),
                            );
                          },
                          icon: const Icon(size: 30, Icons.settings)),
                      IconButton(
                          color: const Color(0xFFEB9E5C),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RewardsPage()));
                          },
                          icon: const Icon(size: 25, FontAwesomeIcons.gift)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(AppLocalizations.of(context)!.redirectLog,
                    style: const TextStyle(fontSize: 20))),
          ),
          Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                  textAlign: TextAlign.center,
                  "Badge",
                  style: TextStyle(fontSize: 20))),
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.bottomLeft,
            child: const Text(style: TextStyle(fontSize: 15), "Campania"),
          ),
          Card(
            margin: const EdgeInsets.all(20),
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
                  children: [
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars_outlined)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars_outlined)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.bottomLeft,
            child: const Text(style: TextStyle(fontSize: 15), "Toscana"),
          ),
          Card(
            margin: const EdgeInsets.all(20),
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
                  children: [
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars)),
                    IconButton(
                        iconSize: 50,
                        onPressed: () {},
                        icon: const Icon(Icons.stars_outlined)),
                  ],
                ),
              ),
            ),
          ),
        ]));
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
      margin: const EdgeInsets.only(top: 10),
      elevation: 4,
      color: const Color(0xFFEB9E5C),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${AppLocalizations.of(context)!.seasonMex} $day/$month/$year"),
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
