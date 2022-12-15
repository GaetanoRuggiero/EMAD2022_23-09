import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:arts/model/vision_response.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';

Future<GoogleVisionResponse?> getVisionResults(String imageBase64) async {
  final String apiKey = Env.apiKey;
  const String apiType = "WEB_DETECTION";
  const int maxResults = 5;
  final request = {
    "requests": [
      {
        "image": {"content": imageBase64},
        "features": [
          {"maxResults": maxResults, "type": apiType},
        ]
      }
    ]
  };
  final headers = <String, String> {
    "Content-Type": "application/json; charset=utf-8"
  };
  Uri uri = Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey');
  final http.Response response = await http
      .post(uri, headers: headers, body: jsonEncode(request))
      .timeout(const Duration(seconds: 4), onTimeout: () {
        return http.Response('Timeout', 500);
      })
      .onError((error, stackTrace) {
        debugPrint(error.toString());
    return http.Response('Server unreachable', 500);
  });
  if (response.statusCode == 200) {
    return GoogleVisionResponse.fromJson(jsonDecode(response.body));
  }
  else if (response.statusCode == 500) {
    return null;
  }
  else {
    throw Exception("Failure! Couldn't make the call to Google Vision.");
  }
}