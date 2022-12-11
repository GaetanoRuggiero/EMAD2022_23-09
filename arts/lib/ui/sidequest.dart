import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SideQuest extends StatefulWidget {
  const SideQuest({Key? key}) : super(key: key);

  @override
  State<SideQuest> createState() => _SideQuestState();
}

class _SideQuestState extends State<SideQuest> {
  @override
  Widget build(BuildContext context) {

    final deviceOrientation = MediaQuery.of(context).orientation;

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

      body: ListView(
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


          deviceOrientation == Orientation.portrait
              ?
          SideQuestCard(
            poi: "Piazza del Plebiscito ",
            startDate: "05/11/2022",
            endDate: "05/12/2022",
            place: " Museo Nazionale!",
            reward: "un biglietto gratuito",
            image: Image.network("https://images.unsplash.com/photo-1655303717503-c6ab284d7b69?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
                fit: BoxFit.fitHeight),
          )

              :

          //const SizedBox(height: 10),
          SideQuestCard(
            poi: "Castel Nuovo ",
            startDate: "06/02/2023",
            endDate: "06/03/2023",
            place: "Museo Nazionale!",
            reward: "un codice sconto",
            image: Image.network("https://images.unsplash.com/photo-1571075051578-c8cd15385f46?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80",
                fit: BoxFit.fitWidth),
          ),
        ],
      ),
    );
  }
}

class SideQuestCard extends StatelessWidget {

  final String poi, reward, place, startDate, endDate;
  final Image image;

  const SideQuestCard({
    Key? key,
    required this.poi,
    required this.reward,
    required this.place,
    required this.startDate,
    required this.endDate,
    required this.image
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: image),

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
                  TextSpan(text: (AppLocalizations.of(context)!.sideQuestGoToUpper)),
                  TextSpan(text: poi , style: const TextStyle(color: Color(0xffE68532))),
                  TextSpan(text: (AppLocalizations.of(context)!.sideQuestScan)),
                  TextSpan(text: reward),
                  TextSpan(text: (AppLocalizations.of(context)!.articleToThe)),
                  TextSpan(text: place, style: const TextStyle(color: Color(0xffE68532)),),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 30,
            child: Text(AppLocalizations.of(context)!.sideQuestEventProgess + startDate + AppLocalizations.of(context)!.articleToThe + endDate,
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