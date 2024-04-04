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
  referenciaDocumento(FirebaseFirestore db) {
    final docRef = db.collection("agendoWeb"); //email usuario
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
      //
      blog: doc['blog'],
    );
  }

  List<NegocioModel> listaNegocios = [];
  late NegocioModel negocio;
  List<Map<String, dynamic>> horarios = [
    {
      //LUNES
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //MARTES
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //MIERCOLES
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //JUEVES
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //VIERNES
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //SABADO
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    },
    {
      //DOMINGO
      'primerTramo': {
        'apertura': '2023-08-16 10:00:00.000Z',
        'cierre': '2023-08-16 13:00:00.000Z'
      },
      'segundoTramo': {
        'apertura': '2023-08-16 16:00:00.000Z',
        'cierre': '2023-08-16 20:00:00.000Z'
      }
    }

    // Agrega más horarios aquí si es necesario
  ];

  // GUARDA  FOTO, tokenMessaging, imagen,el usuario(email) y publicado == false
  void creaEstructuraNegocio(PerfilModel negocio) async {
    DocumentReference<Map<String, dynamic>>? docRef;
    FirebaseFirestore db = await inicializaFirebase();
    // docRef = referenciaDocumento(db, negocio.email!);
    final fcmToken = await FirebaseMessaging.instance.getToken();

    String? idUsuario =
        await buscarIdUsuario("agendoWeb", "usuario", negocio.email);
    print(idUsuario);
    //
    //si el usario no existe crea estructura y si ya existe no hace nada
    if (idUsuario == null) {
      try {
        await db.collection("agendoWeb").doc().set({
          'imagen': negocio.foto,
          'usuario': negocio.email,
          'denominacion': negocio.denominacion,
          'tokenMessaging': fcmToken,
          'publicado': false,

          //** sin datos */
          'Latitud': 0,
          'Longitud': 0,
          'categoria': '',
          'horarios': horarios,
          'moneda': '€',
          'descripcion': '',
          'destacado': false,
          'direccion': '',
          'servicios': ["servicio1", "servicio2"],
          'telefono': '',
          'ubicacion': '',
          'valoracion': '⭐⭐⭐⭐⭐',
          'blog': {'link': negocio.denominacion, 'publicado': false},

          /****** registro */

          'registro': DateTime.now(),
        });
      } catch (e) {}
    }
  }

  Future<String?> buscarIdUsuario(
      String coleccion, String campo, dynamic valor) async {
    try {
      // Obtener una referencia a la colección en Firestore
      CollectionReference<Map<String, dynamic>> coleccionRef =
          FirebaseFirestore.instance.collection(coleccion);

      // Realizar la consulta para buscar documentos que tengan el campo deseado igual al valor proporcionado
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await coleccionRef.where(campo, isEqualTo: valor).get();

      // Si hay al menos un documento que cumple con la condición, devolver el ID del primer documento encontrado
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        // Si no se encuentra ningún documento que cumpla con la condición, devolver null
        return null;
      }
    } catch (e) {
      // Manejar el error según sea necesario
      print('Error al buscar el documento por campo: $e');
      return null;
    }
  }

  // SWICHT PUBLICADO / DESPUBLICADO
  swicthPublicado(PerfilModel negocio, bool value) async {
    final idUsuario =
        await buscarIdUsuario("agendoWeb", "usuario", negocio.email);
    FirebaseFirestore db = await inicializaFirebase();
    dynamic docRef = db.collection("agendoWeb").doc(idUsuario);

    await docRef!.update({
      'publicado': false,
    });
  }

  //VER ESTADO PUBLICACION EN SWICHT
  // Future<String> verEstadoPublicacion(String email) async {
  Future<String> verEstadoPublicacion(String email) async {
    String coleccion = "agendoWeb";
    final idUsuario = await buscarIdUsuario("agendoWeb", "usuario", email);
    try {
      // Obtener una referencia al documento en Firestore
      DocumentReference<Map<String, dynamic>> docRef =
          FirebaseFirestore.instance.collection(coleccion).doc(idUsuario);

      // Obtener el documento
      DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

      // Verificar si el campo 'publicado' existe y su valor
      if (snapshot.exists && snapshot.data()!.containsKey('publicado')) {
        bool publicado = snapshot.data()!['publicado'];

        // Devolver 'PUBLICADO' si el valor es true, 'NO PUBLICADO' si es false
        if (publicado) {
          return snapshot.id;
        } else {
          // Verificar si el campo 'formularioEnviado' existe y su valor
          if (snapshot.exists &&
              snapshot.data()!.containsKey('formularioEnviado')) {
            bool formularioEnviado = snapshot.data()!['formularioEnviado'];
            if (formularioEnviado) {
              return 'PROCESANDO';
            } else {
              // Si el campo 'formularioEnviado' no existe en el documento, devolver 'NO PUBLICADO'
              return 'NO PUBLICADO';
            }
          }
        }
      }
      // Si el campo 'publicado' no existe en el documento, devolver 'NO PUBLICADO'
      return 'NO PUBLICADO';
    } catch (e) {
      // Manejar el error según sea necesario
      print('Error al obtener el estado de publicación: $e');
      return 'ERROR';
    }
  }
}
