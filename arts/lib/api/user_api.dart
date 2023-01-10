import 'dart:convert';
import 'dart:math';
import 'package:arts/api/poi_api.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../exception/exceptions.dart';
import '../model/POI.dart';
import '../model/user.dart';

String generateToken() {
  final randomNumber = Random.secure().nextDouble();
  final randomBytes = utf8.encode(randomNumber.toString());
  final randomString = sha256.convert(randomBytes).toString();
  return randomString;
}

String hashPassword(String password){
  var saltedPassword = Env.salt + password;
  var bytes = utf8.encode(saltedPassword);
  var hash = sha256.convert(bytes).toString();
  return hash;
}

Future<User?> loginUser(String email, String password, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/login');

  String hashedPassword = hashPassword(password);

  final body = {'email': email, 'password': hashedPassword, 'token': token};

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

    if (response.body.isNotEmpty) {
      User user = User.fromJson(jsonDecode(response.body));
      debugPrint("Logged successfully");
      return user;
    }
  } else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  } else {
    throw Exception('Failed');
  }
  debugPrint("Wrong credentials for: email: $email and password: $password");
  return null;
}

Future<bool?> signUpUser(String name, String surname, String email, String password, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/signUp');

  String hashedPassword = hashPassword(password);

  final body = {'name': name, 'surname': surname, 'email': email, 'password': hashedPassword, 'token': token};

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
    throw Exception('Fatal Error');
  }
  return false;
}

Future<User?> checkIfLogged(String email, String token) async {
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

    if (response.body.isNotEmpty) {
      User user = User.fromJson(jsonDecode(response.body));
      return user;
    }
  } else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  } else {
    throw Exception('Fatal Error');
  }
  return null;
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

Future<Map<POI, String>> getVisitedPOI(String email, String token) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: '/users/getVisited'
  );
  debugPrint("Calling $uri");

  Map<POI, String> visitedPOIMap = {};
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
      try {
        POI poi = await getPOIbyId(visited.poiId!);
        visitedPOIMap.putIfAbsent(poi, () => visited.lastVisited!);
      } on ConnectionErrorException catch(e) {
        debugPrint(e.cause);
      }
    }
  } else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  } else {
    throw Exception('Failed to load POI');
  }
  return visitedPOIMap;
}




