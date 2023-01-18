import 'package:flutter/material.dart';
import '../model/POI.dart';

class UserProvider extends ChangeNotifier {
  late bool isLogged;
  late String name;
  late String surname;
  late Map<POI, String> visited;
  late bool isDeveloperModeOn;

  UserProvider() {
    isLogged = false;
    name = "";
    surname = "";
    visited = {};
    isDeveloperModeOn = false;
  }
}