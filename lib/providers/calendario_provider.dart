import 'package:flutter/material.dart';

class CalendarioProvider extends ChangeNotifier {
  DateTime _fechaSeleccionada = DateTime.now();
  bool _visibleCalendario = false;

  // SELECIONAR LA FECHA
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  set setFechaSeleccionada(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
  }

  // VISIBLE/OCULTAR CALENDARIO
  bool get visibleCalendario => _visibleCalendario;
  set setVisibleCalendario(bool visible) {
    _visibleCalendario = visible;
    notifyListeners();
  }
}
