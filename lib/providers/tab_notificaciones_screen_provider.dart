import 'package:flutter/material.dart';

class TabNotifiacionesScreenProvider extends ChangeNotifier {
  int _tap = 0;

  int get getTap => _tap;

  setTap(int num) {
    _tap = num;
    notifyListeners();
  }
}
