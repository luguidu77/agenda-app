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

  Map<String, bool> get diasDispibles => _diasDisp;

/* 
    para leer Disponibilidad semanal provider
    final disponibilidadSemanalProvider = context.read/watch<DispoSemanalProvider>().diasNoDisponibles;
    devuelve => ejemplo disponibilidadSemanalProvider = {5, 6, 7}
 */
  Set<int> diasNoDisponibles =
      {}; //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7

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

    diasNoDisponibles.clear(); //limpia el Set

    //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
    if (_diasDisp['Lunes'] == false) diasNoDisponibles.add(1);
    if (_diasDisp['Martes'] == false) diasNoDisponibles.add(2);
    if (_diasDisp['Miercoles'] == false) diasNoDisponibles.add(3);
    if (_diasDisp['Jueves'] == false) diasNoDisponibles.add(4);
    if (_diasDisp['Viernes'] == false) diasNoDisponibles.add(5);
    if (_diasDisp['Sabado'] == false) diasNoDisponibles.add(6);
    if (_diasDisp['Domingo'] == false) diasNoDisponibles.add(7);

    notifyListeners();
  }
}
