import 'dart:async';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/model/google_routes_response.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/itinerary_api.dart';
import '../model/POI.dart';
import '../model/itinerary.dart';

class ItineraryScreen extends StatefulWidget {
  final Itinerary itinerary;
  const ItineraryScreen({Key? key, required this.itinerary}) : super(key: key);

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
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
            infoWindow: InfoWindow(
                title: poi.name,
                snippet: poi.province
            ),
            position: LatLng(poi.latitude!, poi.longitude!),
          ));
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
    List<POI> path = List.from(widget.itinerary.path!);
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
      });
    } on ConnectionErrorException catch(e) {
      debugPrint(e.cause);
    }
  }

  Widget _setUIState() {
    if (_showError) {
      return Center(
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
      );
    }
    if (_currentPosition != null) {
      return GoogleMap(
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
      );
    }
    else {
      return Center(
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
      );
    }
  }

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      body: SafeArea(
        child: _setUIState()
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: _goToMyPosition,
      label: Text(AppLocalizations.of(context)!.myLocation),
      icon: const Icon(Icons.my_location))
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