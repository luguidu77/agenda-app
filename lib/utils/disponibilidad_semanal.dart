import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class DisponibilidadSemanal {
  static Future<List<int>> disponibilidadSemanal(context, usuarioAP) async {
    List<int> diasNoDisponibles =
        []; //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
    dynamic data;
    try {
      //leer datos de Firebase
      data = await SincronizarFirebase().getDisponibilidadSemanal(usuarioAP);
    } catch (e) {
      debugPrint(e.toString());
    }

    //invoca DispoSemanalProvider
    final dDispoSemanal =
        Provider.of<DispoSemanalProvider>(context, listen: false);

    // SETEAR DISPONIBILIDAD SEMANAL EN CONTEXTO
    dDispoSemanal.setDiasDispibles(data);

    //trae la disponibilidad semanal para el servicio del CONTEXTO PROVIDER

    //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
    Map<String, bool> diasDisp = dDispoSemanal.diasDispibles;

    if (diasDisp['Lunes'] == false) diasNoDisponibles.add(1);
    if (diasDisp['Martes'] == false) diasNoDisponibles.add(2);
    if (diasDisp['Miercoles'] == false) diasNoDisponibles.add(3);
    if (diasDisp['Jueves'] == false) diasNoDisponibles.add(4);
    if (diasDisp['Viernes'] == false) diasNoDisponibles.add(5);
    if (diasDisp['Sabado'] == false) diasNoDisponibles.add(6);
    if (diasDisp['Domingo'] == false) diasNoDisponibles.add(7);
    // ejemplo diasNoDisponibles = [5, 6, 7]
    debugPrint(
        'Dias(nº) de la semana no disponibles (disponibilidadSemanal.dart) ${diasNoDisponibles.toString()}');

    return diasNoDisponibles;
  }
}
