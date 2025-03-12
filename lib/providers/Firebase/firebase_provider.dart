import 'dart:io';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';

import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/emailHtml/emails_html.dart';
import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:agendacitas/widgets/alertas/alertaAgregarPersonal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';

class FirebaseProvider extends ChangeNotifier {
  List<ClienteModel> clientes = [];
  List<CitaModelFirebase> citas = [];
  List<ServicioModel> servicios = [];
  FirebaseFirestore? db;
  List<Map<String, dynamic>> data = [];

  // Método privado para convertir un RolEmpleado a String
  String rolEmpleadoToString(RolEmpleado role) {
    return role.name; // name es equivalente al String del Enum (ej. 'staff')
  }

  List<RolEmpleado> procesarRoles(dynamic roles) {
    if (roles is List) {
      return roles.map<RolEmpleado>((rol) {
        switch (rol) {
          case 'personal':
            return RolEmpleado.personal;
          case 'gerente':
            return RolEmpleado.gerente;
          case 'administrador':
            return RolEmpleado.administrador;
          default:
            throw ArgumentError('Rol desconocido: $rol');
        }
      }).toList();
    } else {
      throw ArgumentError('El campo roles no es una lista válida: $roles');
    }
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
        .collection(coleccion); // pago, servicio, cliente, perfil...
    // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

    return docRef;
  }

  PerfilAdministradorModel perfil = PerfilAdministradorModel();
  Future<PerfilAdministradorModel> cargarPerfilFB(usuarioAPP) async {
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
      await db!
          .collection("agendacitasapp")
          .doc(usuarioAPP)
          .collection("personaliza")
          .doc("configuracion")
          .get()
          .then((res) {
        var data = res.data();

        perfil.moneda = data!['moneda'];
      });
    } catch (e) {
      print('error lectura en firebase $e');
    }

    return perfil;
  }

  PerfilEmpleadoModel perfilEmpleadoModel = PerfilEmpleadoModel();

  Future<PerfilEmpleadoModel> cargarPerfilEmpleado(
      String usuarioAdministrador, String emailEmpleado) async {
    await _iniFirebase();
    PerfilEmpleadoModel perfilEmpleadoModel;

    try {
      //? TRAIGO LOS DATOS DE FIREBASE
      var querySnapshot = await db!
          .collection("agendacitasapp")
          .doc(usuarioAdministrador)
          .collection('empleados')
          .where("email", isEqualTo: emailEmpleado)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        perfilEmpleadoModel = PerfilEmpleadoModel(
          foto: data['foto'] ?? '',
          categoriaServicios:
              List<dynamic>.from(data['categoriaServicios'] ?? []),
          codVerif: data['cod_verif'] ?? '',
          color: data['color'] ?? 0,
          disponibilidadSemanal:
              List<dynamic>.from(data['disponibilidadSemanal'] ?? []),
          telefono: data['telefono'] ?? '',
          rol: List<String>.from(data['rol'] ?? []),
          emailUsuarioApp: data['emailUsuarioApp'] ?? '',
          nombre: data['nombre'] ?? '',
          email: data['email'] ?? '',
        );
      } else {
        throw "No se encontró el empleado con el email proporcionado.";
      }
    } catch (e) {
      print('Error al leer de Firebase: $e');
      throw "Error al cargar el perfil del empleado.";
    }

    return perfilEmpleadoModel;
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

  Future<String> nuevaCita(
    String emailUsuarioAPP,
    CitaModelFirebase citaElegida,
    List<String> idServicios,
  ) async {
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
      'idRecordatorioLocal': citaElegida.idRecordatorioLocal,
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

    return (docRef.id);
  }

  //------------crea el recordatorio ----------------------------------------------
  creaRecordatorio(
    String emailUsuarioAPP,
    String dia,
    CitaModelFirebase citaElegida,
    String precio,
    List<String> idServicios,
  ) async {
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();

    String horaInicio = citaElegida.horaInicio.toString();
    String comentario = citaElegida.comentario.toString();
    String nombreCliente = citaElegida.nombreCliente.toString();
    String emailCliente = citaElegida.emailCliente.toString();
    String telefonoCliente = citaElegida.telefonoCliente.toString();
    String nombreEmpleado = citaElegida.nombreEmpleado.toString();
    int idRecordatorioLocal = citaElegida.idRecordatorioLocal!;

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

      'cliente': nombreCliente,
      'servicio': listaServiciosAux,
      'telefono': telefonoCliente,
      'email': emailCliente,
      'timezone': timeZoneName,
      'tokenMessanging': perfilUsuarioApp['tokenMessaging'],
      'idRecordatorio': idRecordatorioLocal,
      'nombreEmpleado': nombreEmpleado,
      'comentario': comentario,
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

  /* Future<List<CitaModelFirebase>> getTodasLasCitas(String emailUsuario) async {
    List<CitaModelFirebase> citasFirebase = [];
    List<CitaModelFirebase> data = [];
    dynamic verifica;
    await _iniFirebase();

    final docRef = await _referenciaDocumento(emailUsuario, 'cita');

    // Obtiene todas las citas de la base de datos
    final snapshot = await docRef.get();
    for (var element in snapshot.docs) {
      final dataMap = element.data() as Map<String, dynamic>;

      data.add(CitaModelFirebase(
        id: element.id,
        precio: dataMap['precio'],
        dia: dataMap['dia'],
        comentario: dataMap['comentario'],
        horaInicio: DateTime.parse(dataMap['horaInicio']),
        horaFinal: DateTime.parse(dataMap['horaFinal']),
        idcliente: dataMap['idcliente'],
        idservicio: dataMap['idservicio'],
        idEmpleado: dataMap['idempleado'],
        confirmada: dataMap['confirmada'] ?? true,
        idCitaCliente: dataMap['idCitaCliente']?.toString() ?? '',
        tokenWebCliente: dataMap['tokenWebCliente']?.toString() ?? '',
      ));
    }

    // Procesa cada cita en paralelo
    for (var cita in data) {
      // Variables para cada cita
      late EmpleadoModel empleado;
      late Map<String, dynamic> cliente;
      List<String> servicioFirebase = [];

      // Evita la consulta si el cliente es "indispuesto"
      if (cita.idcliente != "999") {
        // Espera consultas de cliente, empleado y servicio paralelamente
        var clienteFuture =
            FirebaseProvider().getClientePorId(emailUsuario, cita.idcliente!);
        var empleadoFuture =
            FirebaseProvider().getEmpleadoporId(emailUsuario, cita.idEmpleado!);

        // Consultas para obtener servicios por id, corregimos la forma de mapearlo a futuros
        List<Future<Map<String, dynamic>>> serviciosFutures = cita.idservicio!
            .map((servicioId) => FirebaseProvider()
                .cargarServicioPorId(emailUsuario, servicioId))
            .toList(); // Ahora es de tipo Future<Map<String, dynamic>>

        // Consulta las respuestas de los futuros
        var clienteData = await clienteFuture;
        var empleadoData = await empleadoFuture;
        var serviciosData = await Future.wait(serviciosFutures);

        // Agregar los servicios a la lista de servicios
        for (var servicio in serviciosData) {
          servicioFirebase.add(servicio['servicio']);
        }

        // Crear la cita con los datos obtenidos
        citasFirebase.add(CitaModelFirebase(
          id: cita.id,
          dia: cita.dia,
          horaInicio: cita.horaInicio,
          horaFinal: cita.horaFinal,
          comentario: cita.comentario,
          email: cita.email,
          idcliente: cita.idcliente,
          idservicio: cita.idservicio,
          servicios: servicioFirebase,
          idEmpleado: cita.idEmpleado,
          nombreEmpleado: empleadoData.nombre,
          colorEmpleado: empleadoData.color,
          precio: cita.precio,
          confirmada: cita.confirmada,
          tokenWebCliente: cita.tokenWebCliente,
          idCitaCliente: cita.idCitaCliente,
          nombreCliente: clienteData['nombre'],
          fotoCliente: clienteData['foto'],
          telefonoCliente: clienteData['telefono'],
          emailCliente: clienteData['email'],
          notaCliente: clienteData['nota'],
        ));
      } else {
        // Cliente es indispuesto, usar valores predeterminados
        EmpleadoModel empleadoPredeterminado = EmpleadoModel(
          id: '',
          emailUsuarioApp: '',
          nombre: '',
          disponibilidad: [],
          email: '',
          telefono: '',
          categoriaServicios: [],
          foto: '',
          color: 0xFF0000FF,
          codVerif: '',
          roles: [],
        );
        cliente = {
          'nombre': '',
          'foto': '',
          'telefono': '',
          'email': '',
          'nota': ''
        };

        // Crear la cita con valores predeterminados
        citasFirebase.add(CitaModelFirebase(
          id: cita.id,
          dia: cita.dia,
          horaInicio: cita.horaInicio,
          horaFinal: cita.horaFinal,
          comentario: cita.comentario,
          email: cita.email,
          idcliente: cita.idcliente,
          idservicio: cita.idservicio,
          servicios: [],
          idEmpleado: cita.idEmpleado,
          nombreEmpleado: empleadoPredeterminado.nombre,
          colorEmpleado: empleadoPredeterminado.color,
          precio: cita.precio,
          confirmada: cita.confirmada,
          tokenWebCliente: cita.tokenWebCliente,
          idCitaCliente: cita.idCitaCliente,
          nombreCliente: cliente['nombre'],
          fotoCliente: cliente['foto'],
          telefonoCliente: cliente['telefono'],
          emailCliente: cliente['email'],
          notaCliente: cliente['nota'],
        ));
      }
    }

    // Ordenar las citas por hora de inicio
    citasFirebase.sort((a, b) => a.horaInicio!.compareTo(b.horaInicio!));

    return citasFirebase;
  } */
  Future<List<CitaModelFirebase>> getTodasLasCitas(String emailUsuario) async {
    await _iniFirebase();
    final docRef = await _referenciaDocumento(emailUsuario, 'cita');
    final snapshot = await docRef.get();

    // Caché para evitar consultas duplicadas
    final Map<String, Future<Map<String, dynamic>>> clienteCache = {};
    final Map<String, Future<EmpleadoModel>> empleadoCache = {};
    final Map<String, Future<Map<String, dynamic>>> servicioCache = {};

    // Funciones auxiliares para cachear
    Future<Map<String, dynamic>> getCliente(String idcliente) {
      return clienteCache.putIfAbsent(
          idcliente,
          () async => await FirebaseProvider()
              .getClientePorId(emailUsuario, idcliente));
    }

    Future<EmpleadoModel> getEmpleado(String idEmpleado) {
      return empleadoCache.putIfAbsent(
          idEmpleado,
          () async => await FirebaseProvider()
              .getEmpleadoporId(emailUsuario, idEmpleado));
    }

    Future<Map<String, dynamic>> getServicio(String servicioId) {
      return servicioCache.putIfAbsent(
          servicioId,
          () async => await FirebaseProvider()
              .cargarServicioPorId(emailUsuario, servicioId));
    }

    // Procesa cada documento de manera concurrente
    final citasFutures =
        //Usa .map<Future<CitaModelFirebase>>((doc) async { ... }) para que Dart sepa que cada elemento es un Future que retorna un CitaModelFirebase.
        snapshot.docs.map<Future<CitaModelFirebase>>((element) async {
      final dataMap = element.data() as Map<String, dynamic>;

      // Construye la cita básica
      var cita = CitaModelFirebase(
        id: element.id,
        precio: dataMap['precio'],
        dia: dataMap['dia'],
        comentario: dataMap['comentario'],
        horaInicio: DateTime.parse(dataMap['horaInicio']),
        horaFinal: DateTime.parse(dataMap['horaFinal']),
        idcliente: dataMap['idcliente'],
        idservicio: dataMap['idservicio'],
        idEmpleado: dataMap['idempleado'],
        confirmada: dataMap['confirmada'] ?? true,
        idCitaCliente: dataMap['idCitaCliente']?.toString() ?? '',
        tokenWebCliente: dataMap['tokenWebCliente']?.toString() ?? '',
        email: dataMap['email'],
        idRecordatorioLocal: dataMap['idRecordatorioLocal'] != null
            ? (dataMap['idRecordatorioLocal'])
            : 0,
      );

      // Si el cliente no es "indispuesto", realiza las consultas adicionales
      if (cita.idcliente != "999") {
        // Ejecuta las consultas en paralelo
        final clienteFuture = getCliente(cita.idcliente!);
        final empleadoFuture = getEmpleado(cita.idEmpleado!);

        List<String> serviciosFirebase = [];
        if (cita.idservicio != null) {
          // Asume que idservicio es una lista de IDs
          final serviciosIds = List<String>.from(cita.idservicio!);
          final serviciosData = await Future.wait(
            serviciosIds.map((servicioId) => getServicio(servicioId)),
          );
          serviciosFirebase = serviciosData
              .map((servicio) => servicio['servicio'] as String)
              .toList();
        }

        // Espera las respuestas de cliente y empleado
        final clienteData = await clienteFuture;
        final empleadoData = await empleadoFuture;

        // Actualiza la cita con la información extra
        cita = CitaModelFirebase(
          id: cita.id,
          dia: cita.dia,
          horaInicio: cita.horaInicio,
          horaFinal: cita.horaFinal,
          comentario: cita.comentario,
          email: cita.email,
          idcliente: cita.idcliente,
          idservicio: cita.idservicio,
          servicios: serviciosFirebase,
          idEmpleado: cita.idEmpleado,
          nombreEmpleado: empleadoData.nombre,
          colorEmpleado: empleadoData.color,
          precio: cita.precio,
          confirmada: cita.confirmada,
          tokenWebCliente: cita.tokenWebCliente,
          idCitaCliente: cita.idCitaCliente,
          nombreCliente: clienteData['nombre'],
          fotoCliente: clienteData['foto'],
          telefonoCliente: clienteData['telefono'],
          emailCliente: clienteData['email'],
          notaCliente: clienteData['nota'],
          idRecordatorioLocal: cita.idRecordatorioLocal,
        );
      } else {
        // Si el cliente es "indispuesto", asigna valores predeterminados
        cita = CitaModelFirebase(
          id: cita.id,
          dia: cita.dia,
          horaInicio: cita.horaInicio,
          horaFinal: cita.horaFinal,
          comentario: cita.comentario,
          email: cita.email,
          idcliente: cita.idcliente,
          idservicio: cita.idservicio,
          servicios: [],
          idEmpleado: cita.idEmpleado,
          nombreEmpleado: '',
          colorEmpleado: 0xFF0000FF,
          precio: cita.precio,
          confirmada: cita.confirmada,
          tokenWebCliente: cita.tokenWebCliente,
          idCitaCliente: cita.idCitaCliente,
          nombreCliente: '',
          fotoCliente: '',
          telefonoCliente: '',
          emailCliente: '',
          notaCliente: '',
        );
      }
      return cita;
    }).toList();

    // Espera a que todas las citas se procesen
    final List<CitaModelFirebase> citasFirebase =
        await Future.wait(citasFutures);

    // Ordena las citas por hora de inicio
    citasFirebase.sort((a, b) => a.horaInicio!.compareTo(b.horaInicio!));
    return citasFirebase;
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

  cargarCitasAnual(BuildContext context, String email, String fecha) async {
    var anual = fecha.split('-')[0]; //año de fecha buscada

    final contextoCitas = context.read<CitasProvider>();

    List<CitaModelFirebase> citas =
        contextoCitas.getCitas; //await getTodasLasCitas(email);
    print(citas.toString());
    for (var cita in citas) {
      String fecha = cita.dia!; //-> todos los dias
      // si la fecha anual coincide con el año de las citas, trae sus servicios para rescatar el precio
      if (fecha.split('-')[0] == anual) {
        //    _servicio = await DBProvider.db.getServicioPorId(item.idservicio! + 1);

        double precio = (cita.precio != '' &&
                cita.precio !=
                    'null') //  '' para antiguas versiones . 'null' para cuando se trata de indispuestos
            ? double.parse(cita.precio!)
            : 0;
        if (cita.confirmada == "") {
          // verifico que exita el campo "confirmada" en firebase(antiguas versiones no estaba este dato)
          // sin no existiera, agregare a la lista por defecto
          data.add({
            'id': cita.id,
            'fecha': fecha,
            'precio': precio,
          });
        } else {
          // si existiera el campo "confirmada" , solo agregare a la lista los confirmados
          if (cita.confirmada!) {
            // la ganancia mensual solo tiene en cuenta las citas CONFIRMADAS
            data.add({
              'id': cita.id,
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

  Future<Map<String, dynamic>> cargarServicioPorId(
      String email, String idservicio) async {
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

  Future<bool> actualizaPersonaliza(context, String emailUsuario,
      PersonalizaModelFirebase personaliza) async {
    Map<String, Object?> newPersonaliza = {
      'codPais': personaliza.codpais,
      'colorTema': personaliza.colorTema,
      'moneda': personaliza.moneda,
      'tiempoRecordatorio': personaliza.tiempoRecordatorio,
    };
    try {
      // Inicialización de Firebase y referencia al documento
      await _iniFirebase();
      final docRef = await _referenciaDocumento(emailUsuario, 'personaliza');
      docRef.doc('configuracion').get().then((doc) {
        if (doc.exists) {
          docRef.doc('configuracion').update(newPersonaliza);
        } else {
          docRef.doc('configuracion').set(newPersonaliza);
        }
      });

      return true;
    } catch (e) {
      return false;
    }
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
// Formatear la fecha
    String fechaInicioTexto =
        DateFormat('yyyy-MM-dd HH:mm:ss.sss').format(cita.horaInicio!);
    String fechaFinalTexto =
        DateFormat('yyyy-MM-dd HH:mm:ss.sss').format(cita.horaFinal!);

    Map<String, Object?> newCita = {
      'dia': cita.dia,
      'horaInicio': fechaInicioTexto,
      'horaFinal': fechaFinalTexto,
      'comentario': cita.comentario,
      'idcliente': cita.idcliente,
      'idservicio': cita.idservicio,
      'idempleado': cita.idEmpleado,
      'confirmada': cita.confirmada,
      'idCitaCliente': cita.idCitaCliente,
      'tokenWebCliente': cita.tokenWebCliente,
      'idRecordatorioLocal': cita.idRecordatorioLocal,
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(usuarioAPP, 'cita');
    await docRef.doc(cita.id.toString()).update(newCita);
  }

  Future<bool> reasignacionCtasEmpleado(
      String usuarioAPP, String idCita, String idEmpleado) async {
    await _iniFirebase();

    final docRef = await _referenciaDocumento(usuarioAPP, 'cita');

    try {
      await docRef.doc(idCita).update({'idempleado': idEmpleado});
      print("Field updated successfully!");
      return true;
    } catch (error) {
      print("Error updating field: $error");
      return false;
    }
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
          emailUsuarioApp: '',
          nombre: '',
          disponibilidad: [],
          email: '',
          telefono: '',
          categoriaServicios: [],
          foto: '',
          color: 0xFF0000FF,
          codVerif: '',
          roles: [],
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
        colorEmpleado: empleado.color,
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
        idRecordatorioLocal: cita['idRecordatorioLocal'],
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

  Future<Map<String, dynamic>> compruebaRolEmpleadoIniciandoSesion(
      String email) async {
    await _iniFirebase(); // Inicializa Firebase
    Map<String, dynamic> resultado = {
      'emailAdministrador': '',
      'emailUsuario': '',
      'rolUsuario': '',
      'cod_verif': '',
    };

    try {
      // Realiza una consulta collectionGroup en todas las subcolecciones "empleados"
      final empleadosSnapshot = await db!
          .collectionGroup("empleados")
          .where("email", isEqualTo: email)
          .get();

      // Si no se encuentra ningún documento, devuelve un mapa vacío
      if (empleadosSnapshot.docs.isEmpty) {
        return {};
      }

      // Usa el primer documento que coincide
      final empleadoDoc = empleadosSnapshot.docs.first;
      final data = empleadoDoc.data();

      // Para obtener el ID del documento padre de "empleados" (en "agendacitasapp"),
      // se accede a: empleadoDoc.reference.parent.parent
      //final emailAdministrador = empleadoDoc.reference.parent.parent!.id;

      resultado['emailAdministrador'] = data['emailUsuarioApp'];
      resultado['cod_verif'] = data['cod_verif'];
      resultado['rolUsuario'] = data['rol'];
      resultado['emailUsuario'] = email;

      return resultado;
    } catch (e) {
      debugPrint("Error buscando el email en la subcolección 'empleados': $e");
      return {};
    }
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
  cambiarEstadoConfirmacionCita(String emailUsuario, String idCita) async {
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
      context, CitaModelFirebase cita, String emailnegocio) async {
    String nota = '';
/*     CitaModelFirebase cita = CitaModelFirebase();
    cita.email = citaMap['email'];
    cita.idCitaCliente = citaMap['idCitaCliente'];
    cita.id = citaMap['id'];
    cita.dia = citaMap['dia'];
    cita.horaInicio = DateTime.parse(citaMap['horaInicio']);
    cita.horaFinal = DateTime.parse(citaMap['horaFinal']);
    cita.comentario = citaMap['comentario'];
    cita.idcliente = citaMap['idcliente'];
    cita.idservicio = [
      ''
    ]; //citaMap['idservicio']; // todo no esta como lista de servicios
    cita.idEmpleado = citaMap['idEmpleado'];
    cita.precio = citaMap['precio'];
    cita.confirmada = citaMap['confirmada'] == 'true' ? true : false;
    cita.tokenWebCliente = citaMap['tokenWebCliente']; */

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
              extraerDenominacionServiciosdeCadenaTexto(cita.idservicio);
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
              extraerDenominacionServiciosdeCadenaTexto(cita.idservicio);
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
      CitaModelFirebase cita,
      emailnegocio) async {
    /*  CitaModelFirebase cita = CitaModelFirebase();
    cita.email = citaMap.email;
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
    cita.tokenWebCliente = citaMap['tokenWebCliente']; */
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
      emailUsuarioApp: '',
      disponibilidad: [],
      email: '',
      telefono: '',
      categoriaServicios: [],
      foto: '',
      color: 0xFF0000FF,
      codVerif: '',
      roles: [],
    );

    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    CollectionReference docRef = await _referenciaDocumento(email, 'empleados');

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
          empleado.color = (element['color'] ?? 0xFFFFFFFF);
          empleado.codVerif = element['cod_verif'];
          empleado.roles =
              List<RolEmpleado>.from(procesarRoles(element['rol'] ?? []));
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
    CollectionReference docRef = await _referenciaDocumento(email, 'empleados');

    // Buscar el documento del empleado por su ID
    await docRef.get().then((QuerySnapshot snapshot) {
      for (var element in snapshot.docs) {
        var empleado = EmpleadoModel(
          id: element.id,
          emailUsuarioApp: element['emailUsuarioApp'] ?? '',
          nombre: element['nombre'] ?? '',
          disponibilidad:
              List<dynamic>.from(element['disponibilidadSemanal'] ?? []),
          email: element['email'] ?? '',
          telefono: element['telefono'] ?? '',
          categoriaServicios:
              List<dynamic>.from(element['categoriaServicios'] ?? []),
          foto: element['foto'] ?? '',
          color: element['color'] ?? 0xFFFFFFFF,
          codVerif: element['cod_verif'],
          roles: procesarRoles(element['rol'] ?? []),
        );

        listaEmpleados.add(empleado);
      }
    });
    // Función para procesar los roles

    return listaEmpleados;
  }

  Future<void> editaEmpleado(EmpleadoModel empleado, String email) async {
    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    CollectionReference collectRef =
        await _referenciaDocumento(email, 'empleados');

    final empleadoEditado = {
      'nombre': empleado.nombre,
      'disponibilidadSemanal': empleado.disponibilidad,
      'email': empleado.email,
      'telefono': empleado.telefono,
      'categoriaServicios': empleado.categoriaServicios,
      'foto': empleado.foto,
      'color': empleado.color,
      'cod_verif': empleado.codVerif,
      'rol': empleado.roles.map((rol) => rolEmpleadoToString(rol)).toList(),
    };

    await collectRef.doc(empleado.id).update(empleadoEditado);
  }

  Future<bool> editaCodigoVerificacion(String emailAdministrador,
      String emailEmpleado, String nuevoCodVerif) async {
    try {
      // Inicializar Firebase
      await _iniFirebase();

      // Buscar el documento donde `email` coincida con `emailUsuario`
      CollectionReference collectRef =
          await _referenciaDocumento(emailAdministrador, 'empleados');
      QuerySnapshot querySnapshot =
          await collectRef.where('email', isEqualTo: emailEmpleado).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Obtener el ID del primer documento encontrado
        String docId = querySnapshot.docs.first.id;

        print('Documento encontrado: ${docId}, ');

        // Actualizar solo el campo `cod_verif`
        await collectRef.doc(docId).update({'cod_verif': nuevoCodVerif});
        return true; // Devuelve true si se realiza con éxito
      } else {
        print('No se encontró un empleado con el email especificado.');
        return false; // Devuelve false si no se encuentra el documento
      }
    } catch (e) {
      print('Error al actualizar el código de verificación: $e');
      return false; // Devuelve false si ocurre un error
    }
  }

  Future<String> agregaEmpleado(EmpleadoModel empleado, String email) async {
    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    CollectionReference collectRef =
        await _referenciaDocumento(email, 'empleados');

    final empleadoEditado = {
      'emailUsuarioApp': empleado.emailUsuarioApp,
      'nombre': empleado.nombre,
      'disponibilidadSemanal': empleado.disponibilidad,
      'email': empleado.email,
      'telefono': empleado.telefono,
      'categoriaServicios': empleado.categoriaServicios,
      'foto': empleado.foto,
      'color': empleado.color,
      'cod_verif': empleado.codVerif,
      'rol': empleado.roles.map((rol) => rolEmpleadoToString(rol)).toList(),
    };
    DocumentReference docRef = await collectRef.add(empleadoEditado);
    return docRef.id;
  }

  registroEmpleado(EmpleadoModel empleado, String email) async {
    // Inicializar Firebase
    await _iniFirebase();

    // Obtener la referencia del documento de empleados
    CollectionReference collectRef =
        await _referenciaDocumento(email, 'empleados');
    final empleadoEditado = {
      'nombre': empleado.nombre,
      //'disponibilidadSemanal': empleado.disponibilidad,
      'email': empleado.email,
      'telefono': empleado.telefono,
      //'categoriaServicios': empleado.categoriaServicios,
      'foto': empleado.foto,
      // 'color': empleado.color,
      'cod_verif': 'verificado',
      //'rol': empleado.roles.map((rol) => rolEmpleadoToString(rol)).toList(),
    };

    await collectRef.doc(empleado.id).update(empleadoEditado);
  }

  Future<String> subirImagenStorage(
      usuarioAPP, image, EmpleadoModel empleado) async {
    print('------------ESTOY SUBIENDO IMAGEN AL STORE');

    //1º INICIALIZAR

    await _iniFirebase();
    var storage = FirebaseStorage.instance;
    //2º FILE LLEVA LA RUTA DE LA FOTO EN EL DISPOSITIVO
    final file = File(image);

    try {
      //3º SUBIR FOTO AL STORAGE
      // Sube el archivo con metadatos explícitos
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
      );
      //TASKSHAPSHOT ES PARA USAR EN POSTERIOR CONSULTA AL STORAGE

      TaskSnapshot taskSnapshot = await storage
          // GUARDO LAS FOTO DE FICHA CLIENTE EN LA SIGUIENTE DIRECCION DEL STORAGE FIREBASE
          .ref('agendadecitas/$usuarioAPP/empleados/${empleado.nombre}/foto')
          .putFile(file, metadata);
      debugPrint(taskSnapshot.toString());
      // CONSULTA DE LA URL EN STORAGE
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint(downloadUrl.toString());

      return downloadUrl;
    } on FirebaseException catch (e) {
      // 'Error Store en la nube ${e.message}'

      debugPrint(e.toString());
      return 'error en la nube';
    } catch (e) {
      //'ERROR AL CARGAR LA FOTO'

      debugPrint(e.toString());

      return 'error al cargar la foto';
    }
  }
}
