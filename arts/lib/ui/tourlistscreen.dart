import 'dart:async';
import 'package:arts/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/user_provider.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.only(top: 30),
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
              child: TextButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(AppLocalizations.of(context)!.createCustomItinerary, style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).push(_showCustomItineraryDialog(context));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text("${AppLocalizations.of(context)!.checkoutThematicItineraries}:"),
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
                          return PathCard(itinerary: itineraryList[index]);
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
      ),
    );
  }
}

class PathCard extends StatefulWidget {

  final Itinerary itinerary;

  const PathCard({
    Key? key,
    required this.itinerary,
  }) : super(key: key);

  @override
  State<PathCard> createState() => _PathCardState();
}

class _PathCardState extends State<PathCard> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            color: Colors.grey,
            elevation: 1.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      active = !active;
                    });
                  },
                  child: CarouselSlider.builder(
                    itemCount: widget.itinerary.path!.length,
                    itemBuilder: (context, index, realIndex) {
                      List<String?> images = [];
                      for (int i = 0 ; i<widget.itinerary.path!.length; i++) {
                        images.add(widget.itinerary.path![i].imageURL);
                      }
                      return buildImage(images, index);
                    },
                    options: CarouselOptions(
                      height: 250,
                    )
                  ),
                ),
                ExpansionPanelList(
                  expansionCallback: (panelIndex, isExpanded) {
                    setState(() {
                      active = !active;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              child: Text(AppLocalizations.of(context)!.viewAllSteps),
                            ),
                          ],
                        );
                      },
                      body: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widget.itinerary.path!.map((poi) {
                              Locale currentLocale = Localizations.localeOf(context);
                              String name = poi.nameEn!;
                              if (currentLocale.languageCode == "it") {
                                name = poi.name!;
                              }
                              Color markerColor = Colors.orange;
                              if (userProvider.visited.containsKey(poi)) {
                                markerColor = Colors.green;
                              }
                              String? lastVisited;
                              String? dateVisited, hourVisited;
                              if (userProvider.visited[poi] != null) {
                                lastVisited = lastVisited = userProvider.visited[poi]!;
                                if (currentLocale.languageCode == "en") {
                                  dateVisited = DateFormat('yyyy LLLL dd', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
                                  hourVisited = DateFormat('h:mm a', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
                                } else {
                                  dateVisited = DateFormat('dd LLLL yyyy', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
                                  hourVisited = DateFormat('HH:mm', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
                                }
                              }
                              return Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                showDuration: const Duration(seconds: 2),
                                message: dateVisited != null ? "${AppLocalizations.of(context)!.lastVisited} $dateVisited ${AppLocalizations.of(context)!.hourVisited} $hourVisited" : AppLocalizations.of(context)!.notVisitedYet,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0, bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_rounded, size: 18, color: markerColor,),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(name),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                      ),
                      isExpanded: active,
                      canTapOnHeader: true
                    )
                  ],
                ),
              ],
            )
          ),
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4,
                      color: Colors.black12.withOpacity(.2),
                      offset: const Offset(2, 2))
                ],
                gradient: const LinearGradient(
                    colors: [lightOrange, darkOrange]),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: IconButton(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SingleTourScreen(itinerary: widget.itinerary.path!)));
                  }),
            ),
          ),
        ],
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