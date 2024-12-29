import 'package:flutter/material.dart';

// este provider se encarga de verificar si se ha reasignado una cita
// para los antiguios usuarios que tenian la app instalada

class ComprobacionReasignacionCitas with ChangeNotifier {
  bool _reasignado = true;

  bool get estadoReasignado {
    return _reasignado;
  }

  setReasignado(bool reasignado) {
    _reasignado = reasignado;
    notifyListeners();
  }
}
