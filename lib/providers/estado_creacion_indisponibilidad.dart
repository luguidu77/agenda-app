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

class HorarioElegidoCarrusel extends ChangeNotifier {
  DateTime _horaInicio = DateTime(0);
  DateTime _horaFin = DateTime(0);

  DateTime get horaInicio => _horaInicio;
  DateTime get horaFin => _horaFin;

  setHoraInicio(DateTime hora) async {
    _horaInicio = hora;
    notifyListeners();
  }

  setHoraFin(DateTime hora) async {
    _horaFin = hora;
    notifyListeners();
  }
}
