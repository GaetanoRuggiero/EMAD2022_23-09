import 'package:arts/model/sidequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../model/POI.dart';
import '../model/reward.dart';

class SinglePOIView extends StatelessWidget {
  const SinglePOIView({super.key, required this.poi, required this.sidequest});
  final POI poi;
  final Sidequest? sidequest;

  @override
  Widget build(BuildContext context) {
    if (sidequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(context: context, builder: (context) => SidequestCompletedDialog(reward: sidequest!.reward!));
      });
    }
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
            poi.modelName != null ?
              ElevatedButton.icon(
                icon: const Icon(Icons.view_in_ar_outlined),
                label: Text(AppLocalizations.of(context)!.view3dModel),
                onPressed: () {}
              )
            : const Text(""),
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
  _Step(this.title, this.body);

  String title;
  String body;
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
    final List<_Step> steps = [_Step(AppLocalizations.of(context)!.history, widget.poiHistory) ,_Step(AppLocalizations.of(context)!.trivia, widget.poiTrivia)];

    return ExpansionPanelList.radio(
      children: steps.map<ExpansionPanelRadio>((_Step step) {
        return ExpansionPanelRadio(
            canTapOnHeader: true,
            //backgroundColor: Colors.grey.shade200,
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

class SidequestCompletedDialog extends StatelessWidget {
  const SidequestCompletedDialog({Key? key, required this.reward}) : super(key: key);
  final Reward reward;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("${AppLocalizations.of(context)!.missionCompleted}!"),
      content: Text("${AppLocalizations.of(context)!.youHaveReceived} 1 ${reward.type} ${AppLocalizations.of(context)!.sideQuestGoToLower} ${reward.placeEvent}!"),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}