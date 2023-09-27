import 'package:flutter/material.dart';

class FormularioBusqueda extends ChangeNotifier {
  String _texto = '';

  String get textoBusqueda => _texto;
  set setTextoBusqueda(String visible) {
    _texto = visible;
    notifyListeners();
  }
}
