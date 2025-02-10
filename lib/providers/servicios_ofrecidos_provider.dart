import 'package:agendacitas/models/cita_model.dart';
import 'package:flutter/material.dart';

class ServiciosOfrecidosProvider extends ChangeNotifier {
  List<ServicioModelFB> _servicios = <ServicioModelFB>[];
  bool _serviciosCargados = false;

  List<ServicioModelFB> get getServicios => _servicios;

  bool get serviciosCargados => _serviciosCargados;

  void setTodosLosServicios(List<ServicioModelFB> todosLosServicios) {
    _servicios = todosLosServicios;
    _serviciosCargados = true;
    notifyListeners();
  }

  void agregaServicioAlContexto(ServicioModelFB nuevoServicio) {
    if (nuevoServicio.id == null) {
      print("No se agrega el servicio porque su id es null.");
      return;
    }

    bool existe = _servicios.any((servicio) {
      print(
          "Comparando servicio existente con id: ${servicio.id} vs nuevo servicio id: ${nuevoServicio.id}");
      return servicio.id == nuevoServicio.id;
    });

    if (existe) {
      print("El servicio con id ${nuevoServicio.id} ya existe en el contexto.");
      return;
    }

    _servicios.add(nuevoServicio);
    print("Servicio agregado, total de servicios: ${_servicios.length}");
    notifyListeners();
  }

  void eliminaServicioAlContexto(String id) {
    _servicios.removeWhere((element) => element.id == id);

    _serviciosCargados = false;
    notifyListeners();
  }

  void actualizaEstadoDisponibilidadServicioContexto(
      ServicioModelFB servicioEditado, String estadoDisponibilidad) {
    int index =
        _servicios.indexWhere((servicio) => servicio.id == servicioEditado.id);

    if (index != -1) {
      _servicios[index] =
          _servicios[index].copyWith(activo: estadoDisponibilidad);

      _serviciosCargados = false;
      notifyListeners();
    }
  }

  void limpiarServiciosContexto() {
    _servicios = [];
    notifyListeners();
  }

  void reasignacionServicios() {
    _serviciosCargados = false;
    notifyListeners();
  }
}
