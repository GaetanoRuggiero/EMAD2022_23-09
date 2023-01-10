import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../exception/exceptions.dart';
import './singlepoiview.dart';
import '../utils/debouncer.dart';
import '../api/poi_api.dart';
import '../api/user_api.dart';
import '../model/POI.dart';

enum SearchFilter { city, name }

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
            title: Text(AppLocalizations.of(context)!.collectionTitle),
            bottom: TabBar(
              tabs: [
                Tab(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(FontAwesomeIcons.bookBookmark, size: 22),
                    ),
                    Text(AppLocalizations.of(context)!.visitedTabTitle),
                  ],
                )),
                Tab(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(FontAwesomeIcons.book, size: 22),
                    ),
                    Text(AppLocalizations.of(context)!.toVisitTabTitle),
                  ],
                )),
                Tab(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(Icons.search, size: 22),
                    ),
                    Text(AppLocalizations.of(context)!.searchTabTitle),
                  ],
                )),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // Visited - First tab
              VisitedTabView(),
              // To Visit - Second tab
              ToVisitTabView(),
              // Search - Third tab
              SearchTabView()
            ],
          ),
        ),
      ),
    );
  }
}

class VisitedTabView extends StatefulWidget {
  const VisitedTabView({Key? key}) : super(key: key);

  @override
  State<VisitedTabView> createState() => _VisitedTabViewState();
}

class _VisitedTabViewState extends State<VisitedTabView> with AutomaticKeepAliveClientMixin<VisitedTabView> {
  Map<POI, String> _visitedPOIMap = {};
  late Future _visitedPOIFuture;

  @override
  void initState() {
    super.initState();

    /* The first time we load this widget we get visited POI's by using
    *  Provider/Consumer, so for now we give an empty map as value to this
    *  future. This future is useful when the user wants to refresh the widget.
    *  Only in that case we make calls to database.*/
    _visitedPOIFuture = Future.value(<POI, String>{});
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> refreshTab() async {
      String? email = await UserUtils.readEmail();
      String? token = await UserUtils.readToken();
      if (email != null && token != null) {
        try {
          _visitedPOIMap = await getVisitedPOI(email, token);
          setState(() {
            _visitedPOIFuture = Future.value(_visitedPOIMap);
          });
        } on ConnectionErrorException catch(e) {
          debugPrint(e.cause);
          setState(() {
            _visitedPOIFuture = Future.value();
          });
        }
      }
      return _visitedPOIFuture;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return FutureBuilder(
          future: _visitedPOIFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                _visitedPOIMap = snapshot.data;
                // If the user has collected a new POI we update the provider's value
                if (_visitedPOIMap.length > userProvider.visited.length) {
                  userProvider.visited = _visitedPOIMap;
                }
                if (userProvider.visited.isNotEmpty) {
                  // Showing visited POI in a grid
                  return RefreshIndicator(
                    onRefresh: refreshTab,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      padding: const EdgeInsets.all(10),
                      childAspectRatio: 1,
                      children: userProvider.visited.keys.map((poi) {
                        return InkWell(
                          child: _GridPOIItem(poi: poi),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SinglePOIView(poi: poi)),
                            );
                          },
                        );
                      }).toList()
                    ),
                  );
                }
                else {
                  // No POI visited yet
                  return RefreshIndicator(
                    onRefresh: refreshTab,
                    child: Stack(
                        children: [
                          Center(
                            child: Text(AppLocalizations.of(context)!.zeroPOIVisited),
                          ),
                          ListView(), //Pull to refresh needs at least a scrollable list to work
                        ]
                    ),
                  );
                }
              }
              else {
                // Connection with server has failed (or timed out)
                return RefreshIndicator(
                  onRefresh: refreshTab,
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
            }
            else {
              // Showing a loading screen until future is complete
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(AppLocalizations.of(context)!.loading),
                        ),
                      ]
                  )
              );
            }
          },
        );
      },
    );
  }
}

class ToVisitTabView extends StatefulWidget {
  const ToVisitTabView({Key? key}) : super(key: key);

  @override
  State<ToVisitTabView> createState() => _ToVisitTabViewState();
}

class _ToVisitTabViewState extends State<ToVisitTabView> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(10),
        childAspectRatio: 1,
        children: const []);
  }
}

class SearchTabView extends StatefulWidget {
  const SearchTabView({Key? key}) : super(key: key);

  @override
  State<SearchTabView> createState() => _SearchTabViewState();
}

class _SearchTabViewState extends State<SearchTabView> with AutomaticKeepAliveClientMixin<SearchTabView> {
  final _searchTextController = TextEditingController();
  String _searchText = '';
  SearchFilter? _searchFilter = SearchFilter.city;
  late List<POI> _filteredList = [];
  bool _showError = false;
  bool _showLoading = true;
  bool _noResultsFound = false;
  bool _showCancelButton = false;
  final _debouncer = Debouncer(milliseconds: 500);

  Widget showGridSearchResults() {
    if (_searchText.isEmpty) {
      return Container();
    }
    if (_showLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_showError) {
      return Container(padding: const EdgeInsets.all(10.0), child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
          Text(textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
              AppLocalizations.of(context)!.connectionError
          )
        ],
      ));
    }
    if (_noResultsFound) {
      return Center(child: Text(style: const TextStyle(fontSize: 20), "${AppLocalizations.of(context)!.resultsNotFound}\"$_searchText\""));
    }

    /* Show results in a grid */
    return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20),
        childAspectRatio: 1,
        children: _filteredList.map((poi) {
          return InkWell(
            child: _GridPOIItem(poi: poi),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SinglePOIView(poi: poi)),
              );
            },
          );
        }).toList());
  }

  Widget radioButtonFilter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(AppLocalizations.of(context)!.city),
        Radio<SearchFilter>(
          value: SearchFilter.city,
          groupValue: _searchFilter,
          onChanged: (SearchFilter? value) {
            setState(() {
              _searchFilter = value;
            });
          },
        ),
        Text(AppLocalizations.of(context)!.poiName),
        Radio<SearchFilter>(
          value: SearchFilter.name,
          groupValue: _searchFilter,
          onChanged: (SearchFilter? value) {
            setState(() {
              _searchFilter = value;
            });
          },
        ),
      ],
    );
  }

  void resetSearchUI() {
    debugPrint("No input given. UI is clear.");
    setState(() {
      _searchTextController.clear();
      _searchText = '';
      _filteredList = [];
      _showError = false;
      _showLoading = false;
      _showCancelButton = false;
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      Center(child: radioButtonFilter()),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: TextField(
          controller: _searchTextController,
          onChanged: (String text) {
            if (text.isNotEmpty) {
              setState(() {
                _showCancelButton = true;
              });
            }
            _debouncer.run(() async {
              /* The second condition blocks the call of onChanged even when
            the focus of TextField is loss (e.g when the back button is pressed to hide keyboard). */
              if (text.length >= 3 && text != _searchText) {
                _searchText = _searchTextController.text;
                if (_filteredList.isEmpty) {
                  debugPrint("Loading...");
                  setState(() {
                    _showLoading = true;
                    _showError = false;
                  });
                }

                List<POI> newFilteredList = [];
                try {
                  if (_searchFilter == SearchFilter.city) {
                    newFilteredList = await getPOIListByCity(text);
                  }
                  else {
                    newFilteredList = await getPOIListByNameKeywords(text);
                  }
                } on ConnectionErrorException catch(e) {
                  debugPrint(e.cause);
                  setState(() {
                    _showLoading = false;
                    _showError = true;
                  });
                }
                if (newFilteredList.isNotEmpty) {
                  /* Server responded successfully, we turn off all the flags. */
                  debugPrint("Ready! Showing results.");
                  setState(() {
                    _filteredList = newFilteredList;
                    _showLoading = false;
                    _showError = false;
                    _noResultsFound = false;
                  });
                }
                else {
                  /* No results found. */
                  debugPrint("No results found for: $_searchText");
                  setState(() {
                    _noResultsFound = true;
                    _showLoading = false;
                    _showError = false;
                  });
                }
              }
              else if (text.isEmpty && _searchText.isNotEmpty) {
                /* Reset UI. The user has cleaned the TextField */
                resetSearchUI();
              }
              else { return; }
            });
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            fillColor: Theme.of(context).dialogBackgroundColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            hintText: AppLocalizations.of(context)!.searchHint,
            prefixIcon: const Icon(Icons.search, color: darkOrange),
            suffixIcon: _showCancelButton
                ? IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      resetSearchUI();
                    },)
                : null
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      Expanded(
          child: showGridSearchResults()
          )
    ]);
  }
}

/// Allow the text size to shrink to fit in the space
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

class _GridPOIItem extends StatelessWidget {
  static const thumbnailName = "thumbnail.jpg";

  const _GridPOIItem({
    Key? key,
    required this.poi,
  }) : super(key: key);

  final POI poi;

  @override
  Widget build(BuildContext context) {
    /* Example:
     - assets/poi_images/0_0.jpg is replaced with
     - assets/poi_images/0_thumbnail.jpg */
    String thumbnailURL = poi.imageURL!
        .replaceRange(poi.imageURL!.lastIndexOf('_') + 1, null, thumbnailName);

    final Widget image = Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(thumbnailURL, fit: BoxFit.cover));

    return GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black45,
          title: _GridTitleText(poi.name!),
          subtitle: _GridTitleText(poi.city!),
        ),
      ),
      child: image,
    );
  }
}