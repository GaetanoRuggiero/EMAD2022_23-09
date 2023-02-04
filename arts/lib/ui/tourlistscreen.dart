import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/widget_utils.dart';
import './singletourscreen.dart';
import './custom_itinerary.dart';
import '../api/itinerary_api.dart';
import '../model/itinerary.dart';

class TourListScreen extends StatefulWidget {
  const TourListScreen({Key? key}) : super(key: key);

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  late Future _itineraryListFuture;
  late Timer _timer;
  final Duration _colorChangeDuration = const Duration(seconds: 2);
  late Color _firstColor;
  late Color _secondColor;

  Route<void> _showCustomItineraryDialog(BuildContext context) {
    return MaterialPageRoute<void>(
      builder: (context) => const CustomItineraryDialog(),
      fullscreenDialog: true,
    );
  }

  void _changeRandomColor() {
    Color tempColor = _firstColor;
    setState(() {
      _firstColor = _secondColor;
      _secondColor =  tempColor;
    });
  }

  Future<void> onRefresh() async {
    setState(() {
      _itineraryListFuture = getAllItinerary();
    });
  }

  @override
  void initState() {
    super.initState();
    _itineraryListFuture = getAllItinerary();
    _timer = Timer.periodic(_colorChangeDuration, (timer) => _changeRandomColor());
    _firstColor = const Color(0xffe67300);
    _secondColor =  const Color(0xffffa04b);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.itineraryList),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
              icon: const Icon(Icons.home_rounded))
        ],
      ),

      body: Column(
        children: [
          AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 8,
                center: Alignment.topCenter,
                colors: [
                _firstColor,
                _secondColor
              ]),
              borderRadius: BorderRadius.circular(30.0),
            ),
            duration: _colorChangeDuration,
            margin: const EdgeInsets.only(top: 20.0),
            child: TextButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(AppLocalizations.of(context)!.createCustomItinerary, style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).push(_showCustomItineraryDialog(context));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0, left: 25.0, top: 20.0),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.thematicItineraries, style: const TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
          FutureBuilder(
            future: _itineraryListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var itineraryList = snapshot.data;
                if (itineraryList == null) {
                  return Expanded(child: showConnectionError(AppLocalizations.of(context)!.connectionError, onRefresh));
                }

                if (itineraryList.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: PathCard(itinerary: itineraryList[index]),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SingleTourScreen(
                                itinerary: itineraryList[index].path!,
                              )));
                          },
                        );
                      },
                      itemCount: itineraryList.length,
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
        color: Theme.of(context).colorScheme.primary,
        elevation: 0,
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
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height
                    )),
              ],
            ),

            Container(
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