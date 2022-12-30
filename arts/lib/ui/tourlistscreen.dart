import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/itinerary_api.dart';
import '../model/itinerary.dart';
import 'package:carousel_slider/carousel_slider.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({Key? key}) : super(key: key);

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {

  List<Itinerary> _itineraryList = [];

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

      body: Column(
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

          const PathCardDivider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.thematicItineraries, style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),

          FutureBuilder(
            future: getAllItinerary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var itineraryList = snapshot.data;
                if (itineraryList == null){

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

                _itineraryList = itineraryList;
                if (itineraryList.isNotEmpty) {
                  return Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return PathCard(itinerary: _itineraryList[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) {return const PathCardDivider();},
                      itemCount: _itineraryList.length,
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
                          AppLocalizations.of(context)!.emptyItinerary
                      )
                    ],
                  ));
                }
              }

              else {
                return const Center(child: CircularProgressIndicator());
              }

            },
          ),
        ],
      ),
    );
  }
}

class PathCard extends StatelessWidget {

  final Itinerary itinerary;

  const PathCard({
    Key? key,
    required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).unselectedWidgetColor,
      elevation: 2.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CarouselSlider.builder(
                  itemCount: itinerary.path!.length,
                  itemBuilder: (context, index, realIndex) {
                    List<String?> images = [];
                    for (int i = 0 ; i<itinerary.path!.length; i++) {
                      images.add(itinerary.path![i].imageURL);
                    }
                    return buildImage(images, index);
                  },
                  options: CarouselOptions(height: 400)),
              //const SizedBox(height: 10),
            ],
          ),

          Container(
            color: Theme.of(context).toggleableActiveColor,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [

                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          children: <TextSpan> [
                            TextSpan(text: (("${AppLocalizations.of(context)!.itineraryStart} ")), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: (itinerary.path![0].name!), style: const TextStyle(color: Colors.black)),
                          ]
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          children: <TextSpan> [
                            TextSpan(text: (("${AppLocalizations.of(context)!.itineraryEnd} ")), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: (itinerary.path![itinerary.path!.length-1].name!), style: const TextStyle(color: Colors.black)),
                          ]
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          children: <TextSpan> [
                            TextSpan(text: (("${AppLocalizations.of(context)!.length} ")), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: ("${itinerary.length}${AppLocalizations.of(context)!.km}"), style: const TextStyle(color: Colors.black)),
                          ]
                      ),
                    ),
                  ],
                ),
              ],
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
    return Divider(
      color: Theme.of(context).dividerColor,
      height: 30,
      thickness: 2,
      indent:45,
      endIndent: 45,
    );
  }
}

Widget buildImage (List<String?> urlImage, int index) {
  return Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(20), topEnd: Radius.circular(20)),
      image: DecorationImage(
          image: AssetImage(urlImage[index]!),
          fit: BoxFit.cover),
    ),
  );
}