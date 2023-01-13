import 'dart:async';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/model/google_routes_response.dart';
import 'package:arts/ui/styles.dart';
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
  late Itinerary _currentItinerary;
  late POI _nextStepPoi;
  Steps? _nextSteps;
  Legs? _leg;
  bool _showError = false;

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
    _drawPolylines();
  }

  Set<Marker> _drawMarkers() {
    Set<Marker> markers = {};
    //Initializing markers
    List<POI> places = widget.itinerary.path!;
    for (var poi in places) {
      markers.add(
        Marker(
          markerId: MarkerId(poi.nameEn!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          position: LatLng(poi.latitude!, poi.longitude!),
          onTap: () async {
            double distance = _geolocatorPlatform.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, poi.latitude!, poi.longitude!);
            showDialog(barrierColor: const Color(0x01000000),context: context, builder: (_) {
              return SimpleDialog(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.topCenter,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                elevation: 2.0,
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.fromLTRB(24, 115, 24, 24),
                children: [
                  SizedBox(
                    width: 200,
                    height: 150,
                    child: Image.asset(poi.imageURL!, fit: BoxFit.fitWidth)),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(poi.name!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: distance >= 1000
                          ? Text("${AppLocalizations.of(context)!.length}: ${(distance / 1000).toStringAsFixed(1)} km")
                          : Text("${AppLocalizations.of(context)!.length}: ${distance.toStringAsFixed(1)} m")
                      )
                    ],
                  ),
                ],
              );
            });
          }
        )
      );
    }
    return markers;
  }

  void _drawPolylines() async {
    if (_currentPosition == null) {
      setState(() {
        _showError = true;
      });
      return null;
    }
    List<POI> path = List.from(_currentItinerary.path!);
    POI? nextStepPoi;
    List<LatLng> coordinates = [];
    Set<Polyline> polylines = {};
    _polylines = {}; // Resetting the current path displayed on the map
    // Adding user's location as first coordinate
    coordinates.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    // Adding shortest path
    while (path.isNotEmpty) {
      double minDistance = _geolocatorPlatform.distanceBetween(coordinates.last.latitude, coordinates.last.longitude, path[0].latitude!, path[0].longitude!);
      int minDistanceIndex = 0;
      for (int i = 1; i < path.length; i++) {
        double newDistance = _geolocatorPlatform.distanceBetween(coordinates.last.latitude, coordinates.last.longitude, path[i].latitude!, path[i].longitude!);
        if (minDistance > newDistance) {
          minDistance = newDistance;
          minDistanceIndex = i;
        }
      }
      nextStepPoi ??= path[minDistanceIndex];
      coordinates.add(LatLng(path[minDistanceIndex].latitude!, path[minDistanceIndex].longitude!));
      path.removeAt(minDistanceIndex);
    }

    try {
      GoogleRoutesResponse routesResponse = await getRoutesBetweenCoordinates(coordinates);
      // Decode polyline
      List<Legs> legs = routesResponse.routes!.first.legs!;
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
        _showError = false;
        _polylines = polylines;
        _nextSteps = legs[0].steps?[0];
        _nextStepPoi = nextStepPoi!;
        _leg = legs[0];
      });
    } on ConnectionErrorException catch(e) {
      debugPrint(e.cause);
    }
  }

  @override
  void initState() {
    super.initState();

    _currentItinerary = widget.itinerary;
    _nextStepPoi = _currentItinerary.path!.first;

    Future.delayed(Duration.zero, () async {
      Position? position = await _getCurrentPosition();
      if (position == null) {
        setState(() {
          _showError = true;
        });
      } else {
        setState(() {
          _currentPosition = position;
        });
      }
      return;
    });

    _markers = _drawMarkers();

    _serviceStatusStreamSubscription = _geolocatorPlatform.getServiceStatusStream()
        .handleError((error) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }).listen((serviceStatus) {
      if (serviceStatus == ServiceStatus.enabled) {
        setState(() {
          _showError = false;
          _currentPosition = null;
        });
        Future.delayed(Duration.zero, () async {
          Position? position = await _getCurrentPosition();
          if (position != null) {
            setState(() {
              _showError = false;
              _currentPosition = position;
            });
          }
          return;
        });
      } else {
        setState(() {
          _showError = true;
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
          _drawPolylines();
        }
        debugPrint(position == null ? 'Unknown' : 'ItineraryScreen: Location updated successfully.');
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
    if (_showError) {
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
                child: NavigationDirections(steps: _nextSteps, stepName: _nextStepPoi.name!, leg: _leg)
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
  const NavigationDirections({Key? key, required this.steps, required this.stepName, required this.leg}) : super(key: key);
  final Steps? steps;
  final String stepName;
  final Legs? leg;

  @override
  Widget build(BuildContext context) {
    if (leg != null) {
      String distance = "";
      if (leg!.distanceMeters! >= 1000) {
        distance = "${(leg!.distanceMeters!.toDouble() / 1000).toStringAsFixed(1)} km";
      } else {
        distance = "${leg!.distanceMeters!} m";
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("${AppLocalizations.of(context)!.nextStep}: $stepName", style: const TextStyle(color: Colors.white)),
          Text("${AppLocalizations.of(context)!.distance}: $distance", style: const TextStyle(color: Colors.white))
        ],
      );
    }
    return const Text("");
  }
}
