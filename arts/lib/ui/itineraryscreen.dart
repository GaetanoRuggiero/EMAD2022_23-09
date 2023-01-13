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
  late GoogleMapController _mapController;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool locationServiceToggle = false;
  late Position? _currentPosition;
  List<Marker> _markers = [];
  late Future<List<Polyline>?> _drawPolylinesFuture;

  Future<bool> _handlePermission() async {
    LocationPermission permission;
    bool locationService;

    locationService = await _geolocatorPlatform.isLocationServiceEnabled();
    // Test if location services are enabled.
    if (!locationService) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      showLocationDisabledDialog();
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
        title: Text(
            AppLocalizations.of(context)!.locationPermissionDialogTitle),
        content: Text(
            AppLocalizations.of(context)!.locationPermissionDialogContent),
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
  }

  List<Marker> _drawMarkers(List<POI> places) {
    List<Marker> markers = [];
    //Initializing markers
    for (var poi in places) {
      markers.add(
          Marker(
            markerId: MarkerId(poi.nameEn!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
                title: poi.name,
                snippet: poi.province
            ),
            position: LatLng(poi.latitude!, poi.longitude!),
          ));
    }
    return markers;
  }

  Future<List<Polyline>?> _drawPolylines() async {
    Position? myPosition = await _getCurrentPosition();
    if (myPosition != null) {
      _currentPosition = myPosition;
    }
    else {
      return null;
    }
    List<POI> path = widget.itinerary.path!;
    List<Polyline> polylines = [];
    List<LatLng> coordinates = [];
    coordinates.add(LatLng(myPosition.latitude, myPosition.longitude));
    for (var poi in path) {
      coordinates.add(LatLng(poi.latitude!, poi.longitude!));
    }
    try {
      GoogleRoutesResponse routesResponse = await getRoutesBetweenCoordinates(
          coordinates);
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
    } on ConnectionErrorException catch (e) {
      debugPrint(e.cause);
      return null;
    }
    return polylines;
  }

  @override
  void initState() {
    super.initState();

    _markers = _drawMarkers(widget.itinerary.path!);
    _drawPolylinesFuture = _drawPolylines();

    _serviceStatusStreamSubscription =
        _geolocatorPlatform.getServiceStatusStream()
            .handleError((error) {
          _serviceStatusStreamSubscription?.cancel();
          _serviceStatusStreamSubscription = null;
        }).listen((serviceStatus) {
          setState(() {
            _drawPolylinesFuture = _drawPolylines();
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: FutureBuilder(
              future: _drawPolylinesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    List<Polyline> polylines = snapshot.data!;
                    return GoogleMap(
                      markers: Set.from(_markers),
                      polylines: Set.from(polylines),
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          zoom: 18.0
                      ),
                    );
                  }
                  else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 80),
                          Text(AppLocalizations.of(context)!
                              .deviceLocationNotAvailable),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  _handlePermission();
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .turnOnLocation)
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
          ),
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
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0
          )
      ));
    }
  }
}
