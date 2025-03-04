import 'package:agendacitas/models/cita_model.dart';

import 'package:flutter/material.dart';

class CitasProvider extends ChangeNotifier {
  List<CitaModelFirebase> _citas = <CitaModelFirebase>[];
  bool _citasCargadas = false;

  List<CitaModelFirebase> get getCitas => _citas;

  bool get citasCargadas => _citasCargadas;

  void setTodosLasLasCitas(List<CitaModelFirebase> todasLasCitas) {
    _citas = todasLasCitas;
    _citasCargadas = true;
    notifyListeners();
  }

  void agregaCitaAlContexto(CitaModelFirebase nuevaCita) {
    // Si el id de la cita es null, no la agregamos.
    if (nuevaCita.id == null) {
      print("No se agrega la cita porque su id es null.");
      return;
    }

    // Busca si ya existe una cita con el mismo id.
    bool existe = _citas.any((cita) {
      print(
          "Comparando cita existente con id: ${cita.id} vs nueva cita id: ${nuevaCita.id}");
      return cita.id == nuevaCita.id;
    });

    if (existe) {
      print("La cita con id ${nuevaCita.id} ya existe en el contexto.");
      return;
    }

    // Si no existe, la agregamos
    _citas.add(nuevaCita);
    print("Cita agregada, total de citas: ${_citas.length}");
    notifyListeners();
  }

  void eliminacitaAlContexto(String id) {
    _citas.removeWhere((element) => element.id == id);

    _citasCargadas = false;
    notifyListeners();
  }

  void actualizaEstadoConfirmacionCitaContexto(
      CitaModelFirebase citaEditada, bool estadoConfirmacion) {
    int index = _citas.indexWhere((cita) => cita.id == citaEditada.id);

    if (index != -1) {
      _citas[index] = _citas[index].copyWith(confirmada: estadoConfirmacion);

      _citasCargadas = false;
      notifyListeners();
    }
  }

  void limpiarCitaContexto() {
    _citas = [];
    notifyListeners();
  }

  void reasignacionCita() {
    _citasCargadas = true;
    notifyListeners();
  }
}
