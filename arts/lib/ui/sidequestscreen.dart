import 'package:provider/provider.dart';
import '../model/sidequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../api/sidequest_api.dart';
import '../model/POI.dart';
import '../utils/user_provider.dart';

class SidequestScreen extends StatefulWidget {
  const SidequestScreen({Key? key}) : super(key: key);

  @override
  State<SidequestScreen> createState() => _SidequestScreenState();
}
//This is where the interface is created
class _SidequestScreenState extends State<SidequestScreen> {

  late Future _getSidequestFuture;

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
          bottom: TabBar(
            tabs: [
              Tab(child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(Icons.directions_walk_outlined, size: 22),
                  ),
                  Text(AppLocalizations.of(context)!.available),
                ],
              )),
              Tab(child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Icon(Icons.done_outlined, size: 22),
                  ),
                  Text(AppLocalizations.of(context)!.completed),
                ],
              )),
              Tab(child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 5),
                    child: Icon(Icons.block, size: 22),
                  ),
                  Text(AppLocalizations.of(context)!.expired),
                ],
              )),
            ],
          ),
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
                      debugPrint("NowDate: $nowDate");

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

                      return TabBarView(
                        children: [
                          AvailableSidequest(
                              sidequestList: availableSidequestList),

                          CompletedSidequest(
                              sidequestList: completedSidequestList,
                              visitedPOIMap: visitedPOIMap
                          ),

                          ExpiredSidequest(sidequestList: expiredSidequestList)
                        ],
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
  const AvailableSidequest({Key? key, required this.sidequestList}) : super(key: key);
  final List<Sidequest> sidequestList;

  @override
  State<AvailableSidequest> createState() => _AvailableSidequestState();
}
//This is the the view of all Sidequest available
class _AvailableSidequestState extends State<AvailableSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest>? _sidequestList;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _sidequestList = widget.sidequestList;
  }

  Future<void> updateEntry() {
    List<Sidequest>? sidequestList = [];

    return Future.delayed(Duration.zero, () async {
      sidequestList = await getAllSidequest();

      if (sidequestList != null) {
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
              return SideQuestCard(sidequest: _sidequestList![index]);
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
                    const Icon(Icons.android_outlined, size: 64.0, color: Color(0xFFE68532)),
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
                    const Icon(Icons.android_outlined, size: 64.0, color: Color(0xFFE68532)),
                    Text(textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)), AppLocalizations.of(context)!.emptyCompletedMission),
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
                    const Icon(Icons.android_outlined, size: 64.0, color: Color(0xFFE68532)),
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
class SideQuestCard extends StatelessWidget {

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
  Widget build(BuildContext context) {

    final deviceOrientation = MediaQuery.of(context).orientation;
    final startDate = DateTime.fromMillisecondsSinceEpoch(sidequest.startDate!.seconds! * 1000);
    final endDate = DateTime.fromMillisecondsSinceEpoch(sidequest.endDate!.seconds! * 1000);
    final formattedStartDate = DateFormat("dd/MM/yyyy").format(startDate);
    final formattedEndDate = DateFormat("dd/MM/yyyy").format(endDate);

    //set the color of the Card, green if completed, grey if expired, blue if available
    List<Color> colorsCheck() {
      if (isCompleted != null && isCompleted!) {
        return [
          Colors.black.withOpacity(0.0),
          const Color(0xff00994d),
        ];
      }
      else if (isExpired != null && isExpired!) {
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

      if (isCompleted != null && isCompleted!) {
        return Positioned(
          bottom: 5.0,
          right: 5.0,
          child: Icon(Icons.check_circle_outline, size: 80, color: Colors.white.withOpacity(0.4)),
        );
      }

      if (isExpired != null && isExpired!) {
        return Positioned(
            bottom: 5.0,
            right: 5.0,
            child: Icon(Icons.block_outlined, color: Colors.white.withOpacity(0.4), size: 80)
        );
      }
      return pos;
    }

    //set the bottom text of the card, expired if the sidequest is expired,
    // completed if the sidequest is completed, available otherwise
    Widget expiredOrCompletedBottomText() {
      Positioned pos = Positioned(
        bottom: 15,
        left: 20,
        child: Text("${AppLocalizations.of(context)!.sideQuestEventProgess} $formattedStartDate ${AppLocalizations.of(context)!.articleToThe} $formattedEndDate",
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600
          ),
        ),
      );

      if (isExpired != null && isExpired!) {
        return Positioned(
          bottom: 15,
          left: 20,
          child: Text("${AppLocalizations.of(context)!.expiredMission} $formattedEndDate",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600
            ),
          ),
        );
      }
      else if (isCompleted != null && isCompleted!) {
        return Positioned(
          bottom: 15,
          left: 20,
          child: Text(AppLocalizations.of(context)!.sideQuestEventCompleted,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600
            ),
          ),
        );
      }
      return pos;
    }

    return Card(
      margin: const EdgeInsets.only(right: 15, left: 15, top: 10, bottom: 10),
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Stack(
        children: [

          Container(
              margin: const EdgeInsets.only(left: 70.0),
              height: 250.0,
              width: double.infinity,
              child: Image.network(sidequest.reward!.poster!,
                  fit: ( deviceOrientation == Orientation.portrait ? BoxFit.cover : BoxFit.fitWidth))
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
                  TextSpan(text: (" ${AppLocalizations.of(context)!.sideQuestGoToLower} ")),
                  TextSpan(text: sidequest.reward!.placeEvent!, style: TextStyle(color: Theme.of(context).iconTheme.color)),
                ],
              ),
            ),
          ),

          expiredOrCompletedBottomText(),

        ],
      ),
    );
  }
}