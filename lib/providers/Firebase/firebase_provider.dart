import 'dart:async';
import 'dart:convert';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:http/http.dart' as http;

import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/emailHtml/emails_html.dart';
import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';

class FirebaseProvider extends ChangeNotifier {
  List<ClienteModel> clientes = [];
  List<CitaModelFirebase> citas = [];
  List<ServicioModel> servicios = [];
  FirebaseFirestore? db;
  List<Map<String, dynamic>> data = [];

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

  nuevaCita(String emailUsuarioAPP, CitaModelFirebase citaElegida,
      List<String> idServicios) async {
    // Crear una lista de futuros a partir de la lista de ids de servicio
    List<Map<String, dynamic>> listaServiciosAux = [];
    bool esCita = true;
    if (idServicios.contains('indispuesto')) {
      esCita = false;
    } else {
      for (var element in idServicios) {
        final servicio = await FirebaseProvider()
            .cargarServicioPorId(emailUsuarioAPP, element);
        listaServiciosAux.add(servicio);
      }
    }

    final Map<String, dynamic> cita = ({
      'dia': citaElegida.dia,
      'horaInicio': citaElegida.horaInicio.toString(),
      'horaFinal': citaElegida.horaFinal.toString(),
      'precio': citaElegida.precio.toString(), //precio
      'comentario': citaElegida.comentario!,
      'idcliente': citaElegida.idcliente!,
      'idservicio': esCita
          ? listaServiciosAux.map((e) => e['idServicio'])
          : ['indispuesto'],
      'idempleado': citaElegida.idEmpleado!,
      'confirmada': true,
      'idCitaCliente': citaElegida.idCitaCliente,
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

  //------------crea el recordatorio ----------------------------------------------
  creaRecordatorio(
    String emailUsuarioAPP,
    String dia,
    String horaInicio,
    String precio,
    String comentario,
    String nombreCliente,
    String telfonoCliente,
    String emailCliente,
    List<String> idServicios,
    String idEmpleado,
  ) async {
    // Crear una lista de futuros a partir de la lista de ids de servicio
    List<String> listaServiciosAux = [];
    for (var element in idServicios) {
      final servicio = await FirebaseProvider()
          .cargarServicioPorId(emailUsuarioAPP, element);
      listaServiciosAux.add(servicio['servicio']);
    }

    /// obtiene el tokenMessaging del usuario app
    await _iniFirebase();
    //referencia a la coleccion
    final perfilUsuarioApp =
        await db!.collection("agendacitasapp").doc(emailUsuarioAPP).get();

    final Map<String, dynamic> recordatorio = ({
      'emailUsuarioApp': emailUsuarioAPP,
      'fechaCita': dia,
      'fechaFormateada': formatearFecha(horaInicio),
      'horaFormateada': formatearHora(horaInicio),
      //'horaFinal': horaFinal,
      //'precio': precio,
      //'comentario': comentario,
      'cliente': nombreCliente,
      'servicio': listaServiciosAux,

      'telefono': telfonoCliente,
      'email': emailCliente,
      'timezone': "Europe/Madrid",
      'tokenMessanging': perfilUsuarioApp['tokenMessaging'],
    });

    //referencia a la coleccion
    final coleccion = db!.collection("recordatorios");
    // Crear una referencia a un nuevo documento
    DocumentReference docRef = coleccion.doc();
    print('id del documento cita ${docRef.id}');

    await docRef.set(recordatorio);
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

  Future<List<Map<String, dynamic>>> getCitasHoraOrdenadaPorFecha(
      emailUsuario, fecha) async {
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
                        'dia': element['dia'],
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
    dynamic verifica;
    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'cita');

    await docRef.get().then((QuerySnapshot snapshot) => {
          for (var element in snapshot.docs)
            {
              //AGREGA LAS CITAS
              verifica = element
                  .data(), // Accede a los datos del documento como un mapa
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
                // 'confirmada': element['confirmada'],
                'confirmada': verifica.containsKey('confirmada')
                    ? element['confirmada']
                    : '',
              })
            }
        });

    return data; //retorna una lista de todas las citas(CitaModelFirebase)
  }

  // PERSONALIZA
  void nuevoAsuntoIndispuestos(
      emailUsuario, Map<String, dynamic> asunto) async {
    await _iniFirebase();
    final CollectionReference docRef =
        await _referenciaDocumento(emailUsuario, 'personaliza');

    await docRef.doc('NoDisponibles').collection('asuntos').doc().set(asunto);
  }

  void editaAsuntoIndispuestos(
      emailUsuario, Map<String, dynamic> asunto, id) async {
    await _iniFirebase();
    final CollectionReference docRef =
        await _referenciaDocumento(emailUsuario, 'personaliza');

    await docRef
        .doc('NoDisponibles')
        .collection('asuntos')
        .doc(id)
        .update(asunto);
  }

  void eliminaAsuntoIndispuestos(emailUsuario, id) async {
    await _iniFirebase();
    final CollectionReference docRef =
        await _referenciaDocumento(emailUsuario, 'personaliza');

    await docRef.doc('NoDisponibles').collection('asuntos').doc(id).delete();
  }

  getAsuntosIndispuestos(emailUsuario) async {
    List<Map<String, dynamic>> data = [];

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');

    // Verifica si el documento "NoDisponibles" existe
    final noDisponiblesDoc = docRef.doc('NoDisponibles');
    final noDisponiblesSnapshot = await noDisponiblesDoc.get();

    // Si no existe, créalo
    if (!noDisponiblesSnapshot.exists) {
      await noDisponiblesDoc.set({
        // Puedes inicializarlo con datos vacíos o algún valor por defecto
        'inicializado': true
      });
    }

    // Ahora puedes obtener los datos de la colección "asuntos"
    await noDisponiblesDoc
        .collection('asuntos')
        .get()
        .then((QuerySnapshot snapshot) => {
              for (var element in snapshot.docs)
                {
                  // Agrega los asuntos a la lista
                  data.add({
                    'id': element.id,
                    'titulo': element['titulo'],
                    'horas': element['horas'],
                    'minutos': element['minutos'],
                  })
                }
            });

    print(data);
    return data; // Retorna una lista de todos los asuntos
  }

  Future<Map<String, dynamic>> getAsuntoIndispuestoID(emailUsuario, id) async {
    Map<String, dynamic> asunto = {};

    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');

    // Verifica si el documento "NoDisponibles" existe
    final noDisponiblesDoc = docRef.doc('NoDisponibles');

    // Suponiendo que tienes el ID del documento que quieres traer
    String documentId = id;

// Accede al documento directamente por su ID
    DocumentSnapshot documentSnapshot =
        await noDisponiblesDoc.collection('asuntos').doc(documentId).get();

// Verifica si el documento existe
    if (documentSnapshot.exists) {
      // Extrae los datos del documento
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      // Si necesitas acceder a un campo específico
      String titulo = data?['titulo'] ?? '';
      int horas = data?['horas'] ?? 0;
      int minutos = data?['minutos'] ?? 0;

      // Haz lo que necesites con los datos
      print('Título: $titulo, Horas: $horas, Minutos: $minutos');
      // Agrega los asuntos a la lista
      asunto = {
        'id': id,
        'titulo': titulo,
        'horas': horas,
        'minutos': minutos,
      };
    } else {
      print('El documento con ID $documentId no existe.');
    }

    print(asunto);
    return asunto; // Retorna una lista de todos los asuntos
  }
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
        if (cita['confirmada'] == "") {
          // verifico que exita el campo "confirmada" en firebase(antiguas versiones no estaba este dato)
          // sin no existiera, agregare a la lista por defecto
          data.add({
            'id': cita['id'],
            'fecha': fecha,
            'precio': precio,
          });
        } else {
          // si existiera el campo "confirmada" , solo agregare a la lista los confirmados
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

  cargarServicioPorId(String email, String idservicio) async {
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

    for (var element in queryCat.docs) {
      listaCategoriaServicios.add(element.data());
    }

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

  Future<void> cargarPersonaliza(
      BuildContext context, String emailUsuario) async {
    // Inicializamos el modelo vacío con valores predeterminados
    PersonalizaModelFirebase personaliza = PersonalizaModelFirebase(
      codpais: '',
      moneda: '',
      mensaje: '',
      colorTema: '',
      tiempoRecordatorio: '',
    );

    // Inicialización de Firebase y referencia al documento
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');

    // Obtenemos los datos del documento
    final snapshot = await docRef.get();

    // Procesamos los documentos en una sola pasada
    for (var element in snapshot.docs) {
      if (element.id == 'configuracion') {
        personaliza.codpais = element['codPais'] ?? '';
        personaliza.moneda = element['moneda'] ?? '';
        personaliza.colorTema = element['colorTema'] ?? '';
        personaliza.tiempoRecordatorio = element['tiempoRecordatorio'] ?? '';
      } else if (element.id == 'mensajeCita') {
        personaliza.mensaje = element['mensaje'] ?? '';
      }
    }

    print('Personaliza cargado: ${personaliza.moneda}');

    // Establecemos el objeto en el provider
    final personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);
    personalizaProvider.setPersonaliza(personaliza);
  }

  Future<void> actualizaPersonaliza(context, String emailUsuario,
      PersonalizaModelFirebase personaliza) async {
    Map<String, Object?> newPersonaliza = {
      'codPais': personaliza.codpais,
      'colorTema': personaliza.colorTema,
      'moneda': personaliza.moneda,
      'tiempoRecordatorio': personaliza.tiempoRecordatorio,
    };

    // Inicialización de Firebase y referencia al documento
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');
    await docRef.doc('configuracion').update(newPersonaliza);
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

//* HERRAMIENTA PARA AGREGAR Y MODIFICAR DATOS FIREBASE PARA CORRECION DE ERRORES, SE INICIA DESDE calendario_screen.dart
  modificaEstructura() async {
    await _iniFirebase();
// Obtener referencia a la colección 'cita'
    final docRef = await _referenciaDocumento(
        "monicagarciatorrejimeno@hotmail.com", 'cita');

    // Obtener todos los documentos en la colección
    QuerySnapshot snapshot = await docRef.get();

    // Recorrer cada documento y actualizar el campo 'idservicio'
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      // Obtener el valor actual de 'idservicio'
      var idServicioActual = doc['idservicio'];
      if (idServicioActual is String) {
        // Modificar 'idservicio' para que sea un array con el valor original
        List<String> nuevoIdServicio = [idServicioActual];

        // Eliminar el campo actual 'idservicio'
        await doc.reference.update({
          'idservicio': FieldValue.delete(),
        });
        // Actualizar el documento con el nuevo valor de 'idservicio'
        await doc.reference.update({
          'idservicio': nuevoIdServicio,
        });

        await doc.reference.update({
          'confirmada': true,
        });
      }
      debugPrint("  TRABAJANDO.....");
    }
    debugPrint(" ____________ FINALIZADO __________");
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
    await _iniFirebase();
    final docRef =
        db!.collection("agendacitasapp").doc(usuarioAPP); //email usuario

    var data = {'pago': true};

    await docRef.update(data);
  }

  leerBasedatosFirebase(emailUsuarioApp, fecha) async {
    print(fecha);
    List<CitaModelFirebase> citasFirebase = [];

    Map<String, dynamic> clienteFirebase = {};

    //?TRAE LAS CITAS POR FECHA ELEGIDA ///////////////////////////////////////
    List<Map<String, dynamic>> citas = await FirebaseProvider()
        .getCitasHoraOrdenadaPorFecha(emailUsuarioApp, fecha);

    debugPrint('citas traidas de firebase : ${citas.toString()}');

    for (Map<String, dynamic> cita in citas) {
      // Inicializamos citaFirebase correctamente dentro del ciclo

      List<String> servicioFirebase = []; //reseteo de la lista

      /*  if (cita.idservicio!.first != '999') {
        //? TRAE CLIENTE POR SU IDCLIENTE //////////////////////////////////////
        var cliente0 = await FirebaseProvider()
            .getClientePorId(emailUsuarioApp, cita.idcliente!);
        clienteFirebase = cliente0;
        print('clientes ------------------------------$clienteFirebase');
       
        
        debugPrint(
            'servicio traidas de firebase : ${servicioFirebase.toString()}');
      } else {
        // EN EL CASO QUE SEA UN NO DISPONIBLE, ASIGNAMOS NULL A LOS ID SERVICIO Y ID CLIENTE
        /*  servicioFirebase.first['idServicio'] = null;
        clienteFirebase['idCliente'] = null; */
      } */

      var cliente;
      EmpleadoModel empleado;
      var serv;

      if (cita['idCliente'] != "999") {
        // si no es indispuesto

        //? TRAE CLIENTE POR SU IDCLIENTE //////////////////////////////////////
        cliente = await FirebaseProvider()
            .getClientePorId(emailUsuarioApp, cita['idCliente']);
        //? TRAE EMPLEADO POR SU IDCLIENTE //////////////////////////////////////
        empleado = await FirebaseProvider()
            .getEmpleadoporId(emailUsuarioApp, cita['idEmpleado']);

        //? TRAE SERVICIO POR SU IDSERVICIOS ////////////////////////////////////
        for (var servicio in cita['idServicio']) {
          serv = await FirebaseProvider()
              .cargarServicioPorId(emailUsuarioApp, servicio);
          servicioFirebase.add(serv['servicio']);
        }
      } else {
        // es un indisponible
        empleado = EmpleadoModel(
          id: '',
          nombre: '',
          disponibilidad: [],
          email: '',
          telefono: '',
          categoriaServicios: [],
          foto: '',
        );
        cliente = {
          'nombre': '',
          'foto': '',
          'telefono': '',
          'email': '',
          'nota': ''
        };
      }

      print('clientes ------------------------------$cliente');
      print(servicioFirebase);
      // Crea el objeto solo con los datos que tienes
      var citaFirebase = CitaModelFirebase(
        id: cita['id'],
        dia: cita['dia'],
        horaInicio: DateTime.parse(cita['horaInicio']),
        horaFinal: DateTime.parse(cita['horaFinal']),
        comentario: cita['comentario'],
        email: cita['email'],
        idcliente: cita['idCliente'],
        idservicio: cita['idServicio'], // servicioFirebase,
        servicios: servicioFirebase,
        idEmpleado: cita['idEmpleado'],
        nombreEmpleado: empleado.nombre,
        precio: cita['precio'],
        confirmada: cita['confirmada'],
        tokenWebCliente: cita['tokenWebCliente'],
        idCitaCliente: cita['idCitaCliente'],
        // Nuevos campos de cliente, solo los asignas si existen
        nombreCliente: cliente['nombre'],
        fotoCliente: cliente['foto'],
        telefonoCliente: cliente['telefono'],
        emailCliente: cliente['email'],
        notaCliente: cliente['nota'],
      );

      citasFirebase.add(citaFirebase);

      //servicio
      /* citaFirebase.idservicio = cita[
          'idServicio']; //servicioFirebase.map((e) => e.values.toString()).toList(),

      // 'servicio': servicioFirebase.first['servicio'],
      // 'detalle': servicioFirebase.first['detalle'],
      citasFirebase.add(citaFirebase); */
    }

    citasFirebase.sort((a, b) {
      return a.horaInicio!.compareTo(b.horaInicio!);
    });
    print('oooooooooooooooooooooofiltradas oooooooooooooooooooooooooo');

    return citasFirebase;
  }

  Future<String> calculaGananciaDiariasFB(citas) async {
    await Future.delayed(const Duration(seconds: 1));
    //precio total diario
    double gananciaDiaria = 0;
    List<CitaModelFirebase> aux = citas;
    List precios = aux.map((value) {
      return (value.precio! != '') ? double.parse(value.precio!) : 0.0;
    }).toList(); //todo: este campo está pendiende de añadir a tabla cita de firebase

    for (double element in precios) {
      gananciaDiaria = gananciaDiaria + element;
    }
    // Formatear el número con dos decimales
    String gananciaD = NumberFormat("#.00").format(gananciaDiaria);
    return gananciaD.toString();
  }

  Future<int> calculaCitasPorEmpleado(citas, idEmpleado) async {
    // await Future.delayed(const Duration(seconds: 1));
    //precio total diario
    int numCitas = 0;
    List<CitaModelFirebase> aux = citas;
    aux.map((value) {
      return (value.idEmpleado! == idEmpleado) ? numCitas++ : numCitas;
    }).toList(); //todo: este campo está pendiende de añadir a tabla cita de firebase

    return numCitas;
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

  /// esta funcion guarda la notificacion en su tabla correspondiente de firebase

  /* Future<void> guardaNotificacion(RemoteMessage payload) async {
    try {
      print("Payload recibido: ${payload.data}");

      // Verifica si 'data' es un JSON válido
      final rawData = payload.data['data'];

      // Solo intenta parsear si el valor es un JSON válido (NOTIFICACIONES DE CITAS)
      if (rawData != null && rawData.startsWith('{') && rawData.endsWith('}')) {
        final data = json.decode(rawData); // Parsear solo si es un JSON
        final String? email = data['emailUsuarioApp'];

        if (email == null || email.isEmpty) {
          print(
              "No se ha configurado el email, no se puede procesar la notificación.");
          return;
        }

        // Enviar solicitud a la función en la nube
        final response = await http.post(
          Uri.parse(
              'https://us-central1-flutter-varios-576e6.cloudfunctions.net/saveNotification'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'categoria': payload.data['categoria'],
            'data': payload.data['data'],
            'email': email,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Error en la solicitud a la función en la nube: ${response.body}');
        }

        print('Notificación guardada en Firebase con éxito.');
      } else {
        // NOTIFICACIONES DEL ADMINISTRADOR SIN ESTRUCTURA JSON
        // Enviar solicitud a la función en la nube
        final response = await http.post(
          Uri.parse(
              'https://us-central1-flutter-varios-576e6.cloudfunctions.net/saveNotificationAdministrador'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            'categoria': payload.data['categoria'],
            'data': payload.data['data'],
          }),
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Error en la solicitud a la función en la nube: ${response.body}');
        }

        print('Notificación guardada en Firebase con éxito.');
        print("NOTIFICACIONES DEL ADMINISTRADOR.");
      }
    } catch (e) {
      print('Error al manejar la notificación: $e');
    }
  }
 */
  Future<void> cambiarEstadoVisto(
      String emailUsuario, String notificacionId, bool procedencia) async {
    //si viene del boton, procedencia = true // si viene de descripcion de la notificacion ,procedencia = false
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'notificaciones');

    final snapshot = await docRef.get();

    final notificacion =
        snapshot.docs.firstWhere((doc) => doc.id == notificacionId);

    if (procedencia) {
      // compruebo el estado actual de visto en Firebase
      bool estadoActual = notificacion['visto'];
      // cambio al contrario del estado actual
      await docRef.doc(notificacionId).update({'visto': !estadoActual});
    } else {
      // viene del dialogo de descripcion de la notificacion, por lo que siempre se cambiara a visto= true
      await docRef.doc(notificacionId).update({'visto': true});
    }
  }

  Future<void> cambiarEstadoVistoNotifAdministrador(
      String emailUsuario, String notificacionId) async {
    //si viene del boton, procedencia = true // si viene de descripcion de la notificacion ,procedencia = false
    await _iniFirebase();
    final docRef = db!.collection("notificacionesAdministrador");

    final snapshot = await docRef.get();

    final notificacion =
        snapshot.docs.firstWhere((doc) => doc.id == notificacionId);

    List<dynamic> agregaEmail = notificacion['vistoPor'];

    // agregamos el email del usuario al ser vista la notificacion
    if (!agregaEmail.contains(emailUsuario)) {
      agregaEmail.add(emailUsuario);
    }

    // viene del dialogo de descripcion de la notificacion, por lo que siempre se cambiara a visto= true

    await docRef.doc(notificacionId).update({'vistoPor': agregaEmail});
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
    cita.precio = citaMap['precio'];
    cita.confirmada = citaMap['confirmada'] == 'true' ? true : false;
    cita.tokenWebCliente = citaMap['tokenWebCliente'];

    await _iniFirebase();
    print(cita.email);
    print(cita.idcliente);
    print(cita.precio);
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

        // cambia el estado
        estadoActual = !estadoActual;

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
    cita.precio = citaMap['precio'];
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
    DateTime horaInicio = cita.horaInicio!;

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
      precioTotal) async {
    await _iniFirebase();
    final collectionRef = db!
        .collection("clientesAgendoWeb")
        .doc(cliente) //email usuario
        .collection('citas')
        .doc(idCitaCliente);

    // ****** citas ******
    final citaGenerada = await collectionRef.set({
      'confirmada': true,
      'fecIhaHora': fechaHora,
      'fecha': fechaCita,
      'hora': horaFormateada,
      'idNegocio': negocio.id,
      'negocio': negocio.denominacion,
      'ubicacion': negocio.direccion,
      'duracion': duracion,
      'contacto': negocio.telefono,
      'servicios': servicios.map((e) => e.servicio).toList(),
      'precio': precioTotal,
      'notas': ''
    });

    //return citaGenerada.id;
  }

  Future<EmpleadoModel> getEmpleadoporId(
      String email, String idempleado) async {
    // Inicializar un empleado vacío
    final empleado = EmpleadoModel(
      id: '',
      nombre: '',
      disponibilidad: [],
      email: '',
      telefono: '',
      categoriaServicios: [],
      foto: '',
    );

    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    final docRef = await _referenciaDocumento(email, 'empleados');

    // Buscar el documento del empleado por su ID
    await docRef.get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        // Si el ID del documento coincide con el ID del empleado, asignar valores
        if (element.id == idempleado) {
          empleado.id = element.id;
          empleado.nombre = element['nombre'] ?? '';
          empleado.foto = element['foto'] ?? '';
          empleado.telefono = element['telefono'] ?? ''; // Corregido aquí
          empleado.email = element['email'] ?? '';
          empleado.disponibilidad =
              List<dynamic>.from(element['disponibilidadSemanal'] ?? []);
          empleado.categoriaServicios =
              List<dynamic>.from(element['categoriaServicios'] ?? []);
        }
      }
    });

    return empleado;
  }

  Future<List<EmpleadoModel>> getTodosEmpleados(String email) async {
    List<EmpleadoModel> listaEmpleados = [];
    // Inicializar un empleado vacío

    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    final docRef = await _referenciaDocumento(email, 'empleados');

    // Buscar el documento del empleado por su ID
    await docRef.get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        var empleado = EmpleadoModel(
          id: element.id,
          nombre: element['nombre'] ?? '',
          disponibilidad:
              List<dynamic>.from(element['disponibilidadSemanal'] ?? []),
          email: element['email'] ?? '',
          telefono: element['telefono'] ?? '',
          categoriaServicios:
              List<dynamic>.from(element['categoriaServicios'] ?? []),
          foto: element['foto'] ?? '',
        );

        listaEmpleados.add(empleado);
      }
    });

    return listaEmpleados;
  }
}
