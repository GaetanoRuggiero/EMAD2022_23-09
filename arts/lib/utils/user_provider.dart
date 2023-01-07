import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  late bool isLogged;

  UserProvider() {
    isLogged = false;
  }
}