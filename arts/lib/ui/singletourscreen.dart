import 'dart:async';
import 'dart:convert';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/main.dart';
import 'package:arts/model/google_routes_response.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/ui/takepicture.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/itinerary_api.dart';
import '../model/POI.dart';
import '../model/itinerary.dart';

class SingleTourScreen extends StatefulWidget {
  final Itinerary itinerary;
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
    if (_currentItineraryPath.isEmpty) {
      return;
    }

    BitmapDescriptor defaultMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_default.png");
    BitmapDescriptor completedMarker = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_completed.png");
    BitmapDescriptor markerType;

    Set<Marker> markers = {};
    //Initializing markers
    List<POI> places = widget.itinerary.path!;
    for (int i = 0; i < places.length; i++) {
      if (!_currentItineraryPath.contains(places[i])) {
        markerType = completedMarker;
      }
      else {
        markerType = defaultMarker;
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
    if (_currentItineraryPath.isEmpty) {
      //TODO Show completed itinerary message
      debugPrint("The itinerary has been completed!");
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

    // Adding user's location as first coordinate
    coordinates.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));

    /* If the _nextStep is null it means that it needs to be chosen based on user's
    nearest place. Otherwise if the _nextStep != null we don't want to change it
    again while the user is moving so we skip the calculations. */
    if (_nextStep == null) {
      // Adding the user's nearest place as _nextStep
      double minDistance = _geolocatorPlatform.distanceBetween(coordinates.last.latitude, coordinates.last.longitude, path[0].latitude!, path[0].longitude!);
      int minDistanceIndex = 0;
      for (int i = 1; i < path.length; i++) {
        double newDistance = _geolocatorPlatform.distanceBetween(coordinates.last.latitude, coordinates.last.longitude, path[i].latitude!, path[i].longitude!);
        if (minDistance > newDistance) {
          minDistance = newDistance;
          minDistanceIndex = i;
        }
      }
      _nextStep = path[minDistanceIndex];
    }
    coordinates.add(LatLng(_nextStep!.latitude!, _nextStep!.longitude!));

    try {
      GoogleRoutesResponse routesResponse = await getRoutesBetweenCoordinates(coordinates);
      // Decode polyline
      List<Legs> legs = routesResponse.routes!.first.legs!;
      if (legs[0].distanceMeters == null ||
          legs[0].distanceMeters! < POI.getSize(_nextStep!.size!)) {
        debugPrint("Destination reached! - ${_nextStep!.name}");
        path.remove(_nextStep);
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

        return;
      }

      for (var leg in legs) {
        final decodedPolyline = decodePolyline(leg.polyline!.encodedPolyline!);
        List<LatLng> points = decodedPolyline.map((coordinates) {
          return LatLng(coordinates[0].toDouble(), coordinates[1].toDouble());
        }).toList();

        polylines.add(
            Polyline(
                polylineId: PolylineId(leg.hashCode.toString()),
                points: points,
                width: 6,
                color: Colors.blue,
                startCap: Cap.roundCap,
                endCap: Cap.buttCap
            )
        );
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
          TextButton(
            child: Text(AppLocalizations.of(context)!.nextStep, style: const TextStyle(color: lightOrange)),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _stepReached = null;
                _nextStep = null;
                _drawMarkers();
                _drawPolylines();
              });
            }),
          TextButton.icon(
            icon: const Icon(Icons.camera_alt, color: lightOrange),
            label: Text(AppLocalizations.of(context)!.takePicutre, style: const TextStyle(color: lightOrange)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera, latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude)));
              setState(() {
                _stepReached = null;
                _nextStep = null;
                _drawMarkers();
                _drawPolylines();
              });
            }),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _currentItineraryPath = widget.itinerary.path!;

    Future.delayed(Duration.zero, () async {
      Position? position = await _getCurrentPosition();
      if (position == null) {
        setState(() {
          _showLocationError = true;
        });
      } else {
        setState(() {
          _currentPosition = position;
        });
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
                color: Theme.of(context).appBarTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: NavigationDirections(
                  legs: _legs,
                  nextStep: _nextStep,
                  stepReached: _stepReached,
                  goToNextStep: _goToNextStep
                )
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      onPressed: _goToMyPosition,
      label: Text(AppLocalizations.of(context)!.myLocation, style: const TextStyle(color: Colors.white)),
      icon: const Icon(Icons.my_location, color: darkOrange))
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
  const NavigationDirections({Key? key, required this.legs, required this.nextStep, required this.stepReached, required this.goToNextStep}) : super(key: key);
  final POI? stepReached;
  final POI? nextStep;
  final List<Legs>? legs;
  final Function() goToNextStep;

  @override
  Widget build(BuildContext context) {
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

    if (legs != null && nextStep != null) {
      String distance = "${legs![0].distanceMeters!} m";
      if (legs![0].distanceMeters! >= 1000) {
        distance = "${(legs![0].distanceMeters!.toDouble() / 1000).toStringAsFixed(1)} km";
      }
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Image.asset("assets/icon/walking.gif"),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.nextStep, style: const TextStyle(color: Colors.white)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${nextStep!.name}", style: const TextStyle(fontSize: 18))
                ),
                Text("${AppLocalizations.of(context)!.distance}: $distance", style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
        ],
      );
    }
    return const Text("");
  }
}
