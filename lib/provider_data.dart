import 'package:flutter/material.dart';


class Data with ChangeNotifier {

  String myCategory='BusinessNews';

  void changeStringMethod(String newString) {
    myCategory = newString;
    notifyListeners();

  }
}

