import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './singlepoiview.dart';
import '../utils/debouncer.dart';
import '../model/POI.dart';
import '../api/collection_api.dart';

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
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded))
          ],
          title: const Text("Collezione"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(FontAwesomeIcons.bookBookmark), text: "Visitate"),
              Tab(icon: Icon(FontAwesomeIcons.book), text: "Da visitare"),
              Tab(icon: Icon(FontAwesomeIcons.magnifyingGlass), text: "Cerca"),
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
              children: const [
                Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
                Text(textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Color(0xFFE68532)),
                    "Impossibile connettersi al server. Controlla la tua connessione o riprova più tardi."
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
  SearchFilter? _searchFilter = SearchFilter.city;
  String _searchText = '';
  late List<POI> _filteredList = [];
  bool _showError = false;
  bool _showLoading = true;
  bool _noResultsFound = false;
  final _debouncer = Debouncer(milliseconds: 500);

  Widget showGridSearchResults() {
    if (_searchText.isEmpty) {
      return Container();
    }
    if (_showLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_showError) {
      return Container(padding: const EdgeInsets.all(20.0), child: Column(
        children: const [
          Icon(Icons.error_outline, size: 64.0, color: Color(0xFFE68532)),
          Text(textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xFFE68532)),
              "Impossibile connettersi al server. Controlla la tua connessione o riprova più tardi."
          )
        ],
      ));
    }
    if (_noResultsFound) {
      return Center(child: Text(style: TextStyle(fontSize: 20),"Nessun risultato trovato per '$_searchText'"));
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
        const Text("Città"),
        Radio<SearchFilter>(
          value: SearchFilter.city,
          groupValue: _searchFilter,
          onChanged: (SearchFilter? value) {
            setState(() {
              _searchFilter = value;
            });
          },
        ),
        const Text("Opera"),
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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(child: radioButtonFilter()),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: TextField(
          onChanged: (String text) {
            _debouncer.run(() async {
              /* The second condition blocks the call of onChanged even when
            the focus of TextField is loss (e.g when the back button is pressed to hide keyboard). */
              if (text.length >= 3 && text != _searchText) {
                _searchText = text;
                if (_filteredList.isEmpty) {
                  debugPrint("Loading...");
                  setState(() {
                    _showLoading = true;
                    _showError = false;
                  });
                }

                var newFilteredList = await getPOIListByFilter(text, _searchFilter!);

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
                debugPrint("No input given. UI is clear.");
                setState(() {
                  _filteredList = [];
                  _showError = false;
                  _showLoading = false;
                  _searchText = '';
                });
              }
              else { return; }
            });
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            hintText: "Ricerca per città, es. Napoli",
            prefixIcon: const Icon(Icons.search, color: Color(0xffE68532)),
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