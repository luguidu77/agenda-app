// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitaListProvider extends ChangeNotifier {
  List<ClienteModel> clientes = [];
  List<CitaModel> citas = [];
  List<ServicioModel> servicios = [];
  String tipoSeleccionado = 'MANO';

  Future<ClienteModel> nuevoCliente(
    String nombre,
    String telefono,
    String email,
    String foto,
    String nota,
  ) async {
    final nuevoCliente = new ClienteModel(
      nombre: nombre.toUpperCase(),
      telefono: telefono,
      email: email,
      foto: foto,
      nota: nota,
    );

    final id = await DBProvider.db.nuevoCliente(nuevoCliente);

    //asinar el ID de la base de datos al modelo
    nuevoCliente.id = id;

    clientes.add(nuevoCliente);
    notifyListeners();

    return nuevoCliente;
  }

//###### CREA CITA Y TRAE ID CITA CREADA EN DISPOSITIVO PARA ID DEL RECORDATORIO
  Future<int> nuevaCita(String dia, String horaInicio, String horaFinal,
      String comentario, idCliente, idServicio) async {
    debugPrint(
        'dia que se graba $dia ---------------------------------------------');
    debugPrint(
        'horainicio que se graba $horaInicio ---------------------------------------------');
    final nuevaCita = new CitaModel(
      dia: dia,
      horaInicio: horaInicio,
      horaFinal: horaFinal,
      comentario: comentario,
      idcliente: idCliente,
      idservicio: idServicio,
    ); //todo: idEmpleado es eventual, con inicio de sesion debe ser real

    final id = await DBProvider.db.nuevaCita(nuevaCita);

    //asinar el ID de la base de datos al modelo
    nuevaCita.id = id;

    citas.add(nuevaCita);
    notifyListeners();

    return id;
  }

  Future<ServicioModel> nuevoServicio(
    String servicio,
    String tiempo,
    double precio,
    String detalle,
    String activo,
  ) async {
    final nuevoServicio = new ServicioModel(
      servicio: servicio,
      tiempo: tiempo,
      precio: precio,
      detalle: detalle,
      activo: activo,
    );

    final id = await DBProvider.db.nuevoServicio(nuevoServicio);

    //asinar el ID de la base de datos al modelo
    nuevoServicio.id = id;

    servicios.add(nuevoServicio);
    notifyListeners();

    return nuevoServicio;
  }

  acutalizarServicio(ServicioModel servicio) async {
    await DBProvider.db.acutalizarServicio(servicio);
  }

  actualizarCita(CitaModel cita) async {
    await DBProvider.db.actualizarCita(cita);
  }

  cargarCitas() async {
    final citas = await DBProvider.db.getTodasLasCitas();
    this.citas = [...citas];
    notifyListeners();
    return citas;
  }

  List<Map<String, dynamic>> data = [];

  // List<ClienteModel> cientes = [];
  ClienteModel _cliente = ClienteModel();
  ServicioModel _servicio = ServicioModel();
  int? clienteID;
  int? servicioID;
  cargarCitasPorFecha(String fecha) async {
    List<CitaModel> citas =
        await DBProvider.db.getCitasHoraOrdenadaPorFecha(fecha);

    for (var item in citas) {
      if (item.idcliente != 999) {
        _cliente = await DBProvider.db.getCientePorId(item.idcliente!);
        clienteID = _cliente.id;
        _servicio = await DBProvider.db.getServicioPorId(item.idservicio!);
        servicioID = _servicio.id;
      } else {
        servicioID = 999;
        clienteID = 999;
      }

      data.add({
        'id': item.id,
        'comentario': item.comentario,
        'horaInicio': item.horaInicio,
        'horaFinal': item.horaFinal,
        'nombre': _cliente.nombre,
        'telefono': _cliente.telefono,
        'email': _cliente.email,
        'idServicio': servicioID,
        'servicio': _servicio.servicio,
        'precio': _servicio.precio,
        'detalle': _servicio.detalle,
        'idCliente': clienteID,
        'foto': _cliente.foto
      });
    }

    //  this.data = [...data];
    //print(data.toString());

    // notifyListeners();

    return data;
  }

  leerBasedatosDispositivo(fechaElegida) async {
    List<Map<String, dynamic>> citas = [];
    //?comprueba si hay servicios grabados, no los hay los lleva a pagina bienvenida CREAR TU PRIMER SERVICIO
    //todo: REALIZAR introduction_screen Y USAR LOCALSTORE PARA GUARDAR SI ES LA PRIMERA INSTALACION
    //List<ServicioModel> listaservicios =
    //    await CitaListProvider().cargarServicios();
    // if (listaservicios.isEmpty) _irPaginaServicios();

    //? CARGA CITAS POR FECHA ELEGIDA

    citas = await CitaListProvider().cargarCitasPorFecha(fechaElegida);

    //?CREA NUEVA LISTA citas ORDENADAS POR hora de inicio
    citas.sort((a, b) {
      return DateTime.parse(a['horaInicio'])
          .compareTo(DateTime.parse(b['horaInicio']));
    });
    print(' citas traidas desde dispositivo $citas');
    return citas;
  }

  Future<String> calculaGananciasDiarias(
      List<Map<String, dynamic>> citas) async {
    await Future.delayed(const Duration(seconds: 1));

    //precio total diario
    double gananciaDiaria = 0;
    List<Map<String, dynamic>> aux = citas;

    List precios = aux.map((value) {
      return value['precio'];
    }).toList();

    for (var element in precios) {
      if (element != null) {
        gananciaDiaria = gananciaDiaria + element;
      }
    }

    String gananciaD = '';
    // Formatear el número con dos decimales
    if (gananciaDiaria != 0.0) {
      gananciaD = NumberFormat("#.00").format(gananciaDiaria);
    } else {
      gananciaD = '0.00';
    }

    return gananciaD.toString();
  }

  cargarCitasPorCliente(int cliente) async {
    List<CitaModel> citas = await DBProvider.db.getCitasPorCliente(cliente);
    // print(citas.map((e) => e.horaInicio));
    for (var item in citas) {
      _cliente = await DBProvider.db.getCientePorId(item.idcliente!);
      _servicio = await DBProvider.db.getServicioPorId(item.idservicio!);

      data.add({
        'id': item.id,
        'dia': item.dia,
        'nombre': _cliente.nombre,
        'servicio': _servicio.servicio,
        'precio': _servicio.precio,
        'detalle': _servicio.detalle,
        'idCliente': _cliente.id
      });
    }

    notifyListeners();
    return data;
  }

  cargarServiciosPorCliente(int cliente) async {
    List<CitaModel> servicios = await DBProvider.db.getCitasPorCliente(cliente);
    notifyListeners();
    return servicios;
  }

  cargarCitasAnual(String fecha) async {
    var anual = fecha.split('-')[0]; //año de fecha buscada
    int idServicio = 0;
    List<CitaModel> citas = await DBProvider.db.getTodasLasCitas();
    print(citas.map((e) => e.idservicio));
    for (var item in citas) {
      String fecha0 = item.dia.toString(); // todos los dias
      // si la fecha anul coincide con el año de las citas, trae sus servicios para rescatar el precio
      if (fecha0.split('-')[0] == anual) {
        idServicio = item.idservicio!;
        if (idServicio != 999) {
          // DESECHAMOS LOS SERVICIOS CON ID = 999 (CITAS NO DISPONIBLES)
          _servicio = await DBProvider.db.getServicioPorId(idServicio);
        }

        data.add({
          'id': item.id!,
          'fecha': fecha0,
          'precio': _servicio.precio,
        });
      }
    }

    //notifyListeners();

    return data;
  }

  eliminaTodosLasCitas() async {
    await DBProvider.db.eliminaTodoslasCitas();
  }

  cargarServicioPorId(int id) async {
    final servicios = await DBProvider.db.getServicioPorId(id);
    //  this.servicios = [...servicios];
    notifyListeners();
    return servicios;
  }

  cargarServicios() async {
    final servicios = await DBProvider.db.getTodoslosServicios();
    this.servicios = [...servicios];
    notifyListeners();
    return servicios;
  }

  cargarClientes() async {
    final clientes = await DBProvider.db.getTodosLosClientes();
    this.clientes = [...clientes];
    notifyListeners();
    return clientes;
  }

  cargarClientePorTelefono(String telefono) async {
    final clientes = await DBProvider.db.getCientePorTelefono(telefono);
    this.clientes = [...clientes];
    notifyListeners();

    return clientes;
  }

  elimarCita(int id) async {
    await DBProvider.db.eliminarCita(id);
  }

  eliminaTodosLosServicios() async {
    await DBProvider.db.eliminaTodoslosServicios();
  }

  elimarServicio(int id) async {
    await DBProvider.db.eliminarServicio(id);
  }

  eliminaTodosLosClientes() async {
    await DBProvider.db.eliminaTodoslosClientes();
  }

  elimarCliente(int id) async {
    await DBProvider.db.eliminarCliente(id);
  }

  acutalizarCliente(ClienteModel cliente) async {
    await DBProvider.db.actualizarCliente(cliente);
  }

//! CONTEXTO clientaElegida
  Map<String, dynamic> _clientaElegida = {
    'ID': 0,
    'NOMBRE': '',
    'TELEFONO': '',
    'EMAIL': '',
    'FOTO': '',
  };

  Map<String, dynamic> get getClientaElegida => _clientaElegida;

  set setClientaElegida(Map<String, dynamic> nuevoCliente) {
    _clientaElegida = nuevoCliente;
    notifyListeners();
  }

//! CONTEXTO servicioElegido
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

  //! CONTEXTO citaElegida
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
}
