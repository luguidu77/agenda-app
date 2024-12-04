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
    if (!_citas.any((cita) => cita.id == nuevaCita.id)) {
      _citas.add(nuevaCita); // Solo agrega si no existe ya
      notifyListeners();
    }
  }

  void eliminacitaAlContexto(id) {
    _citas.removeWhere((element) => element.id == id);

    _citasCargadas = false;
    notifyListeners();
  }

  void limpiarCitaContexto() {
    _citas.clear();
    notifyListeners();
  }
}
