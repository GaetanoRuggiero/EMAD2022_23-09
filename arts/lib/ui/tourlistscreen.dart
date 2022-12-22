import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TourListScreen extends StatelessWidget {
  const TourListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.itineraryList),
        actions: <Widget>[
          IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
              icon: const Icon(Icons.home_rounded,))
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.green.shade300,
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.location_on)),
                Text(AppLocalizations.of(context)!.deviceLocationAvailable),
              ],
            ),
          ),

          const SizedBox(height: 10.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.recommendedItinerary, style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),

          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child:  const PathCard(
              endPOI: "endPOI",
              lengthPath: "15km",
              startPOI: "startPOI",
              image: "https://images.unsplash.com/photo-1581416271248-213a4f928597?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=735&q=80",
            ),
          ),

          const PathCardDivider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.thematicItineraries, style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),

          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child:  const PathCard(
              endPOI: "ENDpoi",
              lengthPath: "16km",
              startPOI: "STARTpoi",
              image: "https://images.unsplash.com/photo-1655303717503-c6ab284d7b69?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80",
            ),
          ),

          const SizedBox(height: 10.0),

          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child:  const PathCard(
              endPOI: "ENDpoi",
              lengthPath: "19km",
              startPOI: "STARTpoi",
              image: "https://images.unsplash.com/photo-1571075051578-c8cd15385f46?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80",
            ),
          ),
        ],
      ),
    );
  }
}

class PathCard extends StatelessWidget {

  final String image;
  final String startPOI, endPOI, lengthPath;

  const PathCard({
    Key? key,
    required this.image,
    required this.startPOI,
    required this.endPOI,
    required this.lengthPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(

      elevation: 2.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [

          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadiusDirectional.only(topStart: Radius.circular(20), topEnd: Radius.circular(20)),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.fitWidth,
              ),
            ),
            width: double.infinity,
          ),

          Container(
            padding: const EdgeInsets.only(top:10.0,bottom:10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Inizio: $startPOI"),
                  Text("Fine: $endPOI"),
                  Text("Lunghezza: $lengthPath"),
                ]
            ),
          ),
        ],
      ),
    );
  }
}

class PathCardDivider extends StatelessWidget {
  const PathCardDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 20,
      thickness: 1.5,
      indent:20,
      endIndent: 20,
    );
  }
}