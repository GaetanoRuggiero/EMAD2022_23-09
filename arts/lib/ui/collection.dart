import 'package:arts/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './singlepoiview.dart';
import '../utils/debouncer.dart';
import '../model/POI.dart';
import '../api/poi_api.dart';

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
  const VisitedTabView({Key? key})
      : super(key: key);

  @override
  State<VisitedTabView> createState() => _VisitedTabViewState();
}

class _VisitedTabViewState extends State<VisitedTabView> {
  List<POI> _visitedPOIList = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getVisitedPOI(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            _visitedPOIList = snapshot.data!;
            return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                childAspectRatio: 1,
                children: _visitedPOIList.map((poi) {
                  return GestureDetector(
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
          else {
            return Container(padding: const EdgeInsets.all(20.0), child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                Text(textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                  AppLocalizations.of(context)!.connectionError
                )
              ],
            ));
          }
        }
        else {
          return const Center(child: CircularProgressIndicator());
        }
      }
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

class _SearchTabViewState extends State<SearchTabView> {
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
          return GestureDetector(
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
  Widget build(BuildContext context) {
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

                List<POI>? newFilteredList;
                if (_searchFilter == SearchFilter.city) {
                  newFilteredList = await getPOIListByCity(text);
                }
                else {
                  newFilteredList = await getPOIListByName(text);
                }


                if (newFilteredList == null) {
                  /* Server did not respond. */
                  debugPrint("Showing error");
                  setState(() {
                    _showLoading = false;
                    _showError = true;
                  });
                }
                else if (newFilteredList.isNotEmpty) {
                  /* Server responded successfully, we turn off all the flags. */
                  debugPrint("Ready! Showing results.");
                  setState(() {
                    _filteredList = newFilteredList!;
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