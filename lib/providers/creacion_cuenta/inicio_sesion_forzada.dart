import 'package:flutter/material.dart';

class InicioSesionForzada with ChangeNotifier {
  bool _esInicioSesionForzada = true;

  bool get esInicioSesionForzada => _esInicioSesionForzada;

  void setFuerzaInicio(bool value) {
    _esInicioSesionForzada = value;
    notifyListeners();
  }
}
