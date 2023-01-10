import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../model/sidequest.dart';

// TODO: not implemented yet
Future<List<Sidequest>?> getAllSidequest() async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'sidequests'
  );
  debugPrint("Calling $uri");

  List<Sidequest> allSidequestList = [];
  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 7), onTimeout: () {
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
      Sidequest sidequest = Sidequest.fromJson(x);
      allSidequestList.add(sidequest);
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load Sidequest');
  }
  return allSidequestList;
}