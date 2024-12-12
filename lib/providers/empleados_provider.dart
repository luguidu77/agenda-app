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
    print(empleado.id);
    _empleados.add(empleado);
    notifyListeners();
  }

  void modificaEmpleado(EmpleadoModel empleadoEditado) {
    // Verificar el estado actual de la lista
    if (_empleados.isEmpty) {
      print('La lista de empleados está vacía.');
      return;
    }
    // Buscar el índice del empleado a modificar
    final index =
        _empleados.indexWhere((empleado) => empleado.id == empleadoEditado.id);

    if (index != -1) {
      // Actualizar directamente al empleado en la posición encontrada
      _empleados[index] = empleadoEditado;

      // Notificar a los listeners para reflejar los cambios
      notifyListeners();
    } else {
      print('Empleado con ID ${empleadoEditado.id} no encontrado.');
    }
  }
}
