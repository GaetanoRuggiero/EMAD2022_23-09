import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:arts/exception/exceptions.dart';
import 'package:arts/main.dart';
import 'package:arts/model/google_routes_response.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/ui/takepicture.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/itinerary_api.dart';
import '../model/POI.dart';
import '../model/google_routes_matrix.dart';

class SingleTourScreen extends StatefulWidget {
  final List<POI> itinerary;
  const SingleTourScreen({Key? key, required this.itinerary}) : super(key: key);

  @override
  State<SingleTourScreen> createState() => _SingleTourScreenState();
}

class _SingleTourScreenState extends State<SingleTourScreen> {
  GoogleMapController? _mapController;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  final LocationSettings locationSettings = const LocationSettings(
    distanceFilter: 5,
  );
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late List<POI> _currentItineraryPath;
  List<Legs>? _legs;
  POI? _nextStep;
  POI? _stepReached;
  bool _itineraryCompleted = false;
  bool _showLocationError = false;

  Future<bool> _handlePermission() async {
    LocationPermission permission;
    bool locationService;

    locationService = await _geolocatorPlatform.isLocationServiceEnabled();
    // Test if location services are enabled.
    if (!locationService) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        showPermissionDeniedDialog();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      showPermissionDeniedDialog();
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }

    return await _geolocatorPlatform.getCurrentPosition();
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();

    if (opened) {
      debugPrint("Opened Location Settings");
    } else {
      debugPrint("Error opening Location Settings");
    }
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();

    if (opened) {
      debugPrint("Opened Application Settings");
    } else {
      debugPrint("Error opening Location Settings");
    }
  }

  void showLocationDisabledDialog() {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationOffDialogTitle),
        content: Text(AppLocalizations.of(context)!.locationOffDialogContent),
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.noThanks),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text(AppLocalizations.of(context)!.turnOnLocation),
              onPressed: () {
                Navigator.of(context).pop();
                _openLocationSettings();
              })
        ],
      );
    });
  }

  void showPermissionDeniedDialog() {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationPermissionDialogTitle),
        content: Text(AppLocalizations.of(context)!.locationPermissionDialogContent),
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.noThanks),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text(AppLocalizations.of(context)!.allowPermission),
              onPressed: () {
                Navigator.of(context).pop();
                _openAppSettings();
              })
        ],
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    var mapStyle = [{
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }];
    _mapController!.setMapStyle(jsonEncode(mapStyle));
    _drawPolylines();
    _drawMarkers();
  }

  void _drawMarkers() async {

    BitmapDescriptor nextMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_next.png");
    BitmapDescriptor toVisitMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_tovisit.png");
    BitmapDescriptor visitedMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_visited.png");
    BitmapDescriptor markerType;

    Set<Marker> markers = {};
    //Initializing markers
    List<POI> places = widget.itinerary;
    for (int i = 0; i < places.length; i++) {
      if (!_currentItineraryPath.contains(places[i])) {
        markerType = visitedMarker;
      }
      else {
        if (places[i] == _currentItineraryPath.first) {
          markerType = nextMarker;
        } else {
          markerType = toVisitMarker;
        }
      }
      markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          icon: markerType,
          position: LatLng(places[i].latitude!, places[i].longitude!),
          onTap: () {
            showDialog(barrierColor: const Color(0x01000000),
              context: context,
              builder: (_) {
                Color backgroundColor;
                if (!_currentItineraryPath.contains(places[i])) {
                  backgroundColor = Colors.green;
                }
                else {
                  backgroundColor = lightOrange;
                }
                return SimpleDialog(
                  backgroundColor: backgroundColor,
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.topCenter,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                  elevation: 2.0,
                  contentPadding: EdgeInsets.zero,
                  insetPadding: const EdgeInsets.fromLTRB(24, 115, 24, 24),
                  children: [
                    SizedBox(
                      width: 200,
                      height: 150,
                      child: Image.asset(places[i].imageURL!, fit: BoxFit.fitWidth)
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: backgroundColor == Colors.green
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.where_to_vote, color: Colors.white, size: 30.0),
                                ),
                                Text(places[i].name!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.not_listed_location, color: Colors.white, size: 28.0),
                                ),
                                Text(places[i].name!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                        )
                      ],
                    ),
                  ],
                );
              }
            );
          }
        )
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  void _drawPolylines() async {
    if (_itineraryCompleted) {
      return;
    }
    if (_currentPosition == null) {
      setState(() {
        _showLocationError = true;
      });
      return;
    }

    List<POI> path = List.from(_currentItineraryPath);
    List<LatLng> coordinates = [];
    Set<Polyline> polylines = {};

    _nextStep ??= _currentItineraryPath.first;
    for (var poi in _currentItineraryPath) {
      coordinates.add(LatLng(poi.latitude!, poi.longitude!));
    }
    LatLng origin = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    try {
      GoogleRoutesResponse routesResponse = await getRoutesBetweenCoordinates(origin, coordinates.last, coordinates.sublist(0, coordinates.length-1));
      List<Legs> legs = routesResponse.routes!.first.legs!;
      if (legs[0].distanceMeters == null || legs[0].distanceMeters! < POI.getSize(_nextStep!.size!)) {
        debugPrint("Step reached! - ${_nextStep!.name}");
        path.remove(_nextStep);

        // We check if there are more steps
        if (path.isNotEmpty) {
          debugPrint("Remaining steps:");
          for (var element in path) {
            debugPrint("  -- ${element.name}");
          }
          setState(() {
            _currentItineraryPath = path;
            _polylines = {};
            _stepReached = _nextStep;
            _nextStep = null;
          });
          showDestinationReachedDialog();
        } else {
          setState(() {
            _currentItineraryPath = path;
            _polylines = {};
            _itineraryCompleted = true;
          });
          _drawMarkers();
          showItineraryCompletedDialog();
          debugPrint("The itinerary has been completed!");
        }
        return;
      }

      // Decode polyline
      for (int i = 0; i < legs.length; i++) {
        final decodedPolyline = decodePolyline(legs[i].polyline!.encodedPolyline!);
        List<LatLng> points = decodedPolyline.map((coordinates) {
          return LatLng(coordinates[0].toDouble(), coordinates[1].toDouble());
        }).toList();

        /* First Polyline represents the path to the next POI, we draw it with
        * a different color. */
        if (i == 0) {
          polylines.add(
            Polyline(
              polylineId: PolylineId(i.toString()),
              points: points,
              patterns: [
                //PatternItem.dash(10.0),
                PatternItem.gap(20),
                PatternItem.dot
              ],
              width: 10,
              color: Colors.blue,
              zIndex: 5
            )
          );
        } else {
          polylines.add(
            Polyline(
              polylineId: PolylineId(i.toString()),
              points: points,
              patterns: [
                //PatternItem.dash(10.0),
                PatternItem.gap(25),
                PatternItem.dot
              ],
              width: 6,
              color: Colors.grey.withOpacity(0.5),
              zIndex: -1
            )
          );
        }
      }
      setState(() {
        _showLocationError = false;
        _polylines = polylines;
        _legs = legs;
        _stepReached = null;
      });
    } on ConnectionErrorException catch(e) {
      debugPrint(e.cause);
    }
  }

  void showDestinationReachedDialog() {
    showDialog(barrierColor: const Color(0x01000000), context: context, builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.poiNearby),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        icon: const Icon(Icons.flag, size: 25.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${_stepReached!.name}", style: const TextStyle(color: darkOrange, fontWeight: FontWeight.bold)),
            ),
            Text(AppLocalizations.of(context)!.takeAPictureAddToCollection),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.skip_next, color: lightOrange),
            label: Text(AppLocalizations.of(context)!.nextStep, style: const TextStyle(color: lightOrange)),
            onPressed: () {
              Navigator.pop(context);
              _drawMarkers();
              _drawPolylines();
            }),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt, color: lightOrange),
            label: Text(AppLocalizations.of(context)!.takePicutre, style: const TextStyle(color: lightOrange)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera, latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude)));
              _drawMarkers();
              _drawPolylines();
            }),
        ],
      );
    });
  }

  void showItineraryCompletedDialog() {
    showDialog(barrierColor: const Color(0x01000000), context: context, builder: (context) {
      return AlertDialog(
        title: Text("${AppLocalizations.of(context)!.congratulations}!"),
        actionsAlignment: MainAxisAlignment.center,
        icon: const Icon(Icons.sports_score, size: 25.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.destinationReached),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.backToHomepage, style: const TextStyle(color: lightOrange)),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      Position? position = await _getCurrentPosition();
      if (position == null) {
        setState(() {
          _showLocationError = true;
        });
      } else {
        try {
          List<POI> orderedPath = [];
          List<LatLng> coordinates = [];
          coordinates.add(LatLng(position.latitude, position.longitude));
          for (var poi in widget.itinerary) {
            coordinates.add(LatLng(poi.latitude!, poi.longitude!));
          }

          List<GoogleRoutesMatrix> matrixResponse = await getRouteMatrix(coordinates, coordinates);

          int originIndex = 0;
          int minMatrixIndex = 0;
          while (orderedPath.length != widget.itinerary.length) {
            int distanceMeters = 999999999999;
            for (int i = 0; i < matrixResponse.length; i++) {
              if (matrixResponse[i].destinationIndex == 0 || matrixResponse[i].originIndex == matrixResponse[i].destinationIndex) {
                matrixResponse.removeAt(i);
                i--;
                continue;
              }
              if (originIndex == matrixResponse[i].originIndex && originIndex != matrixResponse[i].destinationIndex) {
                if (matrixResponse[i].distanceMeters == null) {
                  distanceMeters = 0;
                  minMatrixIndex = i;
                } else if (distanceMeters > matrixResponse[i].distanceMeters!) {
                  distanceMeters = matrixResponse[i].distanceMeters!;
                  minMatrixIndex = i;
                }
              }
            }
            if (!orderedPath.contains(widget.itinerary[matrixResponse[minMatrixIndex].destinationIndex!-1])) {
              orderedPath.add(widget.itinerary[matrixResponse[minMatrixIndex].destinationIndex!-1]);
            }
            originIndex = matrixResponse[minMatrixIndex].destinationIndex!;
            matrixResponse.removeAt(minMatrixIndex);
          }

          debugPrint("The itinerary has been established!");
          for (int i = 0; i < orderedPath.length-1; i++) {
            debugPrint("${i+1} - ${orderedPath[i].name}");
          }

          setState(() {
            _currentPosition = position;
            _currentItineraryPath = orderedPath;
          });
        } on ConnectionErrorException catch(e) {
          debugPrint(e.cause);
        }
      }
      return;
    });

    _serviceStatusStreamSubscription = _geolocatorPlatform.getServiceStatusStream()
        .handleError((error) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }).listen((serviceStatus) {
      if (serviceStatus == ServiceStatus.enabled) {
        setState(() {
          _showLocationError = false;
          _currentPosition = null;
        });
        Future.delayed(Duration.zero, () async {
          Position? position = await _getCurrentPosition();
          if (position != null) {
            setState(() {
              _showLocationError = false;
              _currentPosition = position;
            });
          }
          return;
        });
      } else {
        setState(() {
          _showLocationError = true;
          _currentPosition = null;
        });
      }
    });

    _positionStreamSubscription = _geolocatorPlatform.getPositionStream(locationSettings: locationSettings)
      .handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      })
      .listen((Position? position) {
        if (position != null) {
          _currentPosition = position;
          _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0
            )
          ));
          _drawPolylines();
        }
        debugPrint(position == null ? 'Unknown' : 'SingleTourListScreen: Location updated successfully.');
      });
  }

  @override
  void dispose() {
    super.dispose();
    if (_mapController != null) {
      _mapController!.dispose();
    }
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLocationError) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 80),
                Text(AppLocalizations.of(context)!.deviceLocationNotAvailable),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool hasPermissions = await _handlePermission();
                      if (!hasPermissions) {
                        showLocationDisabledDialog();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.turnOnLocation)
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_currentPosition == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${AppLocalizations.of(context)!.fetchingGPSCoordinates}..."),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: _markers,
              polylines: _polylines,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 18.0
              )
            ),
            Positioned(
              top: 0,
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Card(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: NavigationDirections(
                  legs: _legs,
                  nextStep: _nextStep,
                  stepReached: _stepReached,
                  goToNextStep: _goToNextStep,
                  itineraryCompleted: _itineraryCompleted,
                )
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: _goToMyPosition,
      label: Text(AppLocalizations.of(context)!.myLocation, style: const TextStyle(color: Colors.white)),
      icon: const Icon(Icons.my_location))
    );
  }

  void _goToNextStep() {
    if (_currentItineraryPath.isNotEmpty && _stepReached != null) {
      setState(() {
        _currentItineraryPath.remove(_stepReached!);
        _nextStep = null;
        _stepReached = null;
        _drawMarkers();
        _drawPolylines();
      });
    }
  }

  Future<void> _goToMyPosition() async {
    Position? position = await _getCurrentPosition();
    if (position != null) {
      _currentPosition = position;
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0
        )
      ));
    }
  }
}

class NavigationDirections extends StatelessWidget {
  const NavigationDirections({
    Key? key,
    required this.legs,
    required this.nextStep,
    required this.stepReached,
    required this.goToNextStep,
    required this.itineraryCompleted}) : super(key: key);

  final List<Legs>? legs;
  final POI? nextStep;
  final POI? stepReached;
  final bool itineraryCompleted;
  final Function() goToNextStep;

  @override
  Widget build(BuildContext context) {

    if (itineraryCompleted) {
      return Column(
        children:[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.sports_score, size: 40),
                  Expanded(child: Text(textAlign: TextAlign.center, AppLocalizations.of(context)!.destinationReached, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton.icon(
                icon: const Icon(Icons.home),
                onPressed: () { Navigator.of(context).popUntil((route) => route.isFirst); },
                label: Text(AppLocalizations.of(context)!.backToHomepage),
                style: TextButton.styleFrom(foregroundColor: lightOrange)),
          )
        ],
      );
    }

    // Show the POI that has been reached
    if (stepReached != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.flag, size: 40),
                ),
                Center(child: Text("${stepReached!.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.skip_next),
            onPressed: goToNextStep,
            label: Text(AppLocalizations.of(context)!.nextStep),
            style: TextButton.styleFrom(foregroundColor: lightOrange))
        ],
      );
    }

    // Show the next POI to be reached with distance
    if (legs != null && nextStep != null) {
      String distance = "${legs![0].distanceMeters!} m";
      if (legs![0].distanceMeters! >= 1000) {
        distance = "${(legs![0].distanceMeters!.toDouble() / 1000).toStringAsFixed(1)} km";
      }
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.nextStep, style: const TextStyle(color: Colors.white)),
                  Text("${nextStep!.name}", style: const TextStyle(fontSize: 16)),
                  Text("${AppLocalizations.of(context)!.distance}: $distance", style: const TextStyle(color: Colors.white))
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Transform.rotate(angle: 270 * math.pi / 180, child: const Icon(FontAwesomeIcons.shoePrints)),
              ),
            ],
          ),
        ],
      );
    }

    // Show loading indicator
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const CircularProgressIndicator(),
        Text(AppLocalizations.of(context)!.loading),
      ],
    );
  }
}