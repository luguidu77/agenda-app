import 'package:flutter/material.dart';

class ButtomNavNotificacionesProvider extends ChangeNotifier {
  int _contador = 0;

  int get contadorNotificaciones => _contador;

  setContadorNotificaciones(int num) async {
    _contador = num;
    notifyListeners();
  }
}
