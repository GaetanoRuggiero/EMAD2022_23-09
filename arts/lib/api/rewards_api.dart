import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env/env.dart';
import '../exception/exceptions.dart';
import '../model/reward.dart';

Future<Reward> getRewardById(String id) async {
  Uri uri = Uri(
      scheme: 'http',
      host: Env.serverIP,
      port: Env.serverPort,
      path: '/rewards/findById',
      queryParameters: {'id' : id}
  );
  debugPrint("Calling $uri");

  final response = await http
      .get(uri)
      .timeout(const Duration(seconds: 4), onTimeout: () {
    return http.Response('Timeout', 500);
  })
      .onError((error, stackTrace) {
    debugPrint(error.toString());
    return http.Response('Server unreachable', 500);
  });

  if (response.statusCode == 200) {
    Reward reward = Reward.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    return reward;
  }
  else if (response.statusCode == 500) {
    throw ConnectionErrorException("Server did not respond at: $uri\nError: HTTP ${response.statusCode}: ${response.body}");
  }
  else {
    throw Exception('Failed to load Rewards');
  }
}