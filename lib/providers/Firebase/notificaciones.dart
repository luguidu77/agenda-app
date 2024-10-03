import 'dart:convert';

import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/emailHtml/emails_html.dart';
import 'package:agendacitas/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/formatear.dart';
import '../buttom_nav_notificaciones_provider.dart';

FirebaseFirestore? db;

//?INICIALIZA FIREBASE //////////////////////////////////////////
_iniFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  db = FirebaseFirestore.instance;
}

//? REFERENCIA DOCUMENTO  APP ////////////////////////////////////////////
_referenciaDocumentoAPP(String usuarioAPP, String coleccion) async {
  // creo una referencia al documento que contiene los clientes
  final docRef = db!
      .collection("agendacitasapp")
      .doc(usuarioAPP) //email usuario
      .collection(coleccion); // pago, servicio, cliente, perfil...
  // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

  return docRef;
}

//? REFERENCIA NOTIFICACIONES ADMINISTRADOR ////////////////////////////////////////////
_referenciaNotificacionesAdministrador() async {
  // creo una referencia al documento que contiene los clientes
  final docRef = db!.collection("notificacionesAdministrador");

  return docRef;
}

//? REFERENCIA DOCUMENTO  CLIENTE AGENDO WEB ////////////////////////////////////////////
_referenciaDocumentoClienteAgendoWeb(
    String emailCliente, String coleccion) async {
  // creo una referencia al documento que contiene los clientes
  final collectionRef = db!
      .collection("clientesAgendoWeb")
      .doc(emailCliente) //email usuario
      .collection(coleccion); // pago, servicio, cliente, perfil...
  // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

  return collectionRef;
}

void guardaNotificacionAlUsuarioApp(RemoteMessage message) async {
  print(
      '************GUARDA  mensaje notificacion recibida *******(notificaciones.dart)******************************');
  print(message.data);
  await _iniFirebase();

  final jsonData = jsonDecode(message.data['data']);
  String emailUsuario = jsonData['emailUsuarioApp'];

  final docRef = await _referenciaDocumentoAPP(emailUsuario, 'notificaciones');

  await docRef.add({
    'categoria': message.data['categoria'],
    'data': message.data['data'],
    'fechaNotificacion': DateTime.now(),
    'visto': false,
  });
}

void guardaNotificacionAdministrador(RemoteMessage message) async {
  print(
      '************GUARDA  mensaje notificacion recibida *******(notificaciones.dart)******************************');
  print(message.data);
  await _iniFirebase();

  final docRef = await _referenciaNotificacionesAdministrador();

  await docRef.add({
    'categoria': message.data['categoria'],
    'data': message.data['data'],
    'fechaNotificacion': DateTime.now(),
    'visto': false,
    'vistoPor': [],
  });
}

// ** NOTIFICACIONES RECIBIDAS A LA APP *************************************************
//******************************************************************************************** */
Future<List<Map<String, dynamic>>>
    getTodasLasNotificacionesAdministrador() async {
  List<Map<String, dynamic>> data = [];

  await _iniFirebase();

  final docRef = await _referenciaNotificacionesAdministrador();

  await docRef.get().then((QuerySnapshot snapshot) => {
        for (var element in snapshot.docs)
          {
            //SI LA CATEGORIA DE LA NOTIFICACION == CITA o CITAWEB, AGREGA NOTIFICACION

            data.add({
              'id': element.id,
              'categoria': element['categoria'],
              'data': element['data'],
              'fechaNotificacion': element['fechaNotificacion'],
              'visto': element['visto'],
              'vistoPor': element['vistoPor'],
            })
          }
      });
  // Ordena la lista de citas por hora de inicio
  print('****************data notificacionesAdministrador : $data');
  data.sort((a, b) => b['fechaNotificacion'].compareTo(a['fechaNotificacion']));

  return data; //retorna una lista de todas las citas(CitaModelFirebase)
}

Future<List<Map<String, dynamic>>> getNotificacionesCitas(emailUsuario) async {
  List<Map<String, dynamic>> dataNotifUsuarioApp = [];

  await _iniFirebase();

  final docRef = await _referenciaDocumentoAPP(emailUsuario, 'notificaciones');

  await docRef.get().then((QuerySnapshot snapshot) => {
        for (var element in snapshot.docs)
          {
            //SI LA CATEGORIA DE LA NOTIFICACION == CITA o CITAWEB, AGREGA NOTIFICACION

            dataNotifUsuarioApp.add({
              'id': element.id,
              'categoria': element['categoria'],
              'data': element['data'],
              'fechaNotificacion': element['fechaNotificacion'],
              'visto': element['visto'],
            })
          }
      });
  // Ordena la lista de citas por hora de inicio
  print('****************data : $dataNotifUsuarioApp');
  dataNotifUsuarioApp
      .sort((a, b) => b['fechaNotificacion'].compareTo(a['fechaNotificacion']));

  return dataNotifUsuarioApp; //retorna una lista de todas las citas(CitaModelFirebase)
}

Future<List<Map<String, dynamic>>> getTodasLasNotificaciones(
    emailUsuario) async {
  List<Map<String, dynamic>> todasLasNotificaciones = [];

  final notifCitas = await getNotificacionesCitas(emailUsuario);
  todasLasNotificaciones.addAll(notifCitas);
  final notifAdministrador = await getTodasLasNotificacionesAdministrador();

  todasLasNotificaciones.addAll(notifAdministrador);

  return todasLasNotificaciones;
}

eliminaNotificacion(emailUsuario, id) async {
  await _iniFirebase();

  final docRef = await _referenciaDocumentoAPP(emailUsuario, 'notificaciones');

  // elimina la notificacion
  await docRef.doc(id).delete();
  print(id);
}

eliminaLeidas(emailUsuario) async {
  await _iniFirebase();

  final docRef = await _referenciaDocumentoAPP(emailUsuario, 'notificaciones');

  // Obtener todas las notificaciones
  final snapshot = await docRef.get();

  // Filtrar las notificaciones que tienen 'visto' igual a true
  final notificacionesVistas =
      snapshot.docs.where((doc) => doc.data()['visto'] == true);

  // Eliminar las notificaciones filtradas
  final batch = FirebaseFirestore.instance.batch();
  notificacionesVistas.forEach((doc) {
    batch.delete(doc.reference);
  });
  await batch.commit();
  /* utilizamos un lote (batch) de Firestore para eliminar todas las notificaciones filtradas de una sola vez. Esto minimiza la cantidad de operaciones de escritura en Firestore. */
}

// ** NOTIFICACIONES ENVIO AL CLIENTE clienteAgendoWeb*******************************************

//? NOTIFICACIONES EMAILS ***************************************
// Usando la extensión Trigger Email  de Firebase
Future<dynamic> emailEstadoCita(
    String estado, CitaModelFirebase cita, emailnegocio) async {
  //? FECHA LARGA EN ESPAÑOL
  String fechaLarga = formateaFechaLarga(cita.horaInicio);
  cita.horaInicio = fechaLarga;

  // obtengo el perfil del negocio
  PerfilModel negocio = await FirebaseProvider().cargarPerfilFB(emailnegocio);
  await _iniFirebase();
  final collectionRef = db!.collection("mail");

  var refDoc = await collectionRef.add({
    'to': cita.email,
    'message': {
      'subject': estado,
      'html': textoHTML(estado, negocio, cita),
    },
  });

  final res = await collectionRef.doc(refDoc.id).get();
  return res.id; //retorno el id de la coleccion mail
}

//comprueba el envio del email
Future<dynamic> comprueStatusEmail(String mailId) async {
  await _iniFirebase();
  final collectionRef = db!.collection("mail");

  dynamic status = await collectionRef.doc(mailId).get();
  // print(status['delivery']['state']);

  return status['delivery']['state'];
}

/* emailCitaCancelada(cita, emailnegocio) async {
  // obtengo el perfil del negocio
  PerfilModel negocio = await FirebaseProvider().cargarPerfilFB(emailnegocio);
  await _iniFirebase();
  final collectionRef = db!.collection("mail");

  collectionRef.add({
    'to': cita['email'],
    'message': {
      'subject': 'Cita cancelada',
      'html': textoHTML('Su cita ha sido cancelada', negocio, cita),
    },
  });
} */

//? NOTIFICACIONES PUSH ***************************************

//******************************************************************************************** */
contadorNotificacionesCitasNoLeidas(
    BuildContext context, String emailUsuario) async {
  int cantidadTotal = 0;
  int recordatorios = 0;
  int citaweb = 0;
  int administrador = 0;
  // List<Map<String, dynamic>> notificacionesCitas =
  await getTodasLasNotificaciones(emailUsuario).then((notificacionesCitas) {
    for (var element in notificacionesCitas) {
      if (element['visto'] == false) {
        if (element['categoria'] == 'recordatorio') {
          cantidadTotal++;
        }
        if (element['categoria'] == 'citaweb') {
          citaweb++;
        }
        cantidadTotal++;
      }

      if (element['categoria'] == 'administrador') {
        List<dynamic> listaAux = element['vistoPor'];

        if (!listaAux.contains(emailUsuario)) {
          administrador++;
          cantidadTotal++;
        }
      }
    }

    // * setea el contador de las notificaciones
    context.read<ButtomNavNotificacionesProvider>().setContadorNotificaciones(
        cantidadTotal, recordatorios, citaweb, administrador);
  });
}
