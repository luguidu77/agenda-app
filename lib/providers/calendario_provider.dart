import 'package:flutter/material.dart';

class CalendarioProvider extends ChangeNotifier {
  DateTime _fechaSeleccionada = DateTime.now();
  bool _visibleCalendario = false;

  // SELECIONAR LA FECHA
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  setFechaSeleccionada(DateTime fecha) {
    _fechaSeleccionada = fecha;
    notifyListeners();
  }

  incrementaUnDia() {
    _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1));
    notifyListeners();
  }

  decrementaUnDia() {
    _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1));
    notifyListeners();
  }

  // VISIBLE/OCULTAR CALENDARIO
  bool get visibleCalendario => _visibleCalendario;
  set setVisibleCalendario(bool visible) {
    _visibleCalendario = visible;
    notifyListeners();
  }
}
