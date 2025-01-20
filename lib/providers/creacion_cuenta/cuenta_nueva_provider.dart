import 'package:flutter/material.dart';

class CuentaNuevaProvider with ChangeNotifier {
  bool _esCuentaNueva = true;

  bool get esCuentaNueva => _esCuentaNueva;

  void setCuentaNueva(bool value) {
    _esCuentaNueva = value;
    notifyListeners();
  }
}
