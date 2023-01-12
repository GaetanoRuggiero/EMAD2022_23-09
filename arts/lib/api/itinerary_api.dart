import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../env/env.dart';
import '../exception/exceptions.dart';
import '../model/itinerary.dart';
import '../model/google_routes_response.dart' as routes;

Future<List<Itinerary>?> getAllItinerary() async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'itinerary'
  );
  debugPrint("Calling $uri");

  List<Itinerary> allItineraryList = [];
  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 10), onTimeout: () {
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
      Itinerary itinerary = Itinerary.fromJson(x);
      allItineraryList.add(itinerary);
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load POI');
  }
  return allItineraryList;
}

Future<routes.GoogleRoutesResponse> getRoutesBetweenCoordinates(List<LatLng> coordinates) async {
  final String apiKey = Env.apiKey;
  final LatLng origin = coordinates.first;
  final LatLng destination = coordinates.last;
  final List<LatLng> waypoints = coordinates.sublist(1, coordinates.length-1);
  final List<Map<String, Object>> intermediates = [];
  for (var waypoint in waypoints) {
    intermediates.add({
      "location":{
        "latLng":{
          "latitude": waypoint.latitude,
          "longitude": waypoint.longitude
        }
      }
    });
  }
  final request = {
    "origin":{
      "location":{
        "latLng":{
          "latitude": origin.latitude,
          "longitude": origin.longitude
        }
      },
    },
    "destination":{
      "location":{
        "latLng":{
          "latitude": destination.latitude,
          "longitude": destination.longitude
        }
      }
    },
    "intermediates": intermediates,
    "travelMode": "WALK",
    "polylineQuality": "OVERVIEW",
    "computeAlternativeRoutes": false,
    "routeModifiers": {
      "avoidTolls": false,
      "avoidHighways": false,
      "avoidFerries": false
    }
  };

  final headers = <String, String> {
    "Content-Type": "application/json",
    "X-Goog-Api-Key": apiKey,
    "X-Goog-FieldMask": "routes.duration,routes.distanceMeters,routes.legs"
  };
  Uri uri = Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes');

  debugPrint("Calling $uri");

  final http.Response response = await http
      .post(uri, headers: headers, body: jsonEncode(request))
      .timeout(const Duration(seconds: 10), onTimeout: () {
    return http.Response('Timeout', 500);
  })
      .onError((error, stackTrace) {
    debugPrint(error.toString());
    return http.Response('Server unreachable', 500);
  });
  if (response.statusCode == 200) {
    debugPrint("HTTP ${response.statusCode}: OK at: $uri");
    return routes.GoogleRoutesResponse.fromJson(jsonDecode(response.body));
  }
  else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  }
  else {
    throw Exception("Failure! Couldn't make the call to Google Routes API.");
  }
}