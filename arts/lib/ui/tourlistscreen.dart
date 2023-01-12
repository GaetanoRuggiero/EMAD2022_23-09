import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/itinerary_api.dart';
import '../model/itinerary.dart';
import '../ui/singletourscreen.dart';
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
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
              icon: const Icon(Icons.home_rounded,))
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 25.0),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.recommendedItinerary, style: const TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
          const PathCardDivider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 25.0),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.thematicItineraries, style: const TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
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
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: PathCard(itinerary: _itineraryList[index]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SingleTourScreen(
                                itinerary: _itineraryList[index],
                              )));
                          },
                        );
                      },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        elevation: 4.0,
        clipBehavior: Clip.antiAlias,
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
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: true,
                      autoPlayCurve: Curves.easeInOut,
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height
                    )),
              ],
            ),

            Container(
              color: Theme.of(context).appBarTheme.backgroundColor,
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [

                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                            children: <TextSpan> [
                              TextSpan(text: (("${AppLocalizations.of(context)!.itineraryStart} ")), style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: (itinerary.path![0].name!)),
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
                              TextSpan(text: (("${AppLocalizations.of(context)!.itineraryEnd} ")), style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: (itinerary.path![itinerary.path!.length-1].name!)),
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
                              TextSpan(text: (("${AppLocalizations.of(context)!.length} ")), style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: ("${itinerary.length}${AppLocalizations.of(context)!.km}")),
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
      height: 40,
      thickness: 0.5,
      indent: 25,
      endIndent: 25,
    );
  }
}

Widget buildImage (List<String?> urlImage, int index) {
  return Container(
    height: 300,
    width: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage(urlImage[index]!),
          fit: BoxFit.cover),
    ),
  );
}