import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../model/user.dart';

Future<Type?> getUser() async {
  Uri uri = Uri(
      scheme: 'http', host: Env.serverIP, port: Env.serverPort, path: 'users');
  debugPrint("Calling $uri");

  User user;
  final response =
      await http.get(uri).timeout(const Duration(seconds: 4), onTimeout: () {
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
      User user = User.fromJson(x);
    }
  } else if (response.statusCode == 500) {
    return null;
  } else {
    throw Exception('Failed to load POI');
  }
  return User;
}

Future<bool> loginUser(String email, String password) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/login');
  final body = {'email': email, 'password': password};

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
    return false;
  } else {
    throw Exception('Failed');
  }
  debugPrint("Wrong credentials for: email: $email and password: $password");
  return false;
}

Future<bool> signUpUser(String name, String surname, String email, String password) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: 'users/signUp');
  final body = {'name': name, 'surname': surname, 'email': email, 'password': password};

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
    return false;
  } else {
    throw Exception('Failed');
  }
  return false;
}

//TODO:Future<bool> checkTokenValidity() async {}
