import 'package:flutter/material.dart';

class Profilo extends StatelessWidget {
  const Profilo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profilo"),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
        ),
        body: Stack(
          children: const [ElevatedCard()],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const FittedBox(),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(size: 70, Icons.account_circle),
                  IconButton(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                      icon: const Icon(size: 15, Icons.edit)),
                ],
              ),
              const Text(textAlign: TextAlign.left, "nome Utente"),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: const [
              Icon(size: 30, Icons.settings),
              SizedBox(
                height: 5,
              ),
              Icon(size: 30, Icons.redeem),
            ],
          ),
        )
      ],
    );
  }
}
