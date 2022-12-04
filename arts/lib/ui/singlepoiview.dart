import 'package:flutter/material.dart';
import '../model/POI.dart';

class SinglePOIView extends StatelessWidget {
  const SinglePOIView({super.key, required this.poi});
  final POI poi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(poi.name!),
          actions: [IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }, icon: const Icon(Icons.home))],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                height: 350.0,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Image.asset(poi.imageURL!, fit: BoxFit.fitHeight),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Steps(poiHistory: poi.history!, poiTrivia: poi.trivia!)
              ),
            ),
          ],
        )
    );
  }
}

class _Step {
  _Step(this.title, this.body, [this.isExpanded = false]);

  String title;
  String body;
  bool isExpanded;
}

class Steps extends StatefulWidget {
  final String poiHistory, poiTrivia;

  const Steps({Key? key, required this.poiHistory, required this.poiTrivia}) : super(key: key);

  @override
  State<Steps> createState() => StepsState();
}

class StepsState extends State<Steps> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _renderSteps(),
      ),
    );
  }

  Widget _renderSteps() {
    debugPrint(widget.poiHistory);
    final List<_Step> steps = [_Step('Cenni storici', widget.poiHistory) ,_Step('Curiosità', widget.poiTrivia)];

    return ExpansionPanelList.radio(
      children: steps.map<ExpansionPanelRadio>((_Step step) {
        return ExpansionPanelRadio(
            canTapOnHeader: true,
            backgroundColor: Colors.grey.shade200,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(step.title),
              );
            },
            body: Container(
                //height: 135,
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Text(step.body)),
            value: step.title);
      }).toList(),
    );
  }
}
