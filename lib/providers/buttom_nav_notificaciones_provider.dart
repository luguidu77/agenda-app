import 'package:flutter/material.dart';

class ButtomNavNotificacionesProvider extends ChangeNotifier {
  int _contador = 0;
  int _recordatorios = 0;
  int _citaweb = 0;
  int _administrador = 0;

  int get contadorNotificaciones => _contador;
  int get contadorNotificacionesRecordatorio => _recordatorios;
  int get contadorNotificacionesCitaweb => _citaweb;
  int get contadorNotificacionesAdministrador => _administrador;

  setContadorNotificaciones(
      int num, int recordatorios, int citaweb, int administrador) async {
    _contador = num;
    _recordatorios = recordatorios;
    _citaweb = citaweb;
    _administrador = administrador;
    notifyListeners();
  }
}
