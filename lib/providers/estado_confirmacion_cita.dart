import 'package:flutter/material.dart';

class EstadoConfirmacionCita extends ChangeNotifier {
  bool _citaconfirmada = false;

  bool get estadoCita => _citaconfirmada;

  setEstadoCita(bool p) async {
    _citaconfirmada = p;
    notifyListeners();
  }
}
