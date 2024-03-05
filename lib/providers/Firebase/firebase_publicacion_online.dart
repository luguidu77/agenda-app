import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../models/models.dart';

class FirebasePublicacionOnlineAgendoWeb {
  FirebaseFirestore? db;

  //?INICIALIZA FIREBASE //////////////////////////////////////////
  inicializaFirebase() async {
    FirebaseFirestore? db;

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    db = FirebaseFirestore.instance;
    // creo una referencia al documento que contiene los clientes

    return db;
  }

  //? REFERENCIA DOCUMENTO ////////////////////////////////////////////
  referenciaDocumento(FirebaseFirestore db, String email) {
    final docRef = db.collection("agendoWeb").doc(email); //email usuario
    // .collection(coleccion); // citas, favoritos, perfil...
    // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

    return docRef;
  }

  NegocioModel createNegocioModelFromDocument(doc) {
    return NegocioModel(
      id: doc.id,
      denominacion: doc['denominacion'],
      direccion: doc['direccion'],
      ubicacion: doc['ubicacion'], //ciudad
      email: doc['usuario'],
      telefono: doc['telefono'],
      imagen: doc['imagen'],
      moneda: doc['moneda'],
      latitud: doc['Latitud'],
      longitud: doc['Longitud'],
      valoracion: doc['valoracion'],
      categoria: doc['categoria'],
      servicios: doc['servicios'],
      tokenMessaging: doc['tokenMessaging'],
      //
      descripcion: doc['descripcion'],
      horarios: doc['horarios'],
      //
      destacado: doc['destacado'],
      publicado: doc['publicado'],
    );
  }

  List<NegocioModel> listaNegocios = [];
  late NegocioModel negocio;

  // GUARDA  FOTO, tokenMessaging, imagen,el usuario(email) y publicado == false
  void creaEstructuraNegocio(PerfilModel negocio, bool estadoPublicado) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    FirebaseFirestore db = await inicializaFirebase();
    docRef = referenciaDocumento(db, negocio.email!);
    final fcmToken = await FirebaseMessaging.instance.getToken();

    await docRef!.set({
      //docRef.id: negocio.email,
      'imagen': negocio.foto,
      'usuario': negocio.email,
      'denominacion': negocio.denominacion,
      'tokenMessaging': fcmToken,
      'publicado': estadoPublicado,

      /* //** sin datos */
      'Latitud': 0,
      'Longitud': 0,
      'categoria': '',
      'descripcion': '',
      'destacado': false,
      'direccion': '',
      'servicios': [],
      'telefono': '',
      'valoracion': '⭐⭐⭐⭐⭐',

      /****** registro */ */

      'registro': DateTime.now(),
    });
  }

  // SWICHT PUBLICADO / DESPUBLICADO
   swicthPublicado(PerfilModel negocio, bool value) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    FirebaseFirestore db = await inicializaFirebase();
    docRef = referenciaDocumento(db, negocio.email!);
    await docRef!.update({
      'publicado': value,
    });
  }

  //VER ESTADO PUBLICACION EN SWICHT
  Future<String> verEstadoPublicacion(String email) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    FirebaseFirestore db = await inicializaFirebase();
    docRef = referenciaDocumento(db, email);
    final data = await docRef!.get();
    if (data['publicado']) {
      return 'PUBLICADO';
    } else {
      return 'NO PUBLICADO';
    }
  }
}
