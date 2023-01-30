import 'package:flutter/material.dart';
import '../model/POI.dart';

class UserProvider extends ChangeNotifier {
  late bool isLogged;
  late String name;
  late String surname;
  late Map<POI, String> visited;
  late bool isDeveloperModeOn;
  late bool isPartner;
  late int rewardsAdded;
  late String category;
  late int ongoingRewards;

  UserProvider() {
    isLogged = false;
    name = "";
    surname = "";
    visited = {};
    isDeveloperModeOn = false;
    isPartner = false;
    rewardsAdded = 0;
    category = "";
    ongoingRewards = 0;
  }

  void logout() {
    isLogged = false;
    name = "";
    surname = "";
    visited = {};
    isDeveloperModeOn = false;
    isPartner = false;
    rewardsAdded = 0;
    category = "";
    ongoingRewards = 0;
  }

  void incrementRewardCount() {
    rewardsAdded++;
    ongoingRewards++;
    notifyListeners();
  }
}