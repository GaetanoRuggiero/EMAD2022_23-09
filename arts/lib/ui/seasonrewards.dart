import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeasonRewardsPage extends StatefulWidget {
  const SeasonRewardsPage({Key? key}) : super(key: key);

  @override
  State<SeasonRewardsPage> createState() => _SeasonRewardsPageState();
}

class _SeasonRewardsPageState extends State<SeasonRewardsPage> {
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
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                 child: Container(margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),child: Text(style: const TextStyle(fontSize: 18),
                     AppLocalizations.of(context)!.seasonRewardMex)))),
            const Expanded(child: SeasonRewardsCard()),
          ],
        ));
  }
}

class SeasonRewardsCard extends StatelessWidget {
  const SeasonRewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['1', '2', '3', '4', '5'];
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: ListView.builder(
          shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.sell),
                  ),
                  Text("Buono Sconto n°${entries[index]}",
                      style: const TextStyle(fontSize: 15)),
                  const Text(" fino al 31/11/2022",
                      style: TextStyle(fontSize: 15))
                ]),
              );
            }),
      ),
    );
  }
}
