import 'dart:convert';
import 'dart:math';
import 'package:arts/api/poi_api.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../model/POI.dart';
import '../model/user.dart';

Future<bool?> loginUser(String email, String password, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/login');

  final body = {'email': email, 'password': password, 'token': token};

  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };

  debugPrint("Calling $uri");

  final response =
      await http.post(uri, headers: headers, body:jsonEncode(body)).timeout(const Duration(seconds: 4), onTimeout: () {
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

    bool isLogged =  jsonDecode(response.body);
    if (isLogged) {
      debugPrint("Logged successfully");
      return true;
    }
  } else if (response.statusCode == 500) {
    debugPrint("Server did not respond at: $uri");
    return null;
  } else {
    throw Exception('Failed');
  }
  debugPrint("Wrong credentials for: email: $email and password: $password");
  return false;
}

Future<bool?> signUpUser(String name, String surname, String email, String password, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/signUp');
  final body = {'name': name, 'surname': surname, 'email': email, 'password': password, 'token': token};

  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };

  debugPrint("Calling $uri");

  final response =
  await http.post(uri, headers: headers, body:jsonEncode(body)).timeout(const Duration(seconds: 4), onTimeout: () {
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
    bool isSignedUp =  jsonDecode(response.body);
    if (isSignedUp) {
      debugPrint("SignedUp successfully");
      return true;
    }
  } else if (response.statusCode == 500) {
    debugPrint("Server did not respond at: $uri");
    return null;
  } else {
    throw Exception('Failed');
  }
  return false;
}

Future<bool?> checkIfLogged(String email, String token) async {
  Uri uri = Uri(
      scheme: 'http', host: Env.serverIP, port: Env.serverPort, path: 'users/checkTokenValidity');
  debugPrint("Calling $uri");

  final body = {'email': email, 'token': token};

  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };
  final response =
      await http.post(uri, headers: headers, body:jsonEncode(body)).timeout(const Duration(seconds: 4), onTimeout: () {
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

    bool alreadyLogged = jsonDecode(response.body);
    if (alreadyLogged) {
      return true;
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Could not check token validity');
  }
  return false;
}

Future<bool> deleteToken(String email, String token) async {
  Uri uri = Uri(
      scheme: 'http', host: Env.serverIP, port: Env.serverPort, path: '/users/deleteToken');
  debugPrint("Calling $uri");

  final body = {'email': email, 'token': token};

  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };
  final response =
  await http.post(uri, headers: headers, body:jsonEncode(body)).timeout(const Duration(seconds: 4), onTimeout: () {
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
    if (jsonDecode(response.body) == true){
      return true;
    }
  } else if (response.statusCode == 500) {
    debugPrint("Server did not respond at: $uri");
    return false;
  } else {
    throw Exception('Could not delete token validity');
  }
  return false;
}

String generateToken() {
  final randomNumber = Random.secure().nextDouble();
  final randomBytes = utf8.encode(randomNumber.toString());
  final randomString = sha256.convert(randomBytes).toString();
  return randomString;
}

Future<List<POI>?> getVisitedPOI(String email, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: '/users/getVisited'
  );
  debugPrint("Calling $uri");

  List<POI> visitedPOIList = [];
  final body = {'email': email, 'token': token};

  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };
  final response =
  await http.post(uri, headers: headers, body:jsonEncode(body)).timeout(const Duration(seconds: 4), onTimeout: () {
    /* We force a 500 http response after timeout to simulate a
         connection error with the server. */
    return http.Response('Timeout', 500);
  }).onError((error, stackTrace) {
    debugPrint(error.toString());
    return http.Response('Server unreachable', 500);
  });

  if (response.statusCode == 200) {
    List jsonArray = jsonDecode(response.body);
    for (var x in jsonArray) {
      Visited visited = Visited.fromJson(x);
      POI? poi = await getPOIbyId(visited.poiId!);
      if (poi != null) {
        visitedPOIList.add(poi);
      }
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load POI');
  }
  return visitedPOIList;
}




