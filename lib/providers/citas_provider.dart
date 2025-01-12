import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
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
    if (!_citas
        .any((cita) => cita.id == nuevaCita.id || nuevaCita.id == null)) {
      _citas.add(nuevaCita); // Solo agrega si no existe ya
      // _citasCargadas = false;
      notifyListeners();
    }
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
    _citasCargadas = false;
    notifyListeners();
  }
}
