import '../model/sidequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../api/sidequest_api.dart';

class SideQuest extends StatefulWidget {
  const SideQuest({Key? key}) : super(key: key);

  @override
  State<SideQuest> createState() => _SideQuestState();
}

class _SideQuestState extends State<SideQuest> {

  List<Sidequest> _sideQuestList = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.mission),
        actions: <Widget>[
          IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
              icon: const Icon(Icons.home_rounded))
        ],
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.sideQuestAvailableEvents),
              ],
            ),
          ),

          FutureBuilder(
              future: getAllSidequest(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var sideQuestList = snapshot.data;
                  if (sideQuestList == null){

                    return Container(padding: const EdgeInsets.all(20.0), child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                        Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                            AppLocalizations.of(context)!.connectionError
                        )
                      ],
                    )
                    );
                  }
                  _sideQuestList = sideQuestList;
                  if (sideQuestList.isNotEmpty) {
                    return Expanded(
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return SideQuestCard(sidequest: _sideQuestList[index]);
                          },
                          separatorBuilder: (BuildContext context, int index) {return const Divider();},
                          itemCount: _sideQuestList.length
                      ),
                    );
                  }
                  else {

                    return Container(padding: const EdgeInsets.all(20.0), child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                        Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                            AppLocalizations.of(context)!.emptyMission
                        )
                      ],
                    ));
                  }
                }
                else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
          ),
        ],
      ),
    );
  }
}

class SideQuestCard extends StatelessWidget {

  const SideQuestCard({
    Key? key,
    required this.sidequest,
  }) : super(key: key);

  final Sidequest sidequest;

  @override
  Widget build(BuildContext context) {

    final deviceOrientation = MediaQuery.of(context).orientation;
    final startDate = DateTime.fromMillisecondsSinceEpoch(sidequest.startDate!.seconds! * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);
    final formattedStartDate = DateFormat("dd/MM/yyyy").format(startDate);
    final formattedEndDate = DateFormat("dd/MM/yyyy").format(endDate);

    return Card(
      color: const Color(0xff113197),
      margin: const EdgeInsets.all(10),
      elevation: 2.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),

      child: Stack(
        children: [

          Container(
              margin: const EdgeInsets.only(left: 70.0),
              height: 250.0,
              width: double.infinity,
              child: Image.network(sidequest.reward!.poster!,
                  fit: ( deviceOrientation == Orientation.portrait ? BoxFit.fitHeight : BoxFit.fitWidth))
          ),

          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: const AlignmentDirectional(3.5, 0),
                    end: const FractionalOffset(0.25, 0.25),
                    colors: [
                      Colors.black.withOpacity(0.0),
                      const Color(0xff113197),
                    ],
                    stops: const [
                      0.0,
                      1.0
                    ])),
          ),

          Container(
            width: 250,
            margin: const EdgeInsets.all(20),
            child:
            RichText(
              text: TextSpan(
                style: const TextStyle(wordSpacing: 3.0,fontWeight: FontWeight.w500, color: Colors.white,),
                children: <TextSpan> [
                  TextSpan(text: ("${AppLocalizations.of(context)!.sideQuestGoToUpper} ")),
                  TextSpan(text: "${sidequest.poi!.name!} ", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                  TextSpan(text: ("${AppLocalizations.of(context)!.sideQuestScan} ")),
                  TextSpan(text: sidequest.reward!.type!),
                  TextSpan(text: (" ${AppLocalizations.of(context)!.articleToThe} ")),
                  TextSpan(text: sidequest.reward!.placeEvent!, style: TextStyle(color: Theme.of(context).iconTheme.color)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 30,
            child: Text("${AppLocalizations.of(context)!.sideQuestEventProgess} $formattedStartDate ${AppLocalizations.of(context)!.articleToThe} $formattedEndDate",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),

          //Se l'evento è stato completato e quindi si trova nelle opere scansionate
          /* Positioned(
            bottom: 12,
            left: 125,
            child: Text("Evento completato!",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w600
          ),
          ),
          ),

          Positioned(
              bottom: 8,
              left: 250,
              child: Icon(Icons.check_circle_sharp, color: Colors.green)
          ),*/
        ],
      ),
    );
  }
}