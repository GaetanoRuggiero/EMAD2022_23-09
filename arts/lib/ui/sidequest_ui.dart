import '../model/sidequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../api/sidequest_api.dart';
import '../api/user_api.dart';
import '../model/POI.dart';
import '../utils/user_utils.dart';

class SidequestScreen extends StatefulWidget {
  const SidequestScreen({Key? key}) : super(key: key);

  @override
  State<SidequestScreen> createState() => _SidequestScreenState();
}
//This is where the interface is created
class _SidequestScreenState extends State<SidequestScreen> {
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
        body: const TabBarView(
          children: [
            TabAllSidequest(),
            CompletedSidequest(),
            ExpiredSidequest()
          ],
        ),
      ),
    );
  }
}




class TabAllSidequest extends StatefulWidget {
  const TabAllSidequest({Key? key}) : super(key: key);

  @override
  State<TabAllSidequest> createState() => _TabAllSidequestState();
}
//This is the the view of all Sidequest available
class _TabAllSidequestState extends State<TabAllSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest> _sideQuestList = [];
  late String? _userEmail;
  late String? _userToken;
  late Future _getVisitedFuture;
  late Future<List<dynamic>> _getSidequestAndVisited;

  @override
  bool get wantKeepAlive => true;

  Future<void> updateEntry() {
    setState(() {
      _getSidequestAndVisited = Future.wait([getAllSidequest(), getVisitedPOI(_userEmail!, _userToken!)]);
    });
    return _getSidequestAndVisited;
  }

  @override
  void initState() {
    super.initState();

    _getVisitedFuture = Future.delayed(Duration.zero, () async {
      _userEmail = await UserUtils.readEmail();
      _userToken = await UserUtils.readToken();
      return getVisitedPOI(_userEmail!, _userToken!);
    });
    _getSidequestAndVisited = Future.wait([getAllSidequest(), _getVisitedFuture]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _getSidequestAndVisited,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            List<Sidequest>? sideQuestList = snapshot.data?[0] as List<Sidequest>?;
            Map<POI, String>? visitedPOIMap = snapshot.data?[1] as Map<POI, String>?;
            var nowDate = DateTime.now().toLocal();

            if (sideQuestList == null) {
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
            _sideQuestList = sideQuestList;

            if (sideQuestList.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: updateEntry,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            final startDate = DateTime.fromMillisecondsSinceEpoch(sideQuestList[index].startDate!.seconds! * 1000);
                            final endDate = DateTime.fromMillisecondsSinceEpoch(sideQuestList[index].endDate!.seconds! * 1000);

                            //Checking if the Sidequest is completed
                            if (visitedPOIMap != null) {
                              if (visitedPOIMap.containsKey(sideQuestList[index].poi)) {
                                DateTime? lastVisited = DateTime.tryParse(visitedPOIMap[sideQuestList[index].poi]!);

                                if ((lastVisited!.isAfter(startDate)) && (lastVisited.isBefore(endDate))) {
                                  return Container();
                                }
                              }
                            }

                            //Checking if the Sidequest is expired
                            if (nowDate.compareTo(endDate) > 0) {
                              return Container();
                            }

                            //Return the Sidequest available
                            else {
                              return SideQuestCard(sidequest: _sideQuestList[index]);
                            }
                          },
                          itemCount: _sideQuestList.length
                      ),
                    ),
                  ),
                ],
              );
            }

            else {
              return RefreshIndicator(
                onRefresh: updateEntry,
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                        Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                            AppLocalizations.of(context)!.emptyMission
                        )
                      ],
                    )),
              );
            }
          }
          else {
            return const Center(child: CircularProgressIndicator());
          }
        }
    );

  }
}




class CompletedSidequest extends StatefulWidget {
  const CompletedSidequest({Key? key}) : super(key: key);

  @override
  State<CompletedSidequest> createState() => _CompletedSidequestState();
}
//This is the the view of all Sidequest completed
class _CompletedSidequestState extends State<CompletedSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest> _sideQuestList = [];
  late String? _userEmail;
  late String? _userToken;
  late Future _getVisitedFuture;
  late Future<List<dynamic>> _getSidequestAndVisited;

  @override
  bool get wantKeepAlive => true;

  Future<void> updateEntry() {
    setState(() {
      _getSidequestAndVisited = Future.wait([getAllSidequest(), getVisitedPOI(_userEmail!, _userToken!)]);
    });
    return _getSidequestAndVisited;
  }

  @override
  void initState() {
    super.initState();

    _getVisitedFuture = Future.delayed(Duration.zero, () async {
      _userEmail = await UserUtils.readEmail();
      _userToken = await UserUtils.readToken();
      return getVisitedPOI(_userEmail!, _userToken!);
    });
    _getSidequestAndVisited = Future.wait([getAllSidequest(), _getVisitedFuture]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _getSidequestAndVisited,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            List<Sidequest>? sideQuestList = snapshot.data?[0] as List<Sidequest>?;
            Map<POI, String>? visitedPOIMap = snapshot.data?[1] as Map<POI, String>?;

            if (sideQuestList == null) {
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
            _sideQuestList = sideQuestList;

            if (sideQuestList.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: updateEntry,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            final startDate = DateTime
                                .fromMillisecondsSinceEpoch(sideQuestList[index]
                                .startDate!.seconds! * 1000);
                            final endDate = DateTime.fromMillisecondsSinceEpoch(
                                sideQuestList[index].endDate!.seconds! * 1000);

                            //Checking if the Sidequest is completed
                            if (visitedPOIMap != null) {
                              if (visitedPOIMap.containsKey(
                                  sideQuestList[index].poi)) {
                                DateTime? lastVisited = DateTime.tryParse(
                                    visitedPOIMap[sideQuestList[index].poi]!);

                                if ((lastVisited!.isAfter(startDate)) &&
                                    (lastVisited.isBefore(endDate))) {
                                  return SideQuestCard(
                                      sidequest: sideQuestList[index],
                                      isCompleted: true);
                                }
                              }
                            }
                            return Container();
                          },
                          itemCount: _sideQuestList.length
                      ),
                    ),
                  ),
                ],
              );
            }

            else {
              return RefreshIndicator(
                onRefresh: updateEntry,
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                        Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                            AppLocalizations.of(context)!.emptyMission
                        )
                      ],
                    )),
              );
            }
          }
          else {
            return const Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}




class ExpiredSidequest extends StatefulWidget {
  const ExpiredSidequest({Key? key}) : super(key: key);

  @override
  State<ExpiredSidequest> createState() => _ExpiredSidequestState();
}
//This is the the view of all Sidequest expired
class _ExpiredSidequestState extends State<ExpiredSidequest> with AutomaticKeepAliveClientMixin {

  List<Sidequest> _sideQuestList = [];
  late String? _userEmail;
  late String? _userToken;
  late Future _getVisitedFuture;
  late Future<List<dynamic>> _getSidequestAndVisited;

  @override
  bool get wantKeepAlive => true;

  Future<void> updateEntry() {
    setState(() {
      _getSidequestAndVisited = Future.wait([getAllSidequest(), getVisitedPOI(_userEmail!, _userToken!)]);
    });
    return _getSidequestAndVisited;
  }

  @override
  void initState() {
    super.initState();

    _getVisitedFuture = Future.delayed(Duration.zero, () async {
      _userEmail = await UserUtils.readEmail();
      _userToken = await UserUtils.readToken();
      return getVisitedPOI(_userEmail!, _userToken!);
    });
    _getSidequestAndVisited = Future.wait([getAllSidequest(), _getVisitedFuture]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: _getSidequestAndVisited,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            List<Sidequest>? sideQuestList = snapshot.data?[0] as List<Sidequest>?;
            var nowDate = DateTime.now().toLocal();

            if (sideQuestList == null) {
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
            _sideQuestList = sideQuestList;

            if (sideQuestList.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: updateEntry,
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            final endDate = DateTime.fromMillisecondsSinceEpoch(sideQuestList[index].endDate!.seconds! * 1000);

                            //Checking if the Sidequest is expired
                            if (nowDate.compareTo(endDate) > 0) {
                              return SideQuestCard(sidequest: sideQuestList[index], isExpired: true);
                            }

                            return Container();
                          },
                          itemCount: _sideQuestList.length
                      ),
                    ),
                  ),
                ],
              );
            }
            else {
              return RefreshIndicator(
                onRefresh: updateEntry,
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                        Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                            AppLocalizations.of(context)!.thereAreNoExpiredMission
                        )
                      ],
                    )),
              );
            }
          }
          else {
            return const Center(child: CircularProgressIndicator());
          }
        }
    );
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
                  fit: ( deviceOrientation == Orientation.portrait ? BoxFit.fitHeight : BoxFit.fitWidth))
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