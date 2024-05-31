import 'dart:async';

import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/utils.dart';

class FirebaseProvider extends ChangeNotifier {
  List<ClienteModel> clientes = [];
  List<CitaModelFirebase> citas = [];
  List<ServicioModel> servicios = [];
  FirebaseFirestore? db;

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
        .collection(coleccion); // pago, servicio, cliente, perfil...
    // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

    return docRef;
  }

  PerfilModel perfil = PerfilModel();
  Future<PerfilModel> cargarPerfilFB(usuarioAPP) async {
    await _iniFirebase();
    String idNegocio = '';
    try {
      //? TRAIGO EL ID DEL NEGOCIO EN AGENDOWEB
      QuerySnapshot querySnapshot = await db!
          .collection("agendoWeb")
          .where("usuario", isEqualTo: usuarioAPP)
          .get();
      // Verifica si se encontró algún documento
      if (querySnapshot.docs.isNotEmpty) {
        // Obtén el primer documento que coincida (suponiendo que buscas una coincidencia única)
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;

        // Devuelve el ID del documento
        idNegocio = docSnapshot.id;
      } else {
        // No se encontró ningún documento que coincida con la consulta
        debugPrint('No se encontró ningún documento para el usuario');
      }


      //? TRAIGO LOS DATOS DE FIREBASE
      await db!.collection("agendacitasapp").doc(usuarioAPP).get().then((res) {
        var data = res.data();
        perfil.id = idNegocio;
        perfil.email = data!['email'];
        perfil.foto = data['foto'];
        perfil.denominacion = data['denominacion'];
        perfil.descripcion = data['descripcion'];
        perfil.facebook = data['facebook'];
        perfil.instagram = data['instagram'];
        perfil.telefono = data['telefono'];
        perfil.ubicacion = data['ubicacion'];
        perfil.website = data['website'];
      });
    } catch (e) {
      print('error lectura en firebase $e');
    }

    return perfil;
  }

  nuevoCliente(String emailUsuarioAPP, String nombre, telefono, email, foto,
      nota) async {
    final Map<String, dynamic> newCliente = ({
      'nombre': nombre,
      'telefono': telefono,
      'email': email,
      'foto': foto,
      'nota': nota,
    });
    //rinicializa Firebase
    await _iniFirebase();
    //referencia al documento
    final docRef = await _referenciaDocumento(emailUsuarioAPP, 'cliente');

    await docRef.doc().set(newCliente);
  }

  nuevaCita(
      String emailUsuarioAPP,
      String dia,
      String horaInicio,
      String horaFinal,
      String precio,
      String comentario,
      String idCliente,
      List<dynamic> idServicio,
      String idEmpleado,
      idCitaCliente) async {
    final Map<String, dynamic> cita = ({
      'dia': dia,
      'horaInicio': horaInicio,
      'horaFinal': horaFinal,
      'precio': precio,
      'comentario': comentario,
      'idcliente': idCliente,
      'idservicio': idServicio.map((e) => e).toList(),
      'idempleado': idEmpleado,
      'confirmada': true,
      'idCitaCliente': idCitaCliente,
      'tokenWebCliente': '',
    });
    //rinicializa Firebase
    await _iniFirebase();

    //referencia a la coleccion cita
    final coleccion = await _referenciaDocumento(emailUsuarioAPP, 'cita');
    // Crear una referencia a un nuevo documento
    DocumentReference docRef = coleccion.doc();
    print('id del documento cita ${docRef.id}');

    await docRef.set(cita);
    // Obtener el ID del documento

    // retorna el id de la cita para utilizarlo en id recordatorio
    return convertirIdEnEntero(docRef.id);
  }

  nuevoServicio(String emailUsuarioAPP, String servicio, String tiempo,
      double precio, String detalle, String categoria, int index) async {
    final Map<String, dynamic> newServicio = ({
      'activo': 'true',
      'servicio': servicio,
      'tiempo': tiempo,
      'precio': precio,
      'detalle': detalle,
      'categoria': categoria,
      'index': index
    });
    //rinicializa Firebase
    await _iniFirebase();
    //referencia al documento
    final docRef = await _referenciaDocumento(emailUsuarioAPP, 'servicio');

    await docRef.doc().set(newServicio);
  }

  nuevaCategoriaServicio(
    String emailUsuarioAPP,
    String categoria,
    String detalle,
  ) async {
    final Map<String, dynamic> newCategoria = ({
      'nombreCategoria': categoria,
      'detalle': detalle,
    });
    //rinicializa Firebase
    await _iniFirebase();
    //referencia al documento
    final docRef =
        await _referenciaDocumento(emailUsuarioAPP, 'categoriaServicio');

    await docRef.doc().set(newCategoria);
  }

  nuevoPersonaliza(String emailUsuarioAPP, String mensaje) async {
    final Map<String, dynamic> newPersonaliza = ({
      'mensaje': mensaje,
    });
    //rinicializa Firebase
    await _iniFirebase();
    //referencia al documento
    final docRef = await _referenciaDocumento(emailUsuarioAPP, 'personaliza');

    await docRef.doc('mensajeCita').set(newPersonaliza);
  }

  getCitasHoraOrdenadaPorFecha(emailUsuario, fecha) async {
    List<Map<String, dynamic>> data = [];

    dynamic verifica;
    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'cita');

    try {
      await docRef.get().then((QuerySnapshot snapshot) => {
            for (var element in snapshot.docs)
              {
                verifica = element
                    .data(), // Accede a los datos del documento como un mapa
                //AGREGA LAS CITAS POR FECHA SELECCIONADA
                if (element['dia'] == fecha)
                  {
                    {
                      // El campo 'confirmada' existe en el documento
                      // Agrega los datos con el campo 'confirmada'
                      data.add({
                        'id': element.id,
                        'precio': element['precio'],
                        'comentario': element['comentario'],
                        'horaInicio': element['horaInicio'],
                        'horaFinal': element['horaFinal'],
                        'idCliente': element['idcliente'],
                        'idServicio': element['idservicio'],
                        'idEmpleado': element['idempleado'],
                        'confirmada': verifica.containsKey('confirmada')
                            ? element['confirmada']
                            : '',
                        'idCitaCliente': verifica.containsKey('idCitaCliente')
                            ? element['idCitaCliente']
                            : '',
                        'tokenWebCliente':
                            verifica.containsKey('tokenWebCliente')
                                ? element['tokenWebCliente']
                                : ''
                      })
                    }
                  }
              }
          });
    } catch (e) {}

    return data; //retorna una lista de citas(CitaModelFirebase) cuando el dia sea igual a la fecha
  }

  getTodasLasCitas(emailUsuario) async {
    List<Map<String, dynamic>> data = [];

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'cita');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA LAS CITAS

              data.add({
                'id': element.id,
                'precio': element['precio'],
                'dia': element['dia'],
                'comentario': element['comentario'],
                'horaInicio': element['horaInicio'],
                'horaFinal': element['horaFinal'],
                'idCliente': element['idcliente'],
                'idServicio': element['idservicio'],
                'idEmpleado': element['idempleado'],
                'confirmada': element['confirmada'],
              })
            }
        });

    return data; //retorna una lista de todas las citas(CitaModelFirebase)
  }

  List<Map<String, dynamic>> data = [];

  // List<ClienteModel> cientes = [];

  getClientePorId(String email, String idcliente) async {
    Map<String, dynamic> cliente = {};

    await _iniFirebase();
    final docRef = await _referenciaDocumento(email, 'cliente');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA CLIENTE BUSCADO POR ID
              if (element.id == idcliente)
                {
                  cliente = {
                    'nombre': element['nombre'],
                    'foto': element['foto'],
                    'telefono': element['telefono'],
                    'email': element['email'],
                    'nota': element['nota'],
                  }
                },
            }
        });

    return cliente;
  }

  cargarServiciosPorCliente(int cliente) async {
    // List<CitaModel> servicios = await DBProvider.db.getCitasPorCliente(cliente);
    notifyListeners();
    return servicios;
  }

  cargarCitasAnual(String email, String fecha) async {
    var anual = fecha.split('-')[0]; //año de fecha buscada

    List<Map<String, dynamic>> citas = await getTodasLasCitas(email);
    print(citas.toString());
    for (var cita in citas) {
      String fecha = cita['dia']; //-> todos los dias
      // si la fecha anual coincide con el año de las citas, trae sus servicios para rescatar el precio
      if (fecha.split('-')[0] == anual) {
        //    _servicio = await DBProvider.db.getServicioPorId(item.idservicio! + 1);

        double precio =
            (cita['precio'] != '') ? double.parse(cita['precio']) : 0;

        if (cita['confirmada']) {
          // la ganancia mensual solo tiene en cuenta las citas CONFIRMADAS
          data.add({
            'id': cita['id'],
            'fecha': fecha,
            'precio': precio,
          });
        }
      }
    }

    return data;
  }

  cargarCitasPorCliente(String email, idCliente) async {
    List<Map<String, dynamic>> listaCitas = [];
    Map<String, dynamic> servicio;
    try {
      await _iniFirebase();

      final docRef = await _referenciaDocumento(email, 'cita');

      await docRef.get().then((QuerySnapshot snapshot) async => {
            for (var cita in snapshot.docs)
              {
                servicio = await cargarServicioPorId(
                    email,
                    cita['idservicio']
                        .first), //todo . solo tiene en cuenta el primer servicio (ficha_cliente -Historial citas)
                //AGREGA CITAS POR ID DE CLIENTE
                if (idCliente == cita['idcliente'])
                  {
                    listaCitas.add({
                      'id': cita.id,
                      'dia': cita['dia'],
                      'servicio': servicio['servicio'],
                      'precio': cita['precio'],
                      'detalle': servicio['detalle'],
                    })
                  }
              }
          });
    } catch (e) {}

    return listaCitas;
  }

  cargarServicioPorId(String email, idservicio) async {
    Map<String, dynamic> servicio = {};

    await _iniFirebase();

    final docRef = await _referenciaDocumento(email, 'servicio');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA SERVICIO POR ID BUSCADO
              if (idservicio == element.id)
                {
                  servicio = {
                    'idServicio': element.id,
                    'activo': element['activo'],
                    'servicio': element['servicio'],
                    'detalle': element['detalle'],
                    'precio': element['precio'],
                    'tiempo': element['tiempo'],
                  }
                }
            }
        });

    return servicio;
  }

  cargarServicios(emailUsuario) async {
    List<Map<String, dynamic>> data = [];

    List<ServicioModelFB> listaServicios = [];

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'servicio');

    try {
      await docRef
          .orderBy('index')
          .get()
          .then((QuerySnapshot snapshot) async => {
                for (var element in snapshot.docs)
                  {
                    //AGREGA LOS SERVICIOS
                    // print('${element['cate']}'),
                    data.add({
                      'id': element.id.toString(),
                      'servicio': element['servicio'],
                      'detalle': element['detalle'],
                      'precio': element['precio'],
                      'tiempo': element['tiempo'],
                      'activo': element['activo'],
                      'categoria': element['categoria'],
                      'index': element['index'] // para reordenar la lista
                    }),
                  }
              });
    } catch (e) {
      // print(e);
    }

    for (var element in data) {
      final newServicio = ServicioModelFB(
          id: element['id'],
          servicio: element['servicio'],
          detalle: element['detalle'],
          precio: element['precio'],
          tiempo: element['tiempo'],
          activo: element['activo'],
          idCategoria: element['categoria'],
          index: element['index']);

      listaServicios.add(newServicio);
    }

    return listaServicios;
  }

  cargarServiciosActivos(email) async {
    List<Map<String, dynamic>> data = [];
    List<ServicioModelFB> listaServiciosActivos = [];
    List<ServicioModelFB> servicios = await cargarServicios(email);

    for (var element in servicios) {
      if (element.activo == 'true') {
        data.add({
          'id': element.id.toString(),
          'servicio': element.servicio,
          'detalle': element.detalle,
          'precio': element.precio,
          'tiempo': element.tiempo,
          'activo': element.activo,
          'categoria': element.idCategoria,
          'index': element.index, // para reordenar la lista
        });
      }
    }

    for (var element in data) {
      final newServicio = ServicioModelFB(
          id: element['id'],
          servicio: element['servicio'],
          detalle: element['detalle'],
          precio: element['precio'],
          tiempo: element['tiempo'],
          activo: element['activo'],
          idCategoria: element['categoria'],
          index: element['index']);

      listaServiciosActivos.add(newServicio);
    }

    return listaServiciosActivos;
  }

  cargarCategoriaServicios(emailUsuario) async {
    List<Map<String, dynamic>> data = [];

    List<CategoriaServicioModel> listaCategoriaServicios = [];

    await _iniFirebase();

    final docRef =
        await _referenciaDocumento(emailUsuario, 'categoriaServicio');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA LOS SERVICIOS

              data.add({
                'id': element.id.toString(),
                'nombreCateria': element['nombreCategoria'],
                'detalle': element['detalle'],
              })
            }
        });

    for (var element in data) {
      final newCategoria = CategoriaServicioModel(
        id: element['id'],
        nombreCategoria: element['nombreCateria'],
        detalle: element['detalle'],
      );

      listaCategoriaServicios.add(newCategoria);
    }

    return listaCategoriaServicios;
  }

  Future<List> cargarCategorias(emailUsuario) async {
    List listaCategoriaServicios = [];

    await _iniFirebase();

    final docRef =
        await _referenciaDocumento(emailUsuario, 'categoriaServicio');

    QuerySnapshot queryCat = await docRef.get();

    queryCat.docs.forEach((element) {
      listaCategoriaServicios.add(element.data());
    });

    return listaCategoriaServicios;
  }

  cargarCategoriaServiciosID(emailUsuario, String idCategoria) async {
    Map<String, dynamic> data = {};

    await _iniFirebase();

    final docRef =
        await _referenciaDocumento(emailUsuario, 'categoriaServicio');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA CATEGORIA POR ID
              if (element.id == idCategoria)
                {
                  data = {
                    'id': element.id.toString(),
                    'nombreCategoria': element['nombreCategoria'],
                    'detalle': element['detalle'],
                  }
                }
            }
        });

    return data;
  }

  cargarClientes(String emailUsuario) async {
    List<Map<String, dynamic>> data = [];

    List<ClienteModel> listaCliente = [];

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'cliente');
    await docRef.get();
    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA LOS CLIENTES

              data.add({
                'id': element.id.toString(),
                'nombre': element['nombre'],
                'telefono': element['telefono'],
                'email': element['email'],
                'foto': element['foto'],
                'nota': element['nota'],
              })
            }
        });

    for (var element in data) {
      final newcliente = ClienteModel(
        id: element['id'],
        nombre: element['nombre'],
        email: element['email'],
        foto: element['foto'],
        nota: element['nota'],
        telefono: element['telefono'],
      );

      listaCliente.add(newcliente);
    }

    return listaCliente; //retorna una lista de citas(CitaModelFirebase) cuando el dia sea igual a la fecha
  }

  cargarClientePorTelefono(String emailUsuarioAPP, String telefono) async {
    Map<String, dynamic> cliente = {};

    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuarioAPP, 'cliente');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA CLIENTE BUSCADO POR ID
              if (element['telefono'] == telefono)
                {
                  cliente = {
                    'id': element.id,
                    'nombre': element['nombre'],
                    'foto': element['foto'],
                    'telefono': element['telefono'],
                    'email': element['email'],
                    'nota': element['nota'],
                  }
                },
            }
        });

    return cliente;
  }

  cargarPersonaliza(String emailUsuario) async {
    Map<String, dynamic> personaliza = {};

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');
    await docRef.get();
    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            personaliza = {
              //AGREGA DATOS

              'mensaje': element['mensaje'],
            }
        });

    return personaliza; //retorna una lista de personaliza(PersonalizaModelFirebase)
  }

  elimarCita(String emailUsuarioAPP, id) async {
    if (emailUsuarioAPP != '') {
      await _iniFirebase();
      final docRef = await _referenciaDocumento(emailUsuarioAPP, 'cita');

      await docRef.doc(id).delete();
    } else {
      await DBProvider.db.eliminarCita(id);
    }
  }

  elimarServicio(String emailUsuarioAPP, String id) async {
    try {
      await _iniFirebase();
      //referencia al documento
      final docRef = await _referenciaDocumento(emailUsuarioAPP, 'servicio');

      await docRef.doc(id).delete();
      debugPrint('cita eliminada');
    } catch (e) {
      debugPrint('No pudo elimnarse la cita ${id.toString()}');
    }
  }

  eliminaTodosLosClientes() async {
    //  await DBProvider.db.eliminaTodoslosClientes();
  }

  elimarCliente(String id) async {
    //  await DBProvider.db.eliminarCliente(id);
  }

  actalizarCliente(ClienteModel cliente) async {
    //  await DBProvider.db.actualizarCliente(cliente);
  }

  actualizarCita(String usuarioAPP, CitaModelFirebase cita) async {
    Map<String, Object?> newCita = {
      'dia': cita.dia,
      'horaInicio': cita.horaInicio,
      'horaFinal': cita.horaFinal,
      'comentario': cita.comentario,
      'idcliente': cita.idcliente,
      'idservicio': cita.idservicio,
      'idempleado': cita.idEmpleado,
      'confirmada': cita.confirmada,
      'idCitaCliente': cita.idCitaCliente,
      'tokenWebCliente': cita.tokenWebCliente
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'cita');
    await docRef.doc(cita.id.toString()).update(newCita);
  }

  actualizaTokenMessaging(String usuarioAPP, String token) async {
    await _iniFirebase();

    final docRef = await _referenciaDocumento(
        usuarioAPP, 'perfil'); //!antigua refencia a extinguir
    // Update a single field
    docRef
        .doc('perfilUsuarioApp')
        .update({'tokenMessaging': token}).then((value) {
      print("Field updated successfully!");
    }).catchError((error) {
      print("Error updating field: $error");
    });

    //** nueva ubicacion del token */
    /// NUEVA UBICACION DEL PERFIL DE USUARIO
    final docRefNuevo = db!.collection("agendacitasapp").doc(usuarioAPP);
    docRefNuevo.update({'tokenMessaging': token}).then((value) {
      print("Field updated successfully!");
    }).catchError((error) {
      print("Error updating field: $error");
    });
  }

  actualizarMensajeCita(String usuarioAPP, texto) async {
    Map<String, Object?> newPersonaliza = {
      'mensaje': texto,
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'personaliza');
    await docRef.doc('mensajeCita').update(newPersonaliza);
  }

  buscarIndiceCategoria(emailUsuario, idCategoria) async {
    await _iniFirebase();
    // final docRef = await _referenciaDocumento(emailUsuario, 'servicio');
    // QuerySnapshot snapshot =  await docRef.where('categoria', isEqualTo: idCategoria).get();

    /// List<QueryDocumentSnapshot> documentos = snapshot.docs;

    return 'id buscado de firebase';
  }

  buscarDocumento(emailUsuario, indexItem) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'servicio');
    QuerySnapshot querySnapshot =
        await docRef.where('index', isEqualTo: indexItem).get();

    if (querySnapshot.docs.isNotEmpty) {
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        String documentId = documentSnapshot.id;
        print('ID del documento: $documentId');
        // Aquí puedes realizar las operaciones adicionales que desees con el ID del documento

        return documentId;
      }
    } else {
      print(
          'No se encontraron documentos que cumplan con los criterios de búsqueda.');
    }

    return 'id buscado de firebase';
  }

  // SE USA PARA ORDENAR LISTA SERVICIOS POR SU INDEX
  modificaIndexServicio(
      String emailUsuario,
      var oldIdServicio,
      var newIdServicio,
      int oldItemIndex,
      int newItemIndex,
      int oldListIndex,
      int newListIndex) async {
    await _iniFirebase();

    //modifica el index añadiendole el digito del index de la lista

    final int newIndexAdaptado =
        newListIndex != 0 ? newItemIndex + newListIndex * 100 : newItemIndex;
    final int oldIndexAdaptado =
        oldListIndex != 0 ? oldItemIndex + oldListIndex * 100 : oldItemIndex;

    //referencia a la coleccion cita
    final docRef = await _referenciaDocumento(emailUsuario, 'servicio');
    await docRef
        .doc(oldIdServicio.toString())
        .update({'index': newIndexAdaptado});
    await docRef
        .doc(newIdServicio.toString())
        .update({'index': oldIndexAdaptado});
  }

  /* actualizarServicio(String usuarioAPP, ServicioModelFB servicio) async {
    print(servicio.servicio);
    Map<String, Object?> newServicio = {
      'activo': servicio.activo,
      'detalle': servicio.detalle,
      'precio': servicio.precio,
      'servicio': servicio.servicio,
      'tiempo': servicio.tiempo,
      'index': servicio.index
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'servicio');
    await docRef.doc(servicio.id.toString()).update(newServicio);
  } */

  actualizarServicioFB(String usuarioAPP, ServicioModelFB servicio) async {
    print(servicio.servicio);
    Map<String, Object?> newServicio = {
      'activo': servicio.activo,
      'detalle': servicio.detalle,
      'precio': servicio.precio,
      'servicio': servicio.servicio,
      'tiempo': servicio.tiempo,
      'categoria': servicio.idCategoria,
      'index': servicio.index
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'servicio');
    await docRef.doc(servicio.id.toString()).update(newServicio);
  }

  actualizarCategoriaServicioFB(
      String usuarioAPP, CategoriaServicioModel categoria) async {
    print(categoria.nombreCategoria);
    Map<String, Object?> newCategoria = {
      'nombreCategoria': categoria.nombreCategoria,
      'detalle': categoria.detalle,
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'categoriaServicio');
    await docRef.doc(categoria.id.toString()).update(newCategoria);
  }

  // actualizar el pago en Firebase
  actualizaPago(String usuarioAPP) async {
    final docRef = await _referenciaDocumento(usuarioAPP, 'pago');

    var data = {'id': 0, 'pago': true, 'email': usuarioAPP};

    await docRef.doc(data['id'].toString()).set(data);
  }

  leerBasedatosFirebase(emailUsuarioApp, fecha) async {
    print(fecha);
    List<Map<String, dynamic>> citasFirebase = [];
    Map<String, dynamic> clienteFirebase = {};

    //?TRAE LAS CITAS POR FECHA ELEGIDA ///////////////////////////////////////
    List<Map<String, dynamic>> citas = await FirebaseProvider()
        .getCitasHoraOrdenadaPorFecha(emailUsuarioApp, fecha);

    debugPrint('citas traidas de firebase : ${citas.toString()}');

    for (var cita in citas) {
      List<Map<String, dynamic>> servicioFirebase = []; //reseteo de la lista
      if (cita['idServicio'].first != '999') {
        //? TRAE CLIENTE POR SU IDCLIENTE //////////////////////////////////////
        var cliente0 = await FirebaseProvider()
            .getClientePorId(emailUsuarioApp, cita['idCliente']);
        clienteFirebase = cliente0;
        print('clientes ------------------------------$clienteFirebase');
        //? TRAE SERVICIO POR SU IDSERVICIOS ////////////////////////////////////
        for (var servicio in cita['idServicio']) {
          var servicioID = await FirebaseProvider()
              .cargarServicioPorId(emailUsuarioApp, servicio);
          servicioFirebase.add(servicioID);
        }

        debugPrint(
            'servicio traidas de firebase : ${servicioFirebase.toString()}');
      } else {
        // EN EL CASO QUE SEA UN NO DISPONIBLE, ASIGNAMOS NULL A LOS ID SERVICIO Y ID CLIENTE
        servicioFirebase.first['idServicio'] = null;
        clienteFirebase['idCliente'] = null;
      }

      citasFirebase.add({
        //empleado
        'idEmpleado': cita['idEmpleado'],
        //cita
        'id': cita['id'],
        'horaInicio': cita['horaInicio'],
        'horaFinal': cita['horaFinal'],
        'comentario': cita['comentario'],
        'precio': cita['precio'],
        'confirmada': cita['confirmada'],
        'idCitaCliente': cita['idCitaCliente'],
        'tokenWebCliente': cita['tokenWebCliente'],
        //cliente
        'idCliente': cita['idCliente'],
        'nombre': clienteFirebase['nombre'],
        'foto': clienteFirebase['foto'],
        'telefono': clienteFirebase['telefono'],
        'email': clienteFirebase['email'],
        'nota': clienteFirebase['nota'],
        //servicio
        'idServicio': servicioFirebase,
        // 'servicio': servicioFirebase.first['servicio'],
        // 'detalle': servicioFirebase.first['detalle'],
      });
    }

    citasFirebase.sort((a, b) {
      return DateTime.parse(a['horaInicio'])
          .compareTo(DateTime.parse(b['horaInicio']));
    });
    return citasFirebase;
  }

  Future<String> calculaGananciaDiariasFB(citas) async {
    await Future.delayed(const Duration(seconds: 1));
    //precio total diario
    double gananciaDiaria = 0;
    List<Map<String, dynamic>> aux = citas;
    List precios = aux.map((value) {
      return (value['precio'] != '') ? double.parse(value['precio']) : 0.0;
    }).toList(); //todo: este campo está pendiende de añadir a tabla cita de firebase

    for (double element in precios) {
      gananciaDiaria = gananciaDiaria + element;
    }
    // Formatear el número con dos decimales
    String gananciaD = NumberFormat("#.00").format(gananciaDiaria);
    return gananciaD.toString();
  }

  Future<bool> compruebaPagoFB(usuarioAPP) async {
    late bool pago;
    await _iniFirebase();
    final docRef = db!.collection("agendacitasapp").doc(usuarioAPP);
    try {
      // final collecRef = await _referenciaDocumento(usuarioAPP, 'pago');

      await docRef.get().then((res) {
        var data = res.data();

        pago = data!['pago'];
      });
    } catch (e) {
      debugPrint(e.toString());
      pago = false;
    }
    return pago;
  }

  Future<void> cambiarEstadoVisto(
      String emailUsuario, String notificacionId, bool visto) async {
    //si viene del boton visto = true // si viene de descripcion de la notificacion ,visto = false
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'notificaciones');

    final snapshot = await docRef.get();

    final notificacion =
        snapshot.docs.firstWhere((doc) => doc.id == notificacionId);

    if (visto) {
      // compruebo el estado actual de visto en Firebase
      bool estadoActual = notificacion['visto'];
      // cambio al contrario del estado actual
      await docRef.doc(notificacionId).update({'visto': !estadoActual});
    } else {
      // viene del dialogo de descripcion de la notificacion, por lo que siempre se cambiara a visto= true
      await docRef.doc(notificacionId).update({'visto': true});
    }
  }

  //* (BOTON CONFIRMAR/ANULAR) estado confirmacion de la cita en agenda del - NEGOCIO
  Future<void> cambiarEstadoConfirmacionCita(
      String emailUsuario, String idCita) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'cita');
    // 1º VEO EL ESTADO DE LA VARIABLE ACUTAL
    final snapshot = await docRef.get();
    final confirmada = snapshot.docs.firstWhere((doc) => doc.id == idCita);
    final bool estadoActual = confirmada['confirmada'];
    //2º ACTUALIAZO EL DATO
    await docRef.doc(idCita).update({'confirmada': !estadoActual});
  }

  //*(BOTON CONFIRMAR/ANULAR) estado confirmacion de la cita en agenda del- CLIENTE
  bool estadoActual = false;
  Future<void> cambiarEstadoConfirmacionCitaCliente(
      context, Map<String, dynamic> citaMap, String emailnegocio) async {
    String nota = '';
    CitaModelFirebase cita = CitaModelFirebase();
    cita.email = citaMap['email'];
    cita.idCitaCliente = citaMap['idCitaCliente'];
    cita.id = citaMap['id'];
    cita.dia = citaMap['dia'];
    cita.horaInicio = citaMap['horaInicio'];
    cita.horaFinal = citaMap['horaFinal'];
    cita.comentario = citaMap['comentario'];
    cita.idcliente = citaMap['idcliente'];
    cita.idservicio = [
      ''
    ]; //citaMap['idservicio']; // todo no esta como lista de servicios
    cita.idEmpleado = citaMap['idEmpleado'];
    cita.precio = double.parse(citaMap['precio']);
    cita.confirmada = citaMap['confirmada'] == 'true' ? true : false;
    cita.tokenWebCliente = citaMap['tokenWebCliente'];

    await _iniFirebase();
    print(cita.email);
    print(cita.idcliente);
    try {
      final collectionRef = db!
          .collection("clientesAgendoWeb")
          .doc(cita.email) //email usuario
          .collection('citas')
          .doc(cita.idCitaCliente);

      // 1º VEO EL ESTADO DE LA VARIABLE ACUTAL
      final docSnapshot = await collectionRef.get();

      //*Antes de actuar con el cliente , verifico si la cita en cuestión sigue en la base de datos del cliente clientesAgendoWeb
      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        estadoActual = data['confirmada'];

        // cambia el estado
        estadoActual = !estadoActual;
        List<String> serviciosNom = [];

        //*****************    email al cliente del estado de la cita ************ */
        if (estadoActual == true) {
          nota = '';
          // envia notificacion al cliente agendo web*/
          // necesito del cliente su email,  idCitaCliente y tokenclienteweb

          List<String> serviciosID =
              extraerDenominacionServiciosdeCadenaTexto(citaMap['idServicio']);
          for (var id in serviciosID) {
            serviciosNom.add(id);
          }
          cita.idservicio = serviciosNom;
          await emailEstadoCita('Cita confirmada', cita, emailnegocio);
          mensajeSuccess(
              context, 'Hemos envíado un email al cliente confirmando la cita');
        } else {
          nota =
              'CANCELADA POR EL NEGOCIO'; // si es cancelada crea la nota CANCELADA POR EL NEGOCIO
          // envia notificacion al cliente agendo web*/
          // necesito del cliente su email,  idCitaCliente y tokenclienteweb
          //! comprobar si el cliente tiene activado en su perfil, autorizacion para recibir emails
          List<String> serviciosID =
              extraerDenominacionServiciosdeCadenaTexto(citaMap['idServicio']);
          for (var id in serviciosID) {
            serviciosNom.add(id);
          }
          cita.idservicio = serviciosNom;
          await emailEstadoCita('Cita cancelada', cita, emailnegocio);
          mensajeSuccess(
              context, 'Hemos envíado un email al cliente anulando la cita');
        }

        //3º ACTUALIAZO EL DATO

        await collectionRef.update({'confirmada': estadoActual, 'notas': nota});
      } else {
        // si la cita no existe en clientesAgendoWeb (el cliente ya ha borrado esta cita por ejemplo)
        debugPrint('EL CLIENTE YA ELIMINO ESTA CITA');
        mensajeSuccess(context, 'EL CLIENTE YA ELIMINÓ ESTA CITA');
      }
    } catch (e) {
      debugPrint(e.toString());
      //TODO: PODAEMOS DAR LA OPCION DE ENVIARLE UN EMAIL AL CLIENTE PARA QUE SE REGISTRE EN LA WEB
      mensajeInfo(
          context, 'NO PODEMOS NOTIFICAR AL CLIENTE PORQUE NO TIENE CUENTA');
    }
  }

  //* (BOTON ELIMINAR) estado confirmacion de la cita en agenda del cliente
  Future<void> cancelacionCitaCliente(
      //reserva['email'], reserva['idCitaCliente'].toString()
      Map<String, dynamic> citaMap,
      emailnegocio) async {
    CitaModelFirebase cita = CitaModelFirebase();
    cita.email = citaMap['email'];
    cita.idCitaCliente = citaMap['idCitaCliente'];
    cita.idservicio = ['cancelada'];
    cita.id = citaMap['id'];
    cita.dia = citaMap['dia'];
    cita.horaInicio = citaMap['horaInicio'];
    cita.horaFinal = citaMap['horaFinal'];
    cita.comentario = citaMap['comentario'];
    cita.idcliente = citaMap['idcliente'];
    cita.idservicio = [
      'eliminada'
    ]; //citaMap['idservicio']; // todo no esta como lista de servicios
    cita.idEmpleado = citaMap['idEmpleado'];
    cita.precio = double.parse(citaMap['precio']);
    cita.confirmada = citaMap['confirmada'] == 'true' ? true : false;
    cita.tokenWebCliente = citaMap['tokenWebCliente'];
    await _iniFirebase();
    final collectionRef = db!
        .collection("clientesAgendoWeb")
        .doc(cita.email) //email usuario
        .collection('citas')
        .doc(cita.idCitaCliente);

    //1ª envia notificacion al cliente agendo web*/
    // necesito del cliente su email,  idCitaCliente y tokenclienteweb
    //! comprobar si el cliente tiene activado en su perfil, autorizacion para recibir emails

    await emailEstadoCita('Cita cancelada', cita, emailnegocio);

    //2º ACTUALIAZO EL DATO
    await collectionRef.update({'notas': 'CITA CANCELADA POR EL NEGOCIO'});
  }

  Future<void> actualizaCitareasignada(
    String emailnegocio,
    CitaModelFirebase cita,
  ) async {
    DateTime horaInicio = DateTime.parse(cita.horaInicio!);

    Map<String, dynamic> formateo =
        FormatearFechaHora.formatearFechaYHora(horaInicio);

    String fechaFormateada = formateo['fechaFormateada'];
    String horaFormateada = formateo['horaFormateada'];

    await _iniFirebase();
    final collectionRef = db!
        .collection("clientesAgendoWeb")
        .doc(cita.email) //email usuario
        .collection('citas')
        .doc(cita.idCitaCliente);

    // antes de enviar email, extraigo los nombres de los servicios por los id
    cita.idservicio = await convierteListaIDaNombres(emailnegocio,
        cita.idservicio!); // ahora tengo en idservicio, lista de sus nombres en vez de lista de los id

    //1º ENVIO EMAIL AL CLIENTE
    await emailEstadoCita('Cita modificada', cita, emailnegocio);

    //2º ACTUALIAZO EL DATO CITA EN AGENDO WEB DEL CLIENTE
    if (cita.idCitaCliente != '') {
      await collectionRef.update({
        'confirmada': true,
        'fechaHora': horaInicio,
        'fecha': fechaFormateada,
        'hora': horaFormateada
      });
    }
  }

  creaNuevacitaAdministracionCliente(
    NegocioModel negocio,
    fechaHora,
    String fechaCita,
    String horaFormateada,
    String duracion,
    List<ServicioModel> servicios,
    String cliente,
    idCitaCliente,
  ) async {
    await _iniFirebase();
    final collectionRef = db!
        .collection("clientesAgendoWeb")
        .doc(cliente) //email usuario
        .collection('citas')
        .doc(idCitaCliente);

    // ****** citas ******
    final citaGenerada = await collectionRef.set({
      'confirmada': true,
      'fechaHora': fechaHora,
      'fecha': fechaCita,
      'hora': horaFormateada,
      'idNegocio': negocio.id,
      'negocio': negocio.denominacion,
      'ubicacion': negocio.direccion,
      'duracion': duracion,
      'servicios': servicios.map((e) => e.servicio).toList(),
      'contacto': negocio.telefono,
      'notas': ''
    });

    //return citaGenerada.id;
  }
}
