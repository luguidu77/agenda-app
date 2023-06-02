import 'package:flutter/material.dart';

import '../providers/providers.dart';

/* 
 LEE DE FIREBASE LA DISPONIBILIDAD Y ESOS DATOS RECIBIDOS LOS SETEA EN EL PROVIDER DE DISPONIVILIDAD(dispo_semanal_provider.dart) 
 */

class DisponibilidadSemanal {
  static Future<List<int>> disponibilidadSemanal(
      dDispoSemanal, usuarioAP) async {
    List<int> diasNoDisponibles =
        []; //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
    dynamic data;
    try {
      //leer datos de Firebase
      data = await SincronizarFirebase().getDisponibilidadSemanal(usuarioAP);
    } catch (e) {
      debugPrint(e.toString());
    }

    //invocado DispoSemanalProvider desde la peticion (dDispoSemanal)  final dDispoSemanal = context.read<DispoSemanalProvider>();
    // SETEAR DISPONIBILIDAD SEMANAL EN EL PROVIDER
    dDispoSemanal.setDiasDispibles(data);

    return diasNoDisponibles;
  }
}
