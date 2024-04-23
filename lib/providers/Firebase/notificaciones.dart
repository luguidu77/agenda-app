import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/emailHtml/emails_html.dart';
import 'package:agendacitas/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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

// ** NOTIFICACIONES RECIBIDAS A LA APP *************************************************
//******************************************************************************************** */
Future<List<Map<String, dynamic>>> getTodasLasNotificacionesCitas(
    emailUsuario) async {
  List<Map<String, dynamic>> data = [];

  await _iniFirebase();

  final docRef = await _referenciaDocumentoAPP(emailUsuario, 'notificaciones');

  await docRef.get().then((QuerySnapshot snapshot) => {
        for (var element in snapshot.docs)
          {
            //SI LA CATEGORIA DE LA NOTIFICACION == CITA o CITAWEB, AGREGA NOTIFICACION
            if (element['categoria'] == 'cita' ||
                element['categoria'] == 'citaweb')
              {
                data.add({
                  'id': element.id,
                  'categoria': element['categoria'],
                  'data': element['data'],
                  'fechaNotificacion': element['fechaNotificacion'],
                  'visto': element['visto'],
                })
              }
          }
      });
  // Ordena la lista de citas por hora de inicio
  print('****************data : $data');
  data.sort((a, b) => b['fechaNotificacion'].compareTo(a['fechaNotificacion']));

  return data; //retorna una lista de todas las citas(CitaModelFirebase)
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
emailEstadoCita(String estado, CitaModelFirebase cita, emailnegocio) async {
  // obtengo el perfil del negocio
  PerfilModel negocio = await FirebaseProvider().cargarPerfilFB(emailnegocio);
  await _iniFirebase();
  final collectionRef = db!.collection("mail");

  collectionRef.add({
    'to': cita.email,
    'message': {
      'subject': estado,
      'html': textoHTML(estado, negocio, cita),
    },
  });
}

emailCitaCancelada(cita, emailnegocio) async {
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
}

//? NOTIFICACIONES PUSH ***************************************

//******************************************************************************************** */
Future<int> hayNotificacionesCitasNoLeidas(String emailUsuario) async {
  bool hayNoleidas = false;
  int cantidad = 0;
  List<Map<String, dynamic>> notificacionesCitas =
      await getTodasLasNotificacionesCitas(emailUsuario);

  for (var element in notificacionesCitas) {
    if (element['visto'] == false) {
      hayNoleidas = true;
      cantidad++;
    }
  }

  print(notificacionesCitas.map((e) => e));

  return cantidad;
}
