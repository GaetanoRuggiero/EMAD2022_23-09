import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
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
        body: const OutlinedCardExample());
  }
}

class OutlinedCardExample extends StatelessWidget {
  const OutlinedCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['1', '2', '3', '4', '5'];
    return Center(
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        padding: const EdgeInsets.all(20),
        //constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: ListView.builder(
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
