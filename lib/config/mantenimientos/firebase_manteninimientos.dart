//** funcion para hacer mantenimientos de datos en firebase ***************** */

import 'package:agendacitas/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MantenimientosFirebase extends ChangeNotifier {
  static nuevoMantenimiento(String emailUsuarioAPP, String trabajo) async {
    FirebaseFirestore? db;

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    db = FirebaseFirestore.instance;
    final Map<String, dynamic> newPersonaliza =
        ({'trabajo': trabajo, 'fecha': DateTime.now()});
    //rinicializa Firebase

    //referencia al documento
    final docRef = db.collection("mantenimientoAPP");

    await docRef.doc(emailUsuarioAPP).set(newPersonaliza);
  }
}
