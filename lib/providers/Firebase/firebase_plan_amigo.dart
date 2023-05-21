import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PlanAmigoFirebase {
  FirebaseFirestore? db;
  //?INICIALIZA FIREBASE //////////////////////////////////////////
  _iniFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    db = FirebaseFirestore.instance;
  }

  //? REFERENCIA DOCUMENTO ////////////////////////////////////////////
  _referenciaDocumento(String email) async {
    // creo una referencia al documento que contiene los clientes
    final docRef = db!
        .collection("planAmigo")
        .doc("usuarios") //email usuario
        .collection(email); // pago, servicio, cliente,...
    // .doc('SDAdSUSNrJhFpOdpuihs'); // ? id del cliente

    return docRef;
  }

  Future<bool> crearUsuario(context, String tuEmail) async {
    await _iniFirebase();

    bool res = false;

    final estaRegistrado = await comprobarExisteUsuario(tuEmail);

    debugPrint('variable estaRegistrado $estaRegistrado');
    if (!estaRegistrado) {
      debugPrint('USUARIO YA SE ENCUNTRA REGISTRADO(TUEMAIL)');
      final docRef = await _referenciaDocumento(tuEmail);
      try {
        await docRef.doc('registro').set({'fecha': DateTime.now()});

        mensajeCreadoUsurio(context);
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      mensajeUsurioYaExiste(context);
      return true; // responde si ya estaba resgistrado
    }
    // responde si ya estaba resgistrado
    return res;
  }

  vinculaAmigos(context, String tuEmail, String amigoEmail) async {
    await _iniFirebase();

    // planAmigo -- amigoEmail -- amigos -- R1Xts10nPZvRxi0AsBM3 -- amigo1 / 2 / 3

    final estaRegistrado = await comprobarExisteUsuario(amigoEmail);
    /*  final yaEstaVinculado =
        await estaRegistradoYNolotienesAgregado(tuEmail, amigoEmail);
    debugPrint(yaEstaVinculado.toString()); */

    if (estaRegistrado) {
      await agregaleTuEmail(context, tuEmail, amigoEmail);

      await agregateEmailAmigo(context, tuEmail, amigoEmail);

      mensajeAmigosViculados(
          context); // mensaje vinculadas las cuentas amigas con exito

      return true;
    } else {
      mensajeNoExisteAmigo(context);
    }
  }

  agregaleTuEmail(context, String tuEmail, String amigoEmail) async {
    /// comprueba si amigoEmail ya tiene primerAmigo para solamente agregarse los email sin añadir nuevoAmigo
    final yaTienePrimerAmigo = await amigoYaTienePrimerAmigo(amigoEmail);

    try {
      debugPrint('agregando tu email al de tu (amigoEmail)');

      final docRef = await _referenciaDocumento(amigoEmail);

      await docRef.doc().set({'amigo': tuEmail});

      if (!yaTienePrimerAmigo['siTiene']) {
        insertaPrimerAmigo(docRef, tuEmail);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  agregateEmailAmigo(context, String tuEmail, String amigoEmail) async {
    /// comprueba si amigoEmail ya tiene primerAmigo para solamente agregarse los email sin añadir nuevoAmigo
    final yaTienePrimerAmigo = await amigoYaTienePrimerAmigo(tuEmail);
    debugPrint(yaTienePrimerAmigo.toString());

    try {
      debugPrint('Agregando (amigoEmail) a tu cuenta');

      final docRef = await _referenciaDocumento(tuEmail);
      await docRef.doc().set({'amigo': amigoEmail});

      await docRef.get().then((data) async {
        final registros = data.docs.map((e) => e.id).toList();

        debugPrint(
            'Nº amigos $amigoEmail - ${registros.length}  '); // comprueba numero de amigos
      });
      //? INSERTA EN FIREBASE (tuEmail - doc(primeramigo)) para verificaciones en la primera pagina plan amigo

      if (!yaTienePrimerAmigo['siTiene']) {
        insertaPrimerAmigo(docRef, amigoEmail);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> comprobarExisteUsuario(String email) async {
    final docRef = await _referenciaDocumento(email);
    bool existe = false;
    await docRef.get().then((value) {
      final registros = value.docs.map((e) => e.id).toList();
      debugPrint('Lista de usuarios : $registros');

      if (!registros.isEmpty) {
        debugPrint('Usuario ya existe: $email');
        // debugPrint(registros['amigo']);
        existe = true;
      } else {
        debugPrint('Usuario no existe: $email');
        existe = false;
      }
    });

    return existe;
  }

  Future<Map<String, dynamic>> amigoYaTienePrimerAmigo(
      String amigoEmail) async {
    final docRef = await _referenciaDocumento(amigoEmail);
    Map<String, dynamic> tienePrimerAmigo = {
      'siTiene': false,
      'primerAmigo': ''
    };
    // bool tienePrimerAmigo = false;
    await docRef.get().then((value) async {
      final registros = value.docs.map((e) => e.id).toList();
      debugPrint('Lista de usuarios : ${registros.toString()}');

      if (registros.contains('primerAmigo')) {
        debugPrint('el usuario ya lo tienes agreado: $amigoEmail');
        // debugPrint(registros['amigo']);
        tienePrimerAmigo['siTiene'] = true;
        final emailPrimerAmigo = await getEmailPrimerAmigo(amigoEmail);
        tienePrimerAmigo['primerAmigo'] = emailPrimerAmigo;
        debugPrint('nombre del primerAmigo $emailPrimerAmigo');
      } else {
        debugPrint('Usuario no existe: $amigoEmail');
        tienePrimerAmigo['siTiene'] = false;
      }
    });

    return tienePrimerAmigo;
  }

  Future<String> getEmailPrimerAmigo(amigoEmail) async {
    String emailPrimerAmigo = '';
    final docRef = await _referenciaDocumento(amigoEmail);
    // quien es el primerAmigo
    await docRef.doc('primerAmigo').get().then((value) {
      final primerAmigo = value['amigo'];

      emailPrimerAmigo = primerAmigo;
    });
    return emailPrimerAmigo;
  }

  void mensajeNoExisteAmigo(context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.error(
        message: 'No hemos encontrado a tu amigo, compruebe el email',
      ),
    );
  }

  void mensajeCreadoUsurio(context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: 'Usuario creado! ya puedes invitar a tus amigos',
      ),
    );
  }

  void mensajeUsurioYaExiste(context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.info(
        message: 'Bienvenid@ de nuevo !! 👋',
      ),
    );
  }

  void mensajeAmigosViculados(context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: 'Amigos vinculados!',
      ),
    );
  }

  void mensajeNoMetaNumeroAmigo(context, metaNumAmigos) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message:
            'Aún no has conseguido los $metaNumAmigos amigos, ánimo !!! 💪 ',
      ),
    );
  }

  void insertaPrimerAmigo(docRef, String email) async {
    await docRef
        .doc('primerAmigo')
        .set({'amigo': email, 'fecha': DateTime.now()});
  }

  Future<Map<String, dynamic>> compruebaSiTienePrimerAmigo(
      String tuEmail) async {
    Map<String, dynamic> data = {
      'primerAmigo': false,
      'numAmigos': 0,
    };

    await _iniFirebase();
    final docRef = await _referenciaDocumento(tuEmail); //todo: email de prueba

   
    await docRef.get().then((value) {
      final List registros = value.docs.map((e) => e.id).toList();
      debugPrint('Lista de usuarios : $registros');

      if (registros.isNotEmpty) {
        if (registros.contains('primerAmigo')) {
          debugPrint('Usuario tiene primer amigo: $registros');
          data['primerAmigo'] = true;
          data['numAmigos'] =
              registros.length - 2; // resto los doc -> primerAmigo y registro
        } else {
          debugPrint('Usuario no tiene primer amigo: $registros');
         
        }
      } else {
        debugPrint('Usuario no tiene primer amigo: $registros');
       
      }
    });

    return data;
  }
}
