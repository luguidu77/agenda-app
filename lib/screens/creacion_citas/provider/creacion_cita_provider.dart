import 'package:flutter/material.dart';

class CreacionCitaProvider extends ChangeNotifier {
  // CONTEXTO servicioElegido ############################
  Map<String, dynamic> _servicioElegido = {
    'ID': 0,
    'SERVICIO': '',
    'TIEMPO': '',
    'PRECIO': '',
    'DETALLE': '',
  };

  Map<String, dynamic> get getServicioElegido => _servicioElegido;

  set setServicioElegido(Map<String, dynamic> nuevoServicio) {
    _servicioElegido = nuevoServicio;
    notifyListeners();
  }

  // CONTEXTO citaElegida ############################
  Map<String, dynamic> _citaElegida = {
    'FECHA': '',
    'HORAINICIO': '',
    'HORAFINAL': '',
  };

  Map<String, dynamic> get getCitaElegida => _citaElegida;

  set setCitaElegida(Map<String, dynamic> nuevaCita) {
    _citaElegida = nuevaCita;
    notifyListeners();
  }

  // CONTEXTO clienteElegido ############################
  Map<String, dynamic> _clienteElegido = {
    'NOMBRE': '',
    'TELEFONO': '',
    'EMAIL': '',
    'FOTO': '',
    'NOTA': ''
  };

  Map<String, dynamic> get getClienteElegido => _clienteElegido;

  set setClienteElegido(Map<String, dynamic> nuevoCliente) {
    _clienteElegido = nuevoCliente;
    notifyListeners();
  }
}
