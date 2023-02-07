import 'package:arts/exception/exceptions.dart';
import 'package:arts/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api/itinerary_api.dart';
import '../model/google_routes_matrix.dart';
import '../utils/location_utils.dart';
import './singletourscreen.dart';
import '../api/poi_api.dart';
import '../model/POI.dart';

class CustomItineraryDialog extends StatefulWidget {
  const CustomItineraryDialog({Key? key}) : super(key: key);

  @override
  State<CustomItineraryDialog> createState() => _CustomItineraryDialogState();
}

class _CustomItineraryDialogState extends State<CustomItineraryDialog> {
  bool  _locationPermissionGranted = false;
  bool  _locationServiceEnabled = false;
  double _currentSliderValue = 4;
  late Future _searchInRangeFuture;
  Map<POI, bool> _selectedPoiMap = {};

  Future<void> _checkLocationEnabled() async {
    bool isLocationEnabled = await LocationUtils.geolocatorPlatform.isLocationServiceEnabled();
    if (isLocationEnabled) {
      setState(() {
        _locationServiceEnabled = true;
      });
    } else {
      setState(() {
        _locationServiceEnabled = false;
      });
    }
    return;
  }

  Future<void> _checkPermissionGranted() async {
    LocationPermission permission;

    permission = await LocationUtils.geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await LocationUtils.geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationPermissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _locationPermissionGranted = false;
      });
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    setState(() {
      _locationPermissionGranted = true;
    });
    return;
  }

  Future<Position?> _getCurrentPosition() async {
    if (_locationServiceEnabled && _locationPermissionGranted) {
      Position? position = await LocationUtils.geolocatorPlatform.getLastKnownPosition();
      if (position != null) {
        return position;
      }
      return await LocationUtils.geolocatorPlatform.getCurrentPosition();
    }
    return null;
  }


  @override
  void initState() {
    super.initState();
    _searchInRangeFuture = Future(() => null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createCustomItinerary),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(AppLocalizations.of(context)!.selectRange),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(10, (index) => Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text("${index+1}"),
                ))
              ),
            ),
            Slider(
              value: _currentSliderValue,
              max: 10,
              min: 1,
              divisions: 9,
              onChangeStart: (double value) {
                setState(() {
                  _searchInRangeFuture = Future(() => null);
                });
              },
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              }),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 4,
                    color: Colors.black12.withOpacity(.2),
                    offset: const Offset(2, 2))
              ],
              gradient: const LinearGradient(
                  colors: [lightOrange, darkOrange]),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextButton.icon(
                icon: const Icon(Icons.search, color: Colors.white,),
                label: Text(AppLocalizations.of(context)!.startSearch, style: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  await _checkLocationEnabled();
                  if (!_locationServiceEnabled) {
                    if (!mounted) return;
                    LocationUtils.showLocationDisabledDialog(context);
                    return;
                  }
                  await _checkPermissionGranted();
                  if (!_locationPermissionGranted) {
                    if (!mounted) return;
                    LocationUtils.showPermissionDeniedDialog(context);
                    return;
                  }
                  Position? currentPosition = await _getCurrentPosition();
                  if (currentPosition != null) {
                    setState(() {
                      _selectedPoiMap = {};
                      _searchInRangeFuture = searchInRange(currentPosition.latitude, currentPosition.longitude, _currentSliderValue);
                    });
                  }
                }
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _searchInRangeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      Map<POI, double> inRangeMap = snapshot.data!;
                      if (inRangeMap.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text("${AppLocalizations.of(context)!.noPOINearby}."),
                        );
                      }
                      inRangeMap.forEach((poi, distance) {
                        _selectedPoiMap.update(poi, (value) => value, ifAbsent: () => false);
                      });
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text("${AppLocalizations.of(context)!.customItineraryResults} ${_currentSliderValue.round().toString()} km:"),
                          ),
                          Expanded(
                            child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                padding: const EdgeInsets.all(8.0),
                                children: _selectedPoiMap.keys.map((poi) {
                                  String distanceText = "";
                                  double distance = inRangeMap[poi]!;
                                  if (distance >= 1000) {
                                    distance = distance / 1000;
                                    distanceText = "${distance.toStringAsFixed(1)} km";
                                  }
                                  else {
                                    distanceText = "${distance.round()} m";
                                  }
                                  return _CustomGridTile(
                                      poi: poi,
                                      distance: distanceText,
                                      value: _selectedPoiMap[poi],
                                      onTap: () {
                                        setState(() {
                                          _selectedPoiMap[poi] = !_selectedPoiMap[poi]!;
                                        });
                                      }
                                  );
                                }).toList(),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      color: Colors.black12.withOpacity(.2),
                                      offset: const Offset(2, 2))
                                ],
                                gradient: const LinearGradient(
                                    colors: [lightOrange, darkOrange]),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: TextButton.icon(
                                icon: const Icon(Icons.near_me, color: Colors.white),
                                label: Text(AppLocalizations.of(context)!.startItinerary, style: const TextStyle(color: Colors.white),),
                                onPressed: () {
                                  List<POI> selectedPoi = _selectedPoiMap.entries.where((element) => element.value).map((e) => e.key).toList();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SingleTourScreen(itinerary: selectedPoi)));
                                }),
                            ),
                          )
                        ],
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("${AppLocalizations.of(context)!.customItineraryBlank}."),
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<POI, double>> searchInRange(double latitude, double longitude, double range) async {
    List<POI> inRangeList = [];
    Map<POI, double> exactDistanceMap = {};
    try {
      inRangeList = await getPOIByRange(latitude, longitude, range);
      if (inRangeList.isEmpty) {
        return exactDistanceMap;
      }
      List<LatLng> coordinates = [];
      for (var poi in inRangeList) {
        coordinates.add(LatLng(poi.latitude!, poi.longitude!));
      }
      List<GoogleRoutesMatrix> matrixResponse = await getRouteMatrix([LatLng(latitude, longitude)], coordinates);
      for (var matrix in matrixResponse) {
        if (matrix.originIndex! == 0) {
          if (matrix.distanceMeters == null) {
            exactDistanceMap.putIfAbsent(inRangeList[matrix.destinationIndex!], () => 0.0);
          } else if (matrix.distanceMeters!.toDouble() <= (range * 1000)) {
            exactDistanceMap.putIfAbsent(inRangeList[matrix.destinationIndex!], () => matrix.distanceMeters!.toDouble());
          }
        }
      }
    } on ConnectionErrorException catch(e) {
      debugPrint(e.cause);
      return Future.error(e);
    }
    return exactDistanceMap;
  }
}

class _CustomGridTile extends StatelessWidget {
  const _CustomGridTile({Key? key, required this.poi, required this.distance, required this.value, required this.onTap}) : super(key: key);
  final POI poi;
  final String distance;
  final bool? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(poi.imageURL!, fit: BoxFit.cover));

    return InkWell(
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GridTile(
            footer: Material(
              color: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 65
                ),
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(poi.name!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                    Text(distance, textAlign: TextAlign.start, style: const TextStyle(color: Colors.white70, fontSize: 14),),
                  ]
                ),
              ),
            ),
            child: image,
          ),
          (value != null && value!) ?
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade900.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Icon(Icons.check_circle, size: 80, color: Colors.white.withOpacity(0.7),)
          ) : const Text("")
        ],
      ),
    );
  }
}