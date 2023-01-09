import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  late bool isLogged;
  late String name;
  late String surname;

  UserProvider() {
    isLogged = false;
    name = "";
    surname = "";
  }
}