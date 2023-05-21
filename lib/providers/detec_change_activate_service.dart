import 'package:flutter/material.dart';

class DetectChangeActivateService with ChangeNotifier {
  final bool _change = false;

  bool get cambio {
    return _change;
  }

  set cambio(bool newchange) {
    // this._change = !_change;
    notifyListeners();
  }
}
