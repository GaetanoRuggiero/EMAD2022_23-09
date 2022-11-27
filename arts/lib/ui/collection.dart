import 'package:arts/ui/singlepoiview.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './radiobuttons.dart';

class Collection extends StatelessWidget {
  const Collection({Key? key}) : super(key: key);

  List<_Photo> _photos(BuildContext context) {
    return [
      _Photo(
        assetUrl:
            'https://images.unsplash.com/photo-1655303717503-c6ab284d7b69?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
        title: "Piazza del Plebiscito",
        subtitle: "Napoli",
      ),
      _Photo(
        assetUrl:
            'https://images.unsplash.com/photo-1581416271248-213a4f928597?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=735&q=80',
        title: "Fontana del Gigante",
        subtitle: "Napoli",
      ),
    ];
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
            GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                childAspectRatio: 1,
                children: _photos(context).map<Widget>((photo) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SinglePOIView(poiName: photo.title, poiURL: photo.assetUrl)),
                      );
                    },
                    child: _GridPhotoItem(
                      photo: photo,
                    ),
                  );
                }).toList()),
            // To Visit - Second tab
            GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.all(10),
                childAspectRatio: 1,
                children: _photos(context).map<Widget>((photo) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SinglePOIView(poiName: photo.title, poiURL: photo.assetUrl)),
                      );
                    },
                    child: _GridPhotoItem(
                      photo: photo,
                    ),
                  );
                }).toList()),
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
                      prefixIcon: const Icon(Icons.search, color: Color(0xffE68532)),
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
                      children: _photos(context).map<Widget>((photo) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SinglePOIView(poiName: photo.title, poiURL: photo.assetUrl)),
                            );
                          },
                          child: _GridPhotoItem(
                            photo: photo,
                          ),
                        );
                      }).toList()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo {
  _Photo({
    required this.assetUrl,
    required this.title,
    required this.subtitle,
  });

  final String assetUrl;
  final String title;
  final String subtitle;
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

class _GridPhotoItem extends StatelessWidget {
  const _GridPhotoItem({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final _Photo photo;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        photo.assetUrl,
        fit: BoxFit.cover,
      ),
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
          title: _GridTitleText(photo.title),
          subtitle: _GridTitleText(photo.subtitle),
        ),
      ),
      child: image,
    );
  }
}
