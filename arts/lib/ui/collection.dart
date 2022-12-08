import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import './singlepoiview.dart';
import '../utils/debouncer.dart';
import '../model/POI.dart';

enum SearchFilter { city, name }

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late List<POI> _visitedPOIList = [];

  // TODO: not implemented yet
  Future<bool> loadVisitedPOI() async {
    debugPrint('http://${Env.serverIP}:${Env.serverPort}/getPOIList');
    _visitedPOIList = [];
    final response = await http
        .get(Uri.parse('http://${Env.serverIP}:${Env.serverPort}/getPOIList'))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      /* We force a 500 http response after timeout to simulate a
          * connection error with the server. */
      return http.Response('Timeout', 500);
    });

    if (response.statusCode == 200) {
      /*If the server did return a 200 OK response, parse the Json and decode
      its content with UTF-8 to allow accented characters to be shown correctly */
      List jsonArray = jsonDecode(utf8.decode(response.bodyBytes));
      for (var x in jsonArray) {
        POI poi = POI.fromJson(x);
        _visitedPOIList.add(poi);
      }
    } else if (response.statusCode == 500) {
      return false;
    } else {
      throw Exception('Failed to load POI');
    }
    return true;
  }

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
        body: TabBarView(
          children: [
            // Visited - First tab
            FutureBuilder(
                future: loadVisitedPOI(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return VisitedTabView(visitedPOIList: _visitedPOIList);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
            // To Visit - Second tab
            const ToVisitTabView(),
            // Search - Third tab
            const SearchTabView()
          ],
        ),
      ),
    );
  }
}

class VisitedTabView extends StatefulWidget {
  final List<POI> visitedPOIList;

  const VisitedTabView({Key? key, required this.visitedPOIList})
      : super(key: key);

  @override
  State<VisitedTabView> createState() => _VisitedTabViewState();
}

class _VisitedTabViewState extends State<VisitedTabView> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(10),
        childAspectRatio: 1,
        children: widget.visitedPOIList.map((poi) {
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

  Future<List<POI>?> getPOIListByFilter(String searchText, SearchFilter filter) async {
    Uri uri;
    if (filter == SearchFilter.city) {
      uri = Uri(
          scheme: 'http',
          host: Env.serverIP,
          port: Env.serverPort,
          path: 'getPOIListByCity',
          queryParameters: {'city' : searchText}
      );
    }
    else {
      uri = Uri(
          scheme: 'http',
          host: Env.serverIP,
          port: Env.serverPort,
          path: 'getPOIListByName',
          queryParameters: {'name' : searchText}
      );
    }

    debugPrint("Calling $uri");

    List<POI> filteredList = [];
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 4), onTimeout: () {
      /* We force a 500 http response after timeout to simulate a
         connection error with the server. */
      return http.Response('Timeout', 500);
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      return http.Response('Server unreachable', 500);
    });

    if (response.statusCode == 200) {
      /*If the server did return a 200 OK response, parse the Json and decode
      its content with UTF-8 to allow accented characters to be shown correctly */
      List jsonArray = jsonDecode(utf8.decode(response.bodyBytes));
      for (var x in jsonArray) {
        POI poi = POI.fromJson(x);
        filteredList.add(poi);
      }
    }
    else if (response.statusCode == 500) {
      debugPrint("Server did not respond at: $uri");
      return null;
    }
    else {
      throw Exception('Failed to load POI');
    }

    return filteredList;
  }

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