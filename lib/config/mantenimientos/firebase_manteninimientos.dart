//** funcion para hacer mantenimientos de datos en firebase ***************** */

import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/perfil_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MantenimientosFirebase extends ChangeNotifier {
  static nuevoRegistroMantenimiento(
      String emailUsuarioAPP, String trabajo, check) async {
    FirebaseFirestore? db;

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    db = FirebaseFirestore.instance;
    final Map<String, dynamic> newPersonaliza =
        ({'trabajo': trabajo, 'fecha': DateTime.now(), 'realizado': check});
    //rinicializa Firebase

    //referencia al documento
    final docRef = db.collection("mantenimientoAPP");

    await docRef.doc(emailUsuarioAPP).set(newPersonaliza);
  }

//* COPIA PERFIL USUARIO A NUEVA UBICACION *******
//LOS CAMPOS DEL PERFIL DE USUARIO LOS PASO A DOCUMENTOS DE LA COLECCION DE CADA USUARIO
  static Future<dynamic> ejecucionMantenimiento(String emailUsuarioAPP) async {
    FirebaseFirestore? db;

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    db = FirebaseFirestore.instance;

    //*traigo los datos del perfil de usuario
    PerfilModel perfil = PerfilModel();

    try {
      //? TRAIGO LOS DATOS DE FIREBASE
      await db
          .collection("agendacitasapp")
          .doc(emailUsuarioAPP)
          .collection('perfil')
          .doc('perfilUsuarioApp')
          .get()
          .then((res) {
        var data = res.data();

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
      return 'Error al traer el dato del perfil: $e';
    }

    //*TRAIGO DATO DE PAGO
    var pago;
    try {
      await db
          .collection("agendacitasapp")
          .doc(emailUsuarioAPP)
          .collection('pago')
          .doc('0')
          .get()
          .then((res) {
        var data = res.data();

        pago = data!['pago'];
      });
    } catch (e) {
      return 'Error al traer el dato de PAGO: $e';
    }

    // * nueva referencia *************************
    final docRefNuevo = db.collection("agendacitasapp").doc(emailUsuarioAPP);
    try {
      ///perfil
      await docRefNuevo.update({
        'foto': perfil.foto,
        'denominacion': perfil.denominacion.toString(),
        'descripcion': perfil.descripcion.toString(),
        'telefono': perfil.telefono.toString(),
        'website': perfil.website.toString(),
        'facebook': perfil.facebook.toString(),
        'instagram': perfil.instagram.toString(),
        'ubicacion': perfil.ubicacion.toString(),
        'email': perfil.email.toString()
      });

      /// pago
      await docRefNuevo.update({'pago': pago});

      //borrar campo 'a' (me sirve como bandera para ejecutar mantenimiento)
      await docRefNuevo.update({
        'a': FieldValue.delete(),
      });

      print('TRABAJO FINALIZADO --------------------------------------');
      return true;
    } catch (e) {
      return 'Error acutualizar perfil: $e';
    }
  }
}
