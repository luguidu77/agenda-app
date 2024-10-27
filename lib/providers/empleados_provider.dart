import 'package:agendacitas/models/empleado_model.dart';
import 'package:flutter/material.dart';

class EmpleadosProvider extends ChangeNotifier {
  final List<EmpleadoModel> _empleados = <EmpleadoModel>[];

  List<EmpleadoModel> get getEmpleados => _empleados;

  void setTodosLosEmpleados(List<EmpleadoModel> todosEmpleados) {
    _empleados.addAll(todosEmpleados);

    notifyListeners();
  }

  void agregaEmpleado(EmpleadoModel empleado) {
    _empleados.add(empleado);
    notifyListeners();
  }
}
