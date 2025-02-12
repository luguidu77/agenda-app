import 'package:agendacitas/models/empleado_model.dart';
import 'package:flutter/material.dart';

class EmpleadosProvider extends ChangeNotifier {
  final List<EmpleadoModel> _empleados = <EmpleadoModel>[];
  final List<EmpleadoModel> _empleadosStaff = <EmpleadoModel>[];
  late EmpleadoModel _empleadoRegistro; // al registrarse un empleado

  bool _empleadosCargados = false; // bandera empleados cargados

  List<EmpleadoModel> get getEmpleados => _empleados;
  List<EmpleadoModel> get getEmpleadosStaff => _empleadosStaff;
  //registrandose un empleado obtengo sus datos
  EmpleadoModel get getEmpleadoRegistro => _empleadoRegistro;

  bool get empleadosCargados => _empleadosCargados;

  void setTodosLosEmpleados(List<EmpleadoModel> todosEmpleados) {
    _empleados.addAll(todosEmpleados); // carga todos los empleados

    // filtra los empleadosStaff que su rol sea personal
    List<EmpleadoModel> empleadosStaff = todosEmpleados
        .where((e) => e.roles.contains(RolEmpleado.personal))
        .toList();

    _empleadosStaff.addAll(empleadosStaff); // carga los roles personal

    _empleadosCargados = true; // bandera carga de empleados

    notifyListeners();
  }

  void agregaEmpleado(EmpleadoModel empleado) {
    print(empleado.id);
    _empleados.add(empleado);

    /* if (empleado.roles.contains(RolEmpleado.personal)) {
      _empleadosStaff.add(empleado);
    } */

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

  void setEmpleadosStaff() {
    _empleadosStaff.clear();
    // filtra los empleadosStaff que su rol sea personal
    List<EmpleadoModel> empleadosStaff = _empleados
        .where((e) => e.roles.contains(RolEmpleado.personal))
        .toList();

    _empleadosStaff.addAll(empleadosStaff); // carga los roles personal

    notifyListeners();
  }

  void setEmpleadoRegistro(EmpleadoModel empleado) {
    _empleadoRegistro = empleado;
    notifyListeners();
  }

  void modificaEmpleadoRegistro(
      {String? nombre, String? email, String? telefono}) {
    if (nombre != null) {
      _empleadoRegistro.nombre = nombre;
    }
    if (email != null) {
      _empleadoRegistro.email = email;
    }
    if (telefono != null) {
      _empleadoRegistro.telefono = telefono;
    }
    notifyListeners();
  }
}
