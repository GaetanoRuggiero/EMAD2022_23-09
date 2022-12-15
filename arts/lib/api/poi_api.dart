import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../model/POI.dart';

// TODO: not implemented yet
Future<List<POI>?> getVisitedPOI() async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'poi'
  );
  debugPrint("Calling $uri");

  List<POI> visitedPOIList = [];
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
      visitedPOIList.add(poi);
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load POI');
  }
  return visitedPOIList;
}

Future<List<POI>?> getPOIListByCity(String searchText) async {
  Uri uri = Uri(
    scheme: 'http',
    host: Env.serverIP,
    port: Env.serverPort,
    path: 'poi',
    queryParameters: {'city' : searchText}
  );
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

Future<List<POI>?> getPOIListByName(String searchText) async {
  Uri uri = Uri(
    scheme: 'http',
    host: Env.serverIP,
    port: Env.serverPort,
    path: 'poi',
    queryParameters: {'name' : searchText}
  );
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