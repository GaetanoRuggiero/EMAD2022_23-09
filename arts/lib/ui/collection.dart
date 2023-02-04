import 'package:arts/ui/styles.dart';
import 'package:arts/utils/widget_utils.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import './singlepoiview.dart';
import '../api/poi_api.dart';
import '../api/user_api.dart';
import '../exception/exceptions.dart';
import '../model/POI.dart';
import '../utils/debouncer.dart';

enum SearchFilter { city, name }

const thumbnailName = "thumbnail.jpg";

String getCountryEmoji(String country) {
  String emoji = '❔';
  switch (country) {
    case 'Italia' : return '🇮🇹';
    case 'Francia' : return '🇫🇷';
    case 'Germania': return '🇩🇪';
    case 'Regno Unito' : return '🇬🇧';
    default: return emoji;
  }
}

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _selectedIndex = 0;
  final List _tabs = [const VisitedTabView(), const SearchTabView()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          actions: [
            IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.collections),
              activeIcon: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(20)
                ),
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                margin: const EdgeInsets.only(bottom: 3),
                child: Icon(
                  Icons.collections,
                  color: Theme.of(context).canvasColor,
                ),
              ),
              label: AppLocalizations.of(context)!.collectionBottomBarTitle,
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.search),
                activeIcon: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  margin: const EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).canvasColor,
                  ),
                ),
                label: AppLocalizations.of(context)!.searchTabTitle
            ),
          ],
        ),
        body: SafeArea(
          child: _tabs[_selectedIndex]
        )
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                          child: Text(AppLocalizations.of(context)!.collectionTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              POI poi = userProvider.visited.keys.elementAt(index);
                              String name = poi.name!;
                              String thumbnailURL = poi.imageURL!
                                  .replaceRange(poi.imageURL!.lastIndexOf('_') + 1, null, thumbnailName);
                              if (Localizations.localeOf(context).languageCode == "en") {
                                name = poi.nameEn!;
                              }
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SinglePOIView(poi: poi, sidequest: null)),
                                  );
                                },
                                title: Text(name),
                                subtitle: Text("${poi.city}, ${poi.region}"),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(color: darkOrange, blurRadius: 0, spreadRadius: 2)
                                    ],
                                    shape: BoxShape.circle
                                  ),
                                  child: Image.asset(thumbnailURL, fit: BoxFit.cover)),
                                trailing: Text(getCountryEmoji(poi.country!)),
                              );
                            },
                            itemCount: userProvider.visited.length,
                          ),
                        ),
                      ],
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
                return showConnectionError(AppLocalizations.of(context)!.connectionError, () => refreshTab());
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

class SearchTabView extends StatefulWidget {
  const SearchTabView({Key? key}) : super(key: key);

  @override
  State<SearchTabView> createState() => _SearchTabViewState();
}

class _SearchTabViewState extends State<SearchTabView> with AutomaticKeepAliveClientMixin<SearchTabView> {
  final _searchTextController = TextEditingController();
  String _searchText = '';
  SearchFilter? _searchFilter = SearchFilter.name;
  int _filterSelected = 0;
  late List<POI> _filteredList = [];
  bool _showError = false;
  bool _showLoading = true;
  bool _noResultsFound = false;
  bool _showCancelButton = false;
  final _debouncer = Debouncer(milliseconds: 400);

  Widget showListSearchResults(BuildContext context) {
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

    /* Show results in a listview */
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ListView.builder(
          itemBuilder: (context, index) {
            POI poi = _filteredList[index];
            String name = poi.name!;
            String thumbnailURL = poi.imageURL!
                .replaceRange(poi.imageURL!.lastIndexOf('_') + 1, null, thumbnailName);
            if (Localizations.localeOf(context).languageCode == "en") {
              name = poi.nameEn!;
            }
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SinglePOIView(poi: poi, sidequest: null)),
                );
              },
              title: Text(name),
              subtitle: Text("${poi.city}, ${poi.region}"),
              leading: Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      boxShadow: userProvider.visited.containsKey(poi) ? [const BoxShadow(color: darkOrange, blurRadius: 1, spreadRadius: 2)] : [],
                      shape: BoxShape.circle
                  ),
                  child: userProvider.visited.containsKey(poi)
                  ? Image.asset(thumbnailURL, fit: BoxFit.cover)
                  : Image.asset(thumbnailURL, color: Colors.grey, colorBlendMode: BlendMode.color, fit: BoxFit.cover)
              ),
              trailing: Text(getCountryEmoji(poi.country!)),
            );
          },
          itemCount: _filteredList.length,
        );
      },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Text(AppLocalizations.of(context)!.searchAmongAllPOI, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
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
                    _filteredList = [];
                  });
                  return;
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
                    _filteredList = [];
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
            labelText: _filterSelected == 0 ? AppLocalizations.of(context)!.searchByLandmarkHint : AppLocalizations.of(context)!.searchByCityHint,
            prefixIcon: const Icon(Icons.search, color: darkOrange),
            suffixIcon: _showCancelButton
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      resetSearchUI();
                    },)
                : null,
          ),
        ),
      ),
      Center(
        child: Wrap(
          children: [
            ChoiceChip(
              labelPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              label: Container(
                constraints: const BoxConstraints(
                  minWidth: 60
                ),
                child: Text(AppLocalizations.of(context)!.poiName, style: TextStyle(color: _filterSelected == 0 ? Colors.white : Colors.orangeAccent))),
              avatar: Icon(Icons.now_wallpaper_outlined, shadows: const [], color: _filterSelected == 0 ? Colors.white : Colors.orangeAccent),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.orange,
              selected: _filterSelected == 0,
              onSelected: (value) {
                setState(() {
                  _filterSelected = 0;
                  _searchFilter = SearchFilter.name;
                  _filteredList = [];
                  _searchText = '';
                  _showCancelButton = false;
                  _searchTextController.clear();
                });
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              labelPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              label: Container(
                constraints: const BoxConstraints(
                    minWidth: 60
                ),
                child: Text(AppLocalizations.of(context)!.city, style: TextStyle(color: _filterSelected == 1 ? Colors.white : Colors.orangeAccent))),
              avatar: Icon(Icons.location_city, shadows: const [], color: _filterSelected == 1 ? Colors.white : Colors.orangeAccent),
              backgroundColor: Colors.transparent,
              selectedColor: Colors.orange,
              selected: _filterSelected == 1,
              onSelected: (value) {
                setState(() {
                  _filterSelected = 1;
                  _searchFilter = SearchFilter.city;
                  _filteredList = [];
                  _searchText = '';
                  _showCancelButton = false;
                  _searchTextController.clear();
                });
              },
            ),
          ],
        ),
      ),
      _filteredList.isNotEmpty ?
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
        child: Text("${AppLocalizations.of(context)!.resultsFound}: ${_filteredList.length}", style: const TextStyle(fontSize: 18)),
      ) : const Text(""),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: showListSearchResults(context),
        )
      )
    ]);
  }
}