import 'package:flutter/material.dart';

class BotonAgregarIndisponibilidadProvider extends ChangeNotifier {
  bool _botonPulsado = false;

  bool get botonPulsado => _botonPulsado;

  setBotonPulsadoIndisponibilidad(bool p) async {
    _botonPulsado = p;
    notifyListeners();
  }
}

class FechaElegida extends ChangeNotifier {
  DateTime _fechaElegida = DateTime(0);

  DateTime get fechaElegida => _fechaElegida;

  setFechaElegida(DateTime hora) async {
    _fechaElegida = hora;
    notifyListeners();
  }
}

class HoraFinCarrusel extends ChangeNotifier {
  DateTime _horaFin = DateTime(0);

  DateTime get horaFin => _horaFin;

  setHoraFin(DateTime hora) async {
    _horaFin = hora;
    notifyListeners();
  }
}
