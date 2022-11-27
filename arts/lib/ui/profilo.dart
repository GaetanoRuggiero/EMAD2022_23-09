import 'package:flutter/material.dart';

class Profilo extends StatelessWidget {
  const Profilo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          title: Text("Profilo"),
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: Icon(Icons.home_rounded))
          ],
        ),
        body: Stack(
          children: [ElevatedCard()],
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
        FittedBox(),
        Container(
          margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(size: 70, Icons.account_circle),
                  IconButton(
                      alignment: Alignment.bottomLeft,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {},
                      icon: Icon(size: 15, Icons.edit)),
                ],
              ),
              Text(textAlign: TextAlign.left, "nome Utente"),
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
    /*Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SizedBox(
          width: 300,
          height: 150,
          child: Row(children: <Widget>[
            Column(children: <Widget>[
              Icon(size: 70, Icons.account_circle),
              Text("nome Utente"),
            ]),
            IconButton(onPressed: () {}, icon: Icon(size: 15, Icons.edit)),
            Column()
          ])),
    );*/
  }
}
