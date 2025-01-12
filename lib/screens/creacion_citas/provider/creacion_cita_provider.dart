import 'package:agendacitas/models/cita_model.dart';
import 'package:flutter/material.dart';

class CreacionCitaProvider extends ChangeNotifier {
  CitaModelFirebase _contextoCita = CitaModelFirebase();

  CitaModelFirebase get contextoCita => _contextoCita;

  setContextoCita(CitaModelFirebase edicionContextoCita) {
    // Actualizar solo los campos que no sean null en edicionContextoCita
    _contextoCita = CitaModelFirebase(
      id: edicionContextoCita.id ?? _contextoCita.id,
      dia: edicionContextoCita.dia ?? _contextoCita.dia,
      horaInicio: edicionContextoCita.horaInicio ?? _contextoCita.horaInicio,
      horaFinal: edicionContextoCita.horaFinal ?? _contextoCita.horaFinal,
      comentario: edicionContextoCita.comentario ?? _contextoCita.comentario,
      email: edicionContextoCita.email ?? _contextoCita.email,
      idcliente: edicionContextoCita.idcliente ?? _contextoCita.idcliente,
      idservicio: edicionContextoCita.idservicio ?? _contextoCita.idservicio,
      servicios: edicionContextoCita.servicios ?? _contextoCita.servicios,
      idEmpleado: edicionContextoCita.idEmpleado ?? _contextoCita.idEmpleado,
      nombreEmpleado:
          edicionContextoCita.nombreEmpleado ?? _contextoCita.nombreEmpleado,
      colorEmpleado:
          edicionContextoCita.colorEmpleado ?? _contextoCita.colorEmpleado,
      precio: edicionContextoCita.precio ?? _contextoCita.precio,
      confirmada: edicionContextoCita.confirmada ?? _contextoCita.confirmada,
      tokenWebCliente:
          edicionContextoCita.tokenWebCliente ?? _contextoCita.tokenWebCliente,
      idCitaCliente:
          edicionContextoCita.idCitaCliente ?? _contextoCita.idCitaCliente,
      nombreCliente:
          edicionContextoCita.nombreCliente ?? _contextoCita.nombreCliente,
      fotoCliente: edicionContextoCita.fotoCliente ?? _contextoCita.fotoCliente,
      telefonoCliente:
          edicionContextoCita.telefonoCliente ?? _contextoCita.telefonoCliente,
      emailCliente:
          edicionContextoCita.emailCliente ?? _contextoCita.emailCliente,
      notaCliente: edicionContextoCita.notaCliente ?? _contextoCita.notaCliente,
    );

    notifyListeners();
  }
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

  void limpiarCitaContexto() {
    // _contextoCita = CitaModelFirebase();
    _listaServiciosElegidos = [];
    notifyListeners();
  }

/*   // CONTEXTO citaElegida ############################
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
  } */
}
