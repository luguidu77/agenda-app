

import 'package:flutter/material.dart';

class DispoSemanalProvider extends ChangeNotifier {
  Map<String, bool> _diasDisp = {
    'Lunes': true,
    'Martes': true,
    'Miercoles': true,
    'Jueves': true,
    'Viernes': true,
    'Sabado': true,
    'Domingo': true
  };
  // diasDisponibles ES LA DATA QUE SE ENVIA AL HACER UN  final diasDisponibles = await Provider.of<DispoSemanalProvider>(context, listen: false);
  Map<String, bool> get diasDispibles => _diasDisp;

  setDiasDispibles(newdisponibles) {
    if (newdisponibles != null) {
      _diasDisp = {
        'Lunes': newdisponibles['Lunes']!,
        'Martes': newdisponibles['Martes']!,
        'Miercoles': newdisponibles['Miercoles']!,
        'Jueves': newdisponibles['Jueves']!,
        'Viernes': newdisponibles['Viernes']!,
        'Sabado': newdisponibles['Sabado']!,
        'Domingo': newdisponibles['Domingo']!,
      };
    }

    notifyListeners();
  }
}
