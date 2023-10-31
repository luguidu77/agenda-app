import 'package:flutter/material.dart';

class CreacionCitaProvider extends ChangeNotifier {
  // CONTEXTO servicioElegido ############################

/*   Map<String, dynamic> _servicioElegido = {
    'ID': 0,
    'SERVICIO': '',
    'TIEMPO': '',
    'PRECIO': '',
    'DETALLE': '',
  }; */
  List<Map<String, dynamic>> _listaServiciosElegidos = [];

  // Map<String, dynamic> get getServicioElegido => _servicioElegido;

  /*  set setServicioElegido(Map<String, dynamic> nuevoServicio) {
    _servicioElegido = nuevoServicio;
    notifyListeners();
  } */

  List<Map<String, dynamic>> get getServiciosElegidos =>
      _listaServiciosElegidos;

  set setListaServiciosElegidos(
      List<Map<String, dynamic>> nuevoListaServicios) {
    _listaServiciosElegidos = nuevoListaServicios;

    notifyListeners();
  }

  set setAgregaAListaServiciosElegidos(
      List<Map<String, dynamic>> nuevoListaServicios) {
    _listaServiciosElegidos.add(nuevoListaServicios.first);

    notifyListeners();
  }

  set setEliminaItemListaServiciosElegidos(List<Map<String, dynamic>> item) {
    _listaServiciosElegidos.remove(item.first);
    print(item.first);
    notifyListeners();
  }

  // CONTEXTO citaElegida ############################
  Map<String, dynamic> _citaElegida = {
    'FECHA': '',
    'HORAINICIO': '',
    'HORAFINAL': '',
    'COMENTARIO': ''
  };

  Map<String, dynamic> get getCitaElegida => _citaElegida;

  set setCitaElegida(Map<String, dynamic> nuevaCita) {
    _citaElegida = nuevaCita;
    notifyListeners();
  }

  // CONTEXTO clienteElegido ############################
  Map<String, dynamic> _clienteElegido = {
    'ID': '',
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
