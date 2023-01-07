import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  late bool _isLogged;

  bool get isLogged => _isLogged;

  set isLogged(bool value) {
    _isLogged = value;
    notifyListeners();
  }

  UserProvider(bool value) {
    _isLogged = value;
  }
}