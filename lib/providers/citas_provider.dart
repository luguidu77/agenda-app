import 'package:agendacitas/models/cita_model.dart';
import 'package:flutter/material.dart';

class CitasProvider extends ChangeNotifier {
  final List<CitaModelFirebase> _citas = <CitaModelFirebase>[];
  bool _citasCargadas = false;

  List<CitaModelFirebase> get getCitas => _citas;

  bool get citasCargadas => _citasCargadas;

  void setTodosLasLasCitas(List<CitaModelFirebase> todasLasCitas) {
    _citas.addAll(todasLasCitas);
    _citasCargadas = true;
    notifyListeners();
  }

  void agregaCitaAlContexto(CitaModelFirebase cita) {
    _citas.add(cita);
    notifyListeners();
  }

  void eliminacitaAlContexto(id) {
    _citas.removeWhere((element) => element.id == id);

    _citasCargadas = false;
    notifyListeners();
  }
}
