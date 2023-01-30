import 'dart:convert';
import 'package:arts/api/poi_api.dart';
import 'package:arts/api/rewards_api.dart';
import 'package:arts/exception/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../model/POI.dart';
import '../model/reward.dart';
import '../model/sidequest.dart';
import '../model/sidequest_database.dart';

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
      SidequestDatabase sidequestDatabase = SidequestDatabase.fromJson(x);
      POI poi = await getPOIbyId(sidequestDatabase.poi!.substring(sidequestDatabase.poi!.indexOf("/")+1));
      Reward reward = await getRewardById(sidequestDatabase.reward!.substring(sidequestDatabase.reward!.indexOf("/")+1));
      StartDate? startDate =  sidequestDatabase.startDate;
      StartDate? endDate =  sidequestDatabase.endDate;
      Sidequest sidequest = Sidequest(poi: poi, reward: reward, endDate: endDate, startDate: startDate);
      allSidequestList.add(sidequest);
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load Sidequest');
  }
  return allSidequestList;
}

Future<List<Sidequest>> getAvailableSidequest() async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'sidequests/available'
  );
  debugPrint("Calling $uri");

  List<Sidequest> sidequestList = [];
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
      SidequestDatabase sidequestDatabase = SidequestDatabase.fromJson(x);
      POI poi = await getPOIbyId(sidequestDatabase.poi!.substring(sidequestDatabase.poi!.indexOf("/")+1));
      Reward reward = await getRewardById(sidequestDatabase.reward!.substring(sidequestDatabase.reward!.indexOf("/")+1));
      StartDate? startDate =  sidequestDatabase.startDate;
      StartDate? endDate =  sidequestDatabase.endDate;
      Sidequest sidequest = Sidequest(poi: poi, reward: reward, endDate: endDate, startDate: startDate);
      sidequestList.add(sidequest);
    }
  } else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  } else {
    throw Exception('Failed to retrieve available sidequest.');
  }
  return sidequestList;
}