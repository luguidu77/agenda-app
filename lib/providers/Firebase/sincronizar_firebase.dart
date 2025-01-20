import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../db_provider.dart';
import '../providers.dart';

//todo sincronizacion primera vez que se hace de pago para subir todo a Firebase

class SincronizarFirebase {
  FirebaseFirestore? db;
  ServicioModel servicio = ServicioModel();

  List listaClientes = [];

  List<ClienteModel> clientesFB = [];

//? UPLOAD: RESPALDO A FIREBASE CON LOS DATOS DEL DISPOSITIVO
  sincronizaSubeFB(usuarioAPP) async {
    debugPrint('sincronizando SUBIENDO datos a firebase');
    await _iniFirebase();

    // await _actualizaClientes(usuarioAPP, 'UPLOAD');

    // await _actualizaCitas(usuarioAPP, 'UPLOAD');

    // await _actualizaServicios(usuarioAPP, 'UPLOAD');

    //await _actualizaPago(usuarioAPP, 'UPLOAD');

    await _configCamposPerfilUsuarioApp(usuarioAPP, 'UPLOAD');

    await _configCategoriaServicios(usuarioAPP);

    await _disponibilidadSemanal(usuarioAPP, 'UPLOAD');

    await _personaliza(usuarioAPP, 'UPLOAD');

    await _empleados(usuarioAPP, 'UPLOAD');

    debugPrint('FIN sincronizando SUBIENDO datos a firebase');
  }

//? DOWNLOAD: RESTABLECE EL DISPOSITIVO CON LOS DATOS DE FIREBASE
  sincronizaDescargaDispositivo(usuarioAPP) async {
    debugPrint('sincronizando DESCARGANDO datos a firebase');
    await _iniFirebase();

    await _actualizaClientes(usuarioAPP, 'DOWNLOAD');

    await _actualizaCitas(usuarioAPP, 'DOWNLOAD');

    await _actualizaServicios(usuarioAPP, 'DOWNLOAD');

    await _actualizaPago(usuarioAPP, 'DOWNLOAD');

    debugPrint('FIN sincronizando DESCARGANDO datos a firebase');
  }

  //?INICIALIZA FIREBASE //////////////////////////////////////////
  _iniFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    db = FirebaseFirestore.instance;
  }

  //? REFERENCIA DOCUMENTO ////////////////////////////////////////////
  _referenciaDocumento(String usuarioAPP, String coleccion) async {
    // creo una referencia al documento que contiene los clientes
    final docRef = db!
        .collection("agendacitasapp")
        .doc(usuarioAPP) //email usuario
        .collection(coleccion); // pago, servicio, cliente,...
    // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

    return docRef;
  }

//? CONFIGURA LOS CAMPOS DE FIREBASE - perfilUsuarioApp si no existen ////////////////////////////////////////////
//? foto, denominacion, descripcion ,... ////////////////////////////////////////////
  _configCamposPerfilUsuarioApp(String usuarioAPP, String updown) async {
    try {
      ///* NUEVA UBICACION DEL PERFIL DE USUARIO
      final docRefNuevo = db!.collection("agendacitasapp").doc(usuarioAPP);
      await docRefNuevo.get().then((data) async {
        if (data.data() == null) {
          await docRefNuevo.set({
            'foto': '',
            'denominacion': '',
            'descripcion': '',
            'telefono': '',
            'website': 'agendadecitas.online',
            'facebook': '',
            'instagram': '',
            'ubicacion': '',
            'email': usuarioAPP,
            'registro': DateTime.now(),
            'pago': false,
          });
        }
      });
    } catch (e) {}
  }

  // CREA ESTRUCTURA DE DISPONIBILIDAD SEMANAL
  _disponibilidadSemanal(String usuarioAPP, String updown) async {
    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'disponibilidad');
    try {
      // si no existen perfilUsuarioApp lo crea con los campos correspondientes
      await docRef.doc('perfilUsuarioApp').get().then((data) async {
        if (data.data() == null) {
          await docRef.doc('Semanal').set({
            'Lunes': true,
            'Martes': true,
            'Miercoles': true,
            'Jueves': true,
            'Viernes': true,
            'Sabado': true,
            'Domingo': true,
          });
        }
      });
    } catch (e) {}
  }

  // CREA ESTRUCTURA DE PERSONALIZA (MENSAJES CONFIRMACION DE CITAS...)
  _personaliza(String usuarioAPP, String updown) async {
    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'personaliza');
    try {
      // si no existen perfilUsuarioApp lo crea con los campos correspondientes
      await docRef.doc('perfilUsuarioApp').get().then((data) async {
        if (data.data() == null) {
          await docRef.doc('mensajeCita').set({
            'mensaje':
                '📢Hola \$cliente,%su cita ha sido reservada con \$denominacion para el día \$fecha h.%Servicio a realizar : \$servicio.%%🙏Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.%%Telefono: \$telefono%Web: \$web%Facebook: \$facebook%Instagram: \$instagram%Dónde estamos: \$ubicacion%',
          });
        }
      });
    } catch (e) {}
  }

  // CREA ESTRUCTURA EMPLEADOS AGREGANDO A LA USUARIO COMO PERSONAL
  _empleados(usuarioAPP, String updown) async {
    //referencia al documento
    final collectionRef = await _referenciaDocumento(usuarioAPP, 'empleados');
    try {
      // si no existen empleados lo crea con los campos correspondientes

      await collectionRef.add({
        'categoriaServicios': [],
        'cod_verif': 'verificado',
        'color': 4294901760,
        'disponibilidadSemanal': [],
        'email': usuarioAPP,
        'emailUsuarioApp': usuarioAPP,
        'foto': '',
        'nombre': '',
        'rol': ['administrador', 'gerente', 'personal'],
        'telefono': '',
      });
    } catch (e) {
      print('error estructura empleados $e');
    }
    ;
  }

  //? SINCRONIZA CLIENTES ////////////////////////////////////////////
  _actualizaClientes(String usuarioAPP, String updown) async {
    List<Map<String, dynamic>> clientesDispositivo = [];
    List<ClienteModel> listaAux = [];
    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'cliente');

    if (updown == 'UPLOAD') {
      // sube los clientes del telefono a firebase
      listaAux = await CitaListProvider().cargarClientes();

      clientesDispositivo = listaAux
          .map((e) => {
                'id': e.id,
                'nombre': e.nombre,
                'telefono': e.telefono,
                'email': e.email,
                'foto': e.foto,
                'nota': e.nota
              })
          .toList();
      print('clientes en el telefono :$clientesDispositivo');

      for (var cliente in clientesDispositivo) {
        final id = cliente['id'];
        Map<String, dynamic> data = {
          'nombre': cliente['nombre'],
          'telefono': cliente['telefono'],
          'email': cliente['email'],
          'foto': cliente['foto'],
          'nota': cliente['nota'],
        };

        await docRef.doc(id.toString()).set(data);
      }

      // for (var cliente in listaClientes) {}
    } else {
      // descarga los datos de firebase al dispositivo
      //? TRAIGO LOS DATOS DE FIREBASE

      List data = await docRef.get().then((value) => value.docs
          .map((e) => {
                'id': e['id'],
                'nombre': e['nombre'],
                'telefono': e['telefono'],
                'email': e['email'],
                'foto': e['foto'],
                'nota': e['nota']
              })
          .toList());

//?elimina todos los clientes
      await CitaListProvider().eliminaTodosLosClientes();

//?crea CLIENTES en dispositivo desde firebase

      for (var y = 0; y < data.length; y++) {
        // print(x.toString());
        String nombre = data[y]['nombre'];
        String telefono = data[y]['telefono'];
        String email = data[y]['email'];
        String foto = data[y]['foto'];
        String nota = data[y]['nota'];

        print('clientes en firebase :$nombre');
        await CitaListProvider()
            .nuevoCliente(nombre, telefono, email, foto, nota);
      }
    }
  }

  //? SINCRONIZA CITAS ////////////////////////////////////////////////
  _actualizaCitas(String usuarioAPP, String updown) async {
    List citasDispositivo = [];
    List<CitaModel> listaAux = [];

    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'cita');

    if (updown == 'UPLOAD') {
      listaAux = await CitaListProvider().cargarCitas();

      citasDispositivo = listaAux
          .map((e) => {
                'id': e.id,
                'dia': e.dia,
                'horaInicio': e.horaInicio,
                'horaFinal': e.horaFinal,
                'comentario': e.comentario,
                'idcliente': e.idcliente,
                'idservicio': e.idservicio,
              })
          .toList();
      print('citas en el telefono :$citasDispositivo');

      for (var cita in citasDispositivo) {
        final id = cita['id'];

        final idServicio = cita['idservicio'];
        if (idServicio != 999) {
          // DESECHAMOS LOS SERVICIOS CON ID = 999 (CITAS NO DISPONIBLES)
          servicio = await DBProvider.db.getServicioPorId(idServicio);
        }

        Map<String, dynamic> data = {
          'dia': cita['dia'],
          'horaInicio': cita['horaInicio'],
          'horaFinal': cita['horaFinal'],
          'comentario': cita['comentario'],
          'idcliente': idServicio == 999 ? '999' : cita['idcliente'].toString(),
          'idservicio':
              idServicio == 999 ? '999' : cita['idservicio'].toString(),
          'idempleado': 'idEmpleado',
          'precio': idServicio == 999 ? '' : servicio.precio.toString(),
        };

        await docRef.doc(id.toString()).set(data);
      }
    } else {
      // descarga los datos de firebase al dispositivo
      //? TRAIGO LOS DATOS DE FIREBASE

      List data = await docRef.get().then((value) => value.docs
          .map((e) => {
                'id': e['id'],
                'dia': e['dia'],
                'horaInicio': e['horaInicio'],
                'horaFinal': e['horaFinal'],
                'comentario': e['comentario'],
                'idcliente': e['idcliente'],
                'idservicio': e['idservicio'],
              })
          .toList());

//?elimina todos los CITAS
      await CitaListProvider().eliminaTodosLasCitas();

//?crea CITAS en dispositivo desde firebase

      for (var y = 0; y < data.length; y++) {
        // print(x.toString());
        String dia = data[y]['dia'];
        String horaInicio = data[y]['horaInicio'];
        String horaFinal = data[y]['horaFinal'];
        String comentario = data[y]['comentario'];
        int idcliente = data[y]['idcliente'];
        int idservicio = data[y]['idservicio'];
        print('citas en firebase :$dia');
        await CitaListProvider().nuevaCita(
            dia, horaInicio, horaFinal, comentario, idcliente, idservicio);
      }
    }
  }

  //? SINCRONIZA SERVICIOS ////////////////////////////////////////////
  _actualizaServicios(String usuarioAPP, String updown) async {
    List serviciosDispositivo = [];
    List<ServicioModel> listaAux = [];
    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'servicio');

    if (updown == 'UPLOAD') {
      listaAux = await CitaListProvider().cargarServicios();

      serviciosDispositivo = listaAux
          .map((e) => {
                'id': e.id,
                'servicio': e.servicio,
                'tiempo': e.tiempo,
                'precio': e.precio,
                'detalle': e.detalle,
                'activo': e.activo,
                'categoria': 'sincategoria',
                'index': 1
              })
          .toList();
      print('servicios en el telefono :$serviciosDispositivo');

      for (var servicio in serviciosDispositivo) {
        final id = servicio['id'];
        Map<String, dynamic> data = {
          'servicio': servicio['servicio'],
          'tiempo': servicio['tiempo'],
          'precio': servicio['precio'],
          'detalle': servicio['detalle'],
          'activo': servicio['activo'],
          'categoria': servicio['categoria'],
          'index': servicio['index']
        };
        await docRef.doc(id.toString()).set(data);
      }
    } else {
      // descarga los datos de firebase al dispositivo
      //? TRAIGO LOS DATOS DE FIREBASE

      List data = await docRef.get().then((value) => value.docs
          .map((e) => {
                'id': e['id'],
                'servicio': e['servicio'],
                'precio': e['precio'],
                'detalle': e['detalle'],
                'tiempo': e['tiempo'],
                'activo': e['activo'],
              })
          .toList());

//?elimina todos los servicios
      await CitaListProvider().eliminaTodosLosServicios();

//?crea SERVICIOS en dispositivo desde firebase

      for (var y = 0; y < data.length; y++) {
        // print(x.toString());
        String servicio = data[y]['servicio'];
        double precio = data[y]['precio'];
        String detalle = data[y]['detalle'];
        String tiempo = data[y]['tiempo'];
        String activo = data[y]['activo'];
        print('servicios en firebase :$servicio');
        await CitaListProvider()
            .nuevoServicio(servicio, tiempo, precio, detalle, activo);
      }
    }
  }

  //? CREA ESTRUCTURA CATEGORIA DE SERVICIOS ////////////////////////////////////////////
  _configCategoriaServicios(String usuarioAPP) async {
    //referencia al documento
    final docRef = await _referenciaDocumento(usuarioAPP, 'categoriaServicio');
    try {
      // si no existen perfilUsuarioApp lo crea con los campos correspondientes
      await docRef.doc().get().then((data) async {
        if (data.data() == null) {
          await docRef.doc('sincategoria').set({
            'nombreCategoria': 'Sin categoría',
            'detalle': 'sin categoria',
          });
        }
      });
    } catch (e) {}
  }

  //? SINCRONIZA PAGO ////////////////////////////////////////////
  _actualizaPago(String usuarioAPP, String updown) async {
    /* final docRef = await _referenciaDocumento(
        usuarioAPP, 'pago');  */ // antigua referencia a extinguir
    final docRefNuevo =
        db!.collection("agendacitasapp").doc(usuarioAPP); //* nueva referencia
    if (updown == 'UPLOAD') {
      //*antigua localizacion del pago ( a extinguir )
      // var data = {'id': 0, 'pago': false, 'email': usuarioAPP};
      //  await docRef.doc(data['id'].toString()).set(data);

      //* nueva localizacion del pago
      var dataNueva = {'pago': false};
      await docRefNuevo.set(dataNueva);
    } else {
      //GUARDA EN DISPOSITIVO PAGO: FALSE, EMAIL: EMAIL DE USUARIO
      await PagoProvider().guardaPagado(false, usuarioAPP);
    }
  }

  // SINCRONIZA DISPONIBILIDAD  SEMANAL PARA EL SERVICIO ////////////////////

  actualizaDisponibilidadSemanal(String usuarioAPP, Map diasDisp) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'disponibilidad');
    await docRef.doc('Semanal').set(diasDisp);
  }

  var dispS = {};
  Future getDisponibilidadSemanal(String usuarioAPP) async {
    await _iniFirebase();
    try {
      final docRef = await _referenciaDocumento(usuarioAPP, 'disponibilidad');
      await docRef.doc('Semanal').get().then((res) {
        var data = res.data();

        dispS = data;
      });
    } catch (e) {
      print('error lectura en firebase $e');
    }

    return dispS;
  }
// SINCRONIZA DISPONIBILIDAD  SEMANAL PARA EL SERVICIO ^^^^^^^^^^^^^^^^

  //---------------------------------------------------------------------------------------------------------
  //
  //    ----- OPERACIONES PARA ACUTALIZAR , ELIMINAR EN FIREBASE CUANDO SE ELIMINA O ACUTUALIZA EN DISPOSITIVO
  actualizarCliente(usuarioAPP, cliente) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'cliente');

    var data = {
      'nombre': cliente.nombre.toString(),
      'telefono': cliente.telefono,
      'email': cliente.email,
      'foto': cliente.foto,
      'nota': cliente.nota
    };
    String id = cliente.id;
    await docRef.doc(id).update(data);
  }

  eliminaClienteId(usuarioAPP, id) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'cliente');

    await docRef.doc(id).delete();
  }

  eliminaCitaId(usuarioAPP, id) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'cita');

    await docRef.doc(id).delete();
  }

  eliminaServicioId(usuarioAPP, id) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'servicio');

    await docRef.doc(id).delete();
  }
  //   ^^^^^^^^ OPERACIONES PARA ACUTALIZAR , ELIMINAR EN FIREBASE CUANDO SE ELIMINA O ACUTUALIZA EN DISPOSITIVO
  //------------------------------------------------------------------------------------------------------------

  actualizarUsuarioApp(
      PerfilAdministradorModel perfilUsuarioApp, String emailUsuario) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(
        emailUsuario, 'perfil'); //!antigua referencia a exitinguir

    // * nueva referencia *************************
    final docRefNuevo = db!.collection("agendacitasapp").doc(emailUsuario);
    try {
      // si no existen perfilUsuarioApp lo crea con los campos correspondientes

      /*  await docRef.doc('perfilUsuarioApp').update({
        'foto': perfilUsuarioApp.foto,
        'denominacion': perfilUsuarioApp.denominacion.toString(),
        'descripcion': perfilUsuarioApp.descripcion.toString(),
        'telefono': perfilUsuarioApp.telefono.toString(),
        'website': perfilUsuarioApp.website.toString(),
        'facebook': perfilUsuarioApp.facebook.toString(),
        'instagram': perfilUsuarioApp.instagram.toString(),
        'ubicacion': perfilUsuarioApp.ubicacion.toString(),
        'email': emailUsuario
      }); */

      //* nueva localizacion del perfil de usuario
      await docRefNuevo.update({
        'foto': perfilUsuarioApp.foto,
        'denominacion': perfilUsuarioApp.denominacion.toString(),
        'descripcion': perfilUsuarioApp.descripcion.toString(),
        'telefono': perfilUsuarioApp.telefono.toString(),
        'website': perfilUsuarioApp.website.toString(),
        'facebook': perfilUsuarioApp.facebook.toString(),
        'instagram': perfilUsuarioApp.instagram.toString(),
        'ubicacion': perfilUsuarioApp.ubicacion.toString(),
        'email': emailUsuario
      });
    } catch (e) {}
  }
}
