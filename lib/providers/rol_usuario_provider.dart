import 'package:agendacitas/models/empleado_model.dart';
import 'package:flutter/material.dart';

class RolUsuarioProvider with ChangeNotifier {
  RolEmpleado _rol = RolEmpleado.personal;

  RolEmpleado get rol => _rol;

  void setRol(RolEmpleado newRol) {
    _rol = newRol;
    notifyListeners();
  }
}

class EmailUsuarioAppProvider with ChangeNotifier {
  String _emailUsuarioApp = '';
  bool _iniciadaSesionUsuario = false;

  String get emailUsuarioApp => _emailUsuarioApp;

  bool get iniciadaSesionUsuario => _iniciadaSesionUsuario;

  void setEmailUsuarioApp(String email) {
    _emailUsuarioApp = email;
    notifyListeners();
  }

  void setIniciadaSesionUsuario(bool estado) {
    _iniciadaSesionUsuario = estado;
    notifyListeners();
  }
}

class EmailAdministradorAppProvider with ChangeNotifier {
  String _emailAdministradorApp = '';
  bool _iniciadaSesionUsuario = false;

  String get emailAdministradorApp => _emailAdministradorApp;

  bool get iniciadaSesionUsuario => _iniciadaSesionUsuario;

  void setEmailAdministradorApp(String email) {
    _emailAdministradorApp = email;
    notifyListeners();
  }

  void setIniciadaSesionUsuario(bool estado) {
    _iniciadaSesionUsuario = estado;
    notifyListeners();
  }
}
