import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

/* 
 LEE DE FIREBASE LA DISPONIBILIDAD Y ESOS DATOS RECIBIDOS LOS SETEA EN EL PROVIDER DE DISPONIVILIDAD(dispo_semanal_provider.dart) 
 */

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

    // SETEAR DISPONIBILIDAD SEMANAL EN EL PROVIDER
    dDispoSemanal.setDiasDispibles(data);

    return diasNoDisponibles;
  }
}
