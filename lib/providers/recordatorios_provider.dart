import 'package:agendacitas/models/tiempo_record_model.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/material.dart';

class RecordatoriosProvider extends ChangeNotifier {
  List<TiempoRecordatorioModel> tiempoGuardado = [];

  /* bool recordatoriosMode = false;

  bool get isNotificationActivate => recordatoriosMode;

  void toggleRecordatorio(bool isOn) {
    recordatoriosMode = isOn ? false : true;
    notifyListeners();
  } */

  Future<TiempoRecordatorioModel> nuevoTiempo(String tiempo) async {
    final nuevoTiempo = TiempoRecordatorioModel(
      id: 0,
      tiempo: tiempo,
    );

    final id = await DBProvider.db.nuevoTiempoRecordatorio(nuevoTiempo);

    //asinar el ID de la base de datos al modelo
    nuevoTiempo.id = id;

    tiempoGuardado.add(nuevoTiempo);
    notifyListeners();

    return nuevoTiempo;
  }

  Future<List<TiempoRecordatorioModel>> cargarTiempo() async {
    final tiempoGuardado = await DBProvider.db.getTiempoRecordatorios();
    this.tiempoGuardado = [...tiempoGuardado];
    notifyListeners();
    return tiempoGuardado;
  }

  acutalizarTiempo(TiempoRecordatorioModel recordatorio) async {
    await DBProvider.db.actualizarRecordatorio(recordatorio);
  }
}
