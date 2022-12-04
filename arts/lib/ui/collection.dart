import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import './singlepoiview.dart';
import '../utils/radiobuttons.dart';
import '../model/POI.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {

  late List<POI> visitedPOIList;

  Future<bool> loadVisitedPOI() async {
    visitedPOIList = [];
    final response = await http.get(Uri.parse('http://${Env.serverIP}:${Env.serverPort}/getPOIList'))
        .timeout(const Duration(seconds: 5), onTimeout: () {
          /* We force a 500 http response after timeout to simulate a
          * connection error with the server. */
          return http.Response('Timeout', 500);
        } );

    if (response.statusCode == 200) {
      /*If the server did return a 200 OK response, parse the Json and decode
      its content with UTF-8 to allow accented characters to be shown correctly */
      List jsonArray = jsonDecode(utf8.decode(response.bodyBytes));
      for (var x in jsonArray) {
        POI poi = POI.fromJson(x);
        visitedPOIList.add(poi);
      }
    }
    else if (response.statusCode == 500) {
      return false;
    }
    else {
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
                /* If the Future has done */
                if (snapshot.connectionState == ConnectionState.done) {
                  /* If the response from server was 200 show all POI */
                  if (snapshot.data!) {
                    return GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        padding: const EdgeInsets.all(10),
                        childAspectRatio: 1,
                        children: visitedPOIList.map((poi) {
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
                    );
                  } else { /* Connection with server timed out */
                    return const Center(child: Icon(Icons.error));
                  }
                }
                else { /* Future has not completed yet, show a loading indicator*/
                  return const Center(child: CircularProgressIndicator());
                }
              }
            ),
            // To Visit - Second tab
            GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                childAspectRatio: 1,
                children: []
            ),
            // Search Tab
            Column(
              children: [
                const RadioFilter(),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      hintText: "Ricerca per città, es. Napoli",
                      prefixIcon: const Icon(
                          Icons.search, color: Color(0xffE68532)),
                    ),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      padding: const EdgeInsets.all(20),
                      childAspectRatio: 1,
                      children: []),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    String thumbnailURL = poi.imageURL!.replaceRange(poi.imageURL!.lastIndexOf('_')+1, null, thumbnailName);

    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(thumbnailURL, fit: BoxFit.cover)
    );

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
