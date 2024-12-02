import 'package:agendacitas/models/empleado_model.dart';
import 'package:flutter/material.dart';

class EmpleadosProvider extends ChangeNotifier {
  final List<EmpleadoModel> _empleados = <EmpleadoModel>[];
  bool _empleadosCargados = false;

  List<EmpleadoModel> get getEmpleados => _empleados;

  bool get empleadosCargados => _empleadosCargados;

  void setTodosLosEmpleados(List<EmpleadoModel> todosEmpleados) {
    _empleados.addAll(todosEmpleados);
    _empleadosCargados = true;
    notifyListeners();
  }

  void agregaEmpleado(EmpleadoModel empleado) {
    _empleados.add(empleado);
    notifyListeners();
  }
}
