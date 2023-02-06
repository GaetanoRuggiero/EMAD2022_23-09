import 'dart:math';
import 'dart:ui';
import 'package:arts/main.dart';
import 'package:arts/ui/singletourscreen.dart';
import 'package:arts/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api/sidequest_api.dart';
import '../model/POI.dart';
import '../model/sidequest.dart';
import '../utils/user_provider.dart';

class SidequestScreen extends StatefulWidget {
  const SidequestScreen({Key? key}) : super(key: key);

  @override
  State<SidequestScreen> createState() => _SidequestScreenState();
}
//This is where the interface is created
class _SidequestScreenState extends State<SidequestScreen> {

  late Future _getSidequestFuture;
  int _selectedIndex = 0;
  final List _tabs = [
    const AvailableSidequest(sidequestList: [], visitedPOIMap: {}),
    const CompletedSidequest(sidequestList: [], visitedPOIMap: {}),
    const ExpiredSidequest(sidequestList: [])
  ];

  void _onItemTapped (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getSidequestFuture = getAllSidequest();
  }

  Future<void> updateEntry() {
    setState(() {
      _getSidequestFuture = getAllSidequest();
    });
    return _getSidequestFuture;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ],
          title: Text(AppLocalizations.of(context)!.mission),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.directions_walk_outlined),
                activeIcon: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  margin: const EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.directions_walk_outlined,
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                label: AppLocalizations.of(context)!.events
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.check_outlined),
                activeIcon: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  margin: const EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.check_outlined,
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                label: AppLocalizations.of(context)!.completed
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.block_outlined),
                activeIcon: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  margin: const EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.block_outlined,
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                label: AppLocalizations.of(context)!.expired
            )
          ],
        ),
        body: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return FutureBuilder(
                future: _getSidequestFuture,
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      List<Sidequest> sidequestList = snapshot.data;
                      List<Sidequest> availableSidequestList = [];
                      List<Sidequest> completedSidequestList = [];
                      List<Sidequest> expiredSidequestList = [];
                      Map<POI, String> visitedPOIMap = userProvider.visited;
                      var nowDate = DateTime.now().toLocal();

                      for (var sidequest in sidequestList) {
                        final startDate = DateTime.fromMillisecondsSinceEpoch(sidequest.startDate!.seconds! * 1000);
                        final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);

                        //Checking if the Sidequest is completed
                        if (visitedPOIMap.containsKey(sidequest.poi)) {
                          DateTime? lastVisited = DateTime.tryParse(visitedPOIMap[sidequest.poi]!);

                          if ((lastVisited!.isAfter(startDate)) && (lastVisited.isBefore(endDate))) {
                            completedSidequestList.add(sidequest);
                            continue;
                          }
                        }

                        //Checking if the Sidequest is expired
                        if (nowDate.compareTo(endDate) > 0) {
                          expiredSidequestList.add(sidequest);
                          continue;
                        }

                        //Return the Sidequest available
                        else {
                          availableSidequestList.add(sidequest);
                        }
                      }

                      _tabs[0] = AvailableSidequest(
                          sidequestList: availableSidequestList,
                          visitedPOIMap: visitedPOIMap);

                      _tabs[1] = CompletedSidequest(
                          sidequestList: completedSidequestList,
                          visitedPOIMap: visitedPOIMap);


                      _tabs[2]= ExpiredSidequest(sidequestList: expiredSidequestList);

                      return SafeArea(child: _tabs[_selectedIndex]);
                    }
                    else {
                      return RefreshIndicator(
                        onRefresh: updateEntry,
                        child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                                    Text(textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)), AppLocalizations.of(context)!.connectionError),
                                  ],
                                ),
                              ),
                              ListView(),
                              //Pull to refresh needs at least a scrollable list to work
                            ]
                        ),
                      );
                    }
                  }
                  else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            }
        ),
      ),
    );
  }
}


class AvailableSidequest extends StatefulWidget {
  const AvailableSidequest({Key? key, required this.sidequestList, required this.visitedPOIMap}) : super(key: key);
  final List<Sidequest> sidequestList;
  final Map<POI, String> visitedPOIMap;


  @override
  State<AvailableSidequest> createState() => _AvailableSidequestState();
}
//This is the the view of all Sidequest available
class _AvailableSidequestState extends State<AvailableSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest>? _sidequestList;
  Map<POI, String>? _visitedPOIMap;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _sidequestList = widget.sidequestList;
    _visitedPOIMap = widget.visitedPOIMap;
  }

  Future<void> updateEntry() {
    List<Sidequest>? sidequestList = [];

    return Future.delayed(Duration.zero, () async {
      sidequestList = await getAllSidequest();

      if (sidequestList != null) {

        for (var sidequest in sidequestList!) {
          final startDate = DateTime.fromMillisecondsSinceEpoch(sidequest.startDate!.seconds! * 1000);
          final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);

          //Checking if the Sidequest is completed
          if (_visitedPOIMap!.containsKey(sidequest.poi)) {
            DateTime? lastVisited = DateTime.tryParse(_visitedPOIMap![sidequest.poi]!);

            if ((lastVisited!.isAfter(startDate)) && (lastVisited.isBefore(endDate))) {
              sidequestList!.remove(sidequest);
            }
          }
        }

        //check if it's expired
        for (var sidequest in sidequestList!) {
          final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);
          var nowDate = DateTime.now().toLocal();

          //Checking if the Sidequest is expired
          if (nowDate.compareTo(endDate) > 0) {
            sidequestList!.remove(sidequest);
          }
        }

        setState(() {
          _sidequestList = sidequestList;
        });
      }
      else {
        setState(() {
          _sidequestList = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_sidequestList == null) {
      // Connection with server has failed (or timed out)
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    Text(textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                        AppLocalizations.of(context)!.connectionError
                    ),
                  ],
                ),
              ),
              ListView(), //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }

    else if (_sidequestList!.isNotEmpty){
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(
                                sigmaY: 5,
                                sigmaX: 5
                            ),
                            child: AlertDialog(
                              title: Column(
                                children: [
                                  Text("${AppLocalizations.of(context)!.itinerarySidequestQuestion}:\n", style: const TextStyle(fontFamily: 'JosefinSans')),
                                  Text(_sidequestList![index].poi!.name!, style: const TextStyle(color: lightOrange, fontFamily: 'JosefinSans')),
                                ],
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              content: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: lightOrange,
                                            blurRadius: 3,
                                            spreadRadius: 3
                                        ),
                                      ],
                                      shape: BoxShape.circle,
                                      color: Colors.red
                                  ),
                                  height: 230,
                                  width: 230,
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Image.asset("assets/animated/man_walking.gif",
                                      fit: BoxFit.scaleDown,
                                    ),
                                  )),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              actions: [
                                TextButton(
                                    child: Text(AppLocalizations.of(context)!.startItinerary),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SingleTourScreen(itinerary: [_sidequestList![index].poi!])));
                                    }
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(AppLocalizations.of(context)!.goBack))
                              ],
                            ),
                          );
                        });
                  },
                  child: SideQuestCard(sidequest: _sidequestList![index]));
            },
            itemCount: _sidequestList!.length
        ),
      );
    }

    else {
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    Text(textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)), AppLocalizations.of(context)!.emptyAvailableMission),
                  ],
                ),
              ),
              ListView(),
              //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }
  }
}



class CompletedSidequest extends StatefulWidget {
  const CompletedSidequest({Key? key, required this.sidequestList, required this.visitedPOIMap}) : super(key: key);
  final List<Sidequest> sidequestList;
  final Map<POI, String> visitedPOIMap;


  @override
  State<CompletedSidequest> createState() => _CompletedSidequestState();
}
//This is the the view of all Sidequest completed
class _CompletedSidequestState extends State<CompletedSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest>? _sidequestList;
  Map<POI, String>? _visitedPOIMap;

  @override
  void initState() {
    super.initState();
    _sidequestList = widget.sidequestList;
    _visitedPOIMap = widget.visitedPOIMap;
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> updateEntry() {
    List<Sidequest>? sidequestList = [];

    return Future.delayed(Duration.zero, () async {
      sidequestList = await getAllSidequest();
      List<Sidequest> sidequestListUpdated = [];

      if (sidequestList != null) {
        for (var sidequest in sidequestList!) {
          final startDate = DateTime.fromMillisecondsSinceEpoch(sidequest.startDate!.seconds! * 1000);
          final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);

          //Checking if the Sidequest is completed
          if (_visitedPOIMap!.containsKey(sidequest.poi)) {
            DateTime? lastVisited = DateTime.tryParse(_visitedPOIMap![sidequest.poi]!);

            if ((lastVisited!.isAfter(startDate)) && (lastVisited.isBefore(endDate))) {
              sidequestListUpdated.add(sidequest);
            }
          }
        }
        setState(() {
          _sidequestList = sidequestListUpdated;
        });
      }
      else {
        setState(() {
          _sidequestList = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_sidequestList == null) {
      // Connection with server has failed (or timed out)
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    Text(textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                        AppLocalizations.of(context)!.connectionError
                    ),
                  ],
                ),
              ),
              ListView(), //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }

    else if (_sidequestList!.isNotEmpty){
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: ListView.builder(
            itemBuilder: (context, index) {
              return SideQuestCard(sidequest: _sidequestList![index], isCompleted: true);
            },
            itemCount: _sidequestList!.length
        ),
      );
    }

    else {
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    )),
                    Center(child: Text(textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)), AppLocalizations.of(context)!.emptyCompletedMission)),
                  ],
                ),
              ),
              ListView(),
              //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }
  }
}


class ExpiredSidequest extends StatefulWidget {
  const ExpiredSidequest({Key? key, required this.sidequestList}) : super(key: key);
  final List<Sidequest> sidequestList;

  @override
  State<ExpiredSidequest> createState() => _ExpiredSidequestState();
}
//This is the the view of all Sidequest expired
class _ExpiredSidequestState extends State<ExpiredSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest>? _sidequestList;

  @override
  void initState() {
    super.initState();
    _sidequestList = widget.sidequestList;
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> updateEntry() {
    List<Sidequest>? sidequestList = [];

    return Future.delayed(Duration.zero, () async {
      sidequestList = await getAllSidequest();
      List<Sidequest> sidequestListUpdated = [];

      if (sidequestList != null) {

        for (var sidequest in sidequestList!) {
          final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);
          var nowDate = DateTime.now().toLocal();

          //Checking if the Sidequest is expired
          if (nowDate.compareTo(endDate) > 0) {
            sidequestListUpdated.add(sidequest);
          }
        }

        setState(() {
          _sidequestList = sidequestListUpdated;
        });
      }
      else {
        setState(() {
          _sidequestList = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_sidequestList == null) {
      // Connection with server has failed (or timed out)
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    Text(textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                        AppLocalizations.of(context)!.connectionError
                    ),
                  ],
                ),
              ),
              ListView(), //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }

    else if (_sidequestList!.isNotEmpty){
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: ListView.builder(
            itemBuilder: (context, index) {
              return SideQuestCard(sidequest: _sidequestList![index], isExpired: true);
            },
            itemCount: _sidequestList!.length
        ),
      );
    }

    else {
      return RefreshIndicator(
        onRefresh: updateEntry,
        child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                    )),
                    Text(textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)), AppLocalizations.of(context)!.emptyExpiredMission),
                  ],
                ),
              ),
              ListView(),
              //Pull to refresh needs at least a scrollable list to work
            ]
        ),
      );
    }
  }
}


//This is the single Sidequest Card
class SideQuestCard extends StatefulWidget {

  final bool? isExpired;
  final bool? isCompleted;

  const SideQuestCard({
    Key? key,
    required this.sidequest,
    this.isCompleted,
    this.isExpired
  }) : super(key: key);

  final Sidequest sidequest;

  @override
  State<SideQuestCard> createState() => _SideQuestCardState();
}

class _SideQuestCardState extends State<SideQuestCard> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final deviceOrientation = MediaQuery.of(context).orientation;
    final startDate = DateTime.fromMillisecondsSinceEpoch(widget.sidequest.startDate!.seconds! * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(widget.sidequest.endDate!.seconds! * 1000);
    final formattedStartDate = DateFormat("dd/MM/yyyy").format(startDate);
    final formattedEndDate = DateFormat("dd/MM/yyyy").format(endDate);

    //set the color of the Card, green if completed, grey if expired, blue if available
    List<Color> colorsCheck() {
      if (widget.isCompleted != null && widget.isCompleted!) {
        return [
          Colors.black.withOpacity(0.0),
          const Color(0xff00994d),
        ];
      }
      else if (widget.isExpired != null && widget.isExpired!) {
        return [
          Colors.black.withOpacity(0.0),
          Colors.grey.shade800,
        ];
      }
      return [
        Colors.black.withOpacity(0.0),
        const Color(0xff113197),
      ];
    }

    //set the icon of the card, checked if completed, blocked if expired, void container otherwise
    Widget expiredOrCompleted() {
      Widget pos = Container();

      if (widget.isCompleted != null && widget.isCompleted!) {
        return Positioned(
          bottom: 5.0,
          right: 15.0,
          child: Icon(Icons.check_circle_outline, size: 40, color: Colors.white.withOpacity(0.4)),
        );
      }

      if (widget.isExpired != null && widget.isExpired!) {
        return Positioned(
            bottom: 5.0,
            right: 15.0,
            child: Icon(Icons.block_outlined, color: Colors.white.withOpacity(0.4), size: 40)
        );
      }
      return pos;
    }

    //return a Red Sale Label build with the amount of the ticked with it's icon
    Widget redSaleLabel(String discountAmount, IconData showedIcon) {
      return Positioned(
        top: 15,
        right: 20,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          children: [

            Transform.rotate(
                angle: pi/2,
                child: const Icon(Icons.sell_rounded, size: 80)),

            Transform.rotate(
              angle: pi*7/4,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 50,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(showedIcon, size: 20, color: const Color(0xff993d00))),
                    ),
                    const SizedBox(height: 5),
                    Expanded(child: Text("$discountAmount%",style: const TextStyle(fontSize:13, fontStyle: FontStyle.italic, fontFamily: 'JosefinSans', color: Colors.white))),
                  ],),
              ),
            ),
          ],
        ),
      );
    }

    //set the bottom text of the card, expired if the sidequest is expired,
    // completed if the sidequest is completed, available otherwise
    Widget expiredOrCompletedBottomText() {
      Positioned pos = Positioned(
        bottom: 15,
        left: 20,
        child: Text("${AppLocalizations.of(context)!.sideQuestEventProgess} $formattedStartDate ${AppLocalizations.of(context)!.articleToThe} $formattedEndDate",
          style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: 'JosefinSans',
              fontWeight: FontWeight.w600
          ),
        ),
      );

      if (widget.isExpired != null && widget.isExpired!) {
        return Positioned(
          bottom: 15,
          left: 20,
          child: Text("${AppLocalizations.of(context)!.expiredMission} $formattedEndDate",
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'JosefinSans',
                fontWeight: FontWeight.w600
            ),
          ),
        );
      }
      else if (widget.isCompleted != null && widget.isCompleted!) {
        return Positioned(
          bottom: 15,
          left: 20,
          child: Text(AppLocalizations.of(context)!.sideQuestEventCompleted,
            style: const TextStyle(
                fontFamily: 'JosefinSans',
                color: Colors.white,
                fontWeight: FontWeight.w600
            ),
          ),
        );
      }
      return pos;
    }

    //set the icon based on the category of the sidequest
    Widget categoryReward() {

      if ((widget.sidequest.reward!.category!).compareTo(restaurant) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.restaurant_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(bakery) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.bakery_dining_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(museum) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.museum_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(theater) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.theater_comedy_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(pizzeria) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.local_pizza_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(iceCreamShop) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.icecream_outlined);
      }

      if ((widget.sidequest.reward!.category!).compareTo(sandwich) == 0) {
        return redSaleLabel(widget.sidequest.reward!.discountAmount.toString(), Icons.lunch_dining_outlined);
      }

      return Container();
    }

    return SizedBox(
      height: 180,
      child: Card(
        borderOnForeground: true,
        margin: const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 10),
        clipBehavior: Clip.antiAlias,
        elevation: 30,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        child: Stack(
          children: [

            Container(
                margin: const EdgeInsets.only(left: 70.0),
                height: 250.0,
                width: double.infinity,
                child: Image.asset(widget.sidequest.poi!.imageURL!,
                    fit: ( deviceOrientation == Orientation.portrait ? BoxFit.fitWidth : BoxFit.fitWidth))
            ),

            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: const AlignmentDirectional(3.5, 0),
                      end: const FractionalOffset(0.25, 0.25),
                      colors: colorsCheck(),
                      stops: const [
                        0.0,
                        1.0
                      ])),
            ),

            expiredOrCompleted(),

            categoryReward(),

            Container(
              width: 190,
              margin: const EdgeInsets.all(20),
              child:
              RichText(
                text: TextSpan(
                  style: const TextStyle(wordSpacing: 3.0,fontWeight: FontWeight.w500, color: Colors.white, fontFamily: "JosefinSans"),
                  children: <TextSpan> [
                    TextSpan(text: ("${AppLocalizations.of(context)!.sideQuestGoToUpper} ")),
                    TextSpan(text: "${widget.sidequest.poi!.name!} ", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                    TextSpan(text: ("${AppLocalizations.of(context)!.sideQuestScan} ")),
                    TextSpan(text: widget.sidequest.reward!.type!),
                    TextSpan(text: (" ${AppLocalizations.of(context)!.sideQuestGoToLower} ")),
                    TextSpan(text: "${widget.sidequest.reward!.placeEvent!}.", style: TextStyle(color: Theme.of(context).iconTheme.color)),
                  ],
                ),
              ),
            ),

            expiredOrCompletedBottomText(),

          ],
        ),
      ),
    );
  }
}