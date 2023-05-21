import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<bool> validateLoginInput(context,  email, password) async {
  bool res = false;
  //  ! RESPALDO  ( DESCARGA DATOS DE FIREBASE )
  try {
    //INICIALIZA FIREBASE
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    //1º INICIO SESION FIREBASE CON EMAIL Y CONTRASEÑA
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      //SI EL INICIO DE SESION HA SIDO CORRECTO, EJECUTA LO SIGUIENTE:
      //GUARDO EN EL PROVIDER DE PAGO : PAGO Y EL EMAIL
      // await PagoProvider().guardaPagado(true, email);
      //SNACKBAR
      await mensajeSuccess(context, 'INICIO DE SESION CORRECTA');
      //2ª REALIZAR DESCARGA DE DATOS DE FIREBASE HE INSTALARLOS EN DISPOSITIVO

      // todo anulado: await SincronizarFirebase().sincronizaDescargaDispositivo(_email);
      /*   //3º REDIRIGIR AL HOME
        Navigator.of(context).pushReplacementNamed('/'); */

      res = true;
    });
  } on FirebaseAuthException catch (e) {
    // ERRORES DE INICIO DE SESION

    // USUARIO NO ENCONTRADO
    if (e.code == 'user-not-found') {
      //SNACKBAR

      mensajeError(context, 'USUARIO NO REGISTRADO');
      res = false;
      // CONTRASEÑA ERRONEA
    } else if (e.code == 'wrong-password') {
      //SNACKBAR

      mensajeError(context, 'CONTRASEÑA ERRONEA');
      res = false;
    }
  }

  return res;
}

// ? LOS NUEVOS USUARIOS PAGO 1ª OPCION
validateRegisterInput(context,  email, password) async {
  debugPrint('FORMULARIO REGISTRO VALIDO');

  // ? activa el onSave de TextFormField
  debugPrint(email.toString());

  //METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  //  await configuracionInfoPagoRespaldo(email.toString().toLowerCase());

  try {
    // REGISTRO AUTHENTICATION FIREBASE POR EMAIL Y CONTRASEÑA
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    //1º INICIO SESION FIREBASE CON EMAIL Y CONTRASEÑA
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    //SI EL INICIO DE SESION HA SIDO CORRECTO, EJECUTA LO SIGUIENTE: (retorna true como formulario validado)
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      debugPrint('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      debugPrint('The account already exists for that email.');
    }
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

// ? LOS NUEVOS USUARIOS PAGO 2ª OPCION
validateRegisterInput2(context, formKey, email, password) async {
  final form = formKey.currentState;
  if (form!.validate()) {
    debugPrint('FORMULARIO REGISTER VALIDO');

    form.save(); // ? activa el onSave de TextFormField
    debugPrint(email.toString());
    // setState(() {});
    try {
      //INICIALIZA FIREBASE
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      //1º INICIO SESION FIREBASE CON EMAIL Y CONTRASEÑA
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      //SI EL INICIO DE SESION HA SIDO CORRECTO, EJECUTA LO SIGUIENTE:

      mensajeSuccess(context, 'INICIO SESION CORRECTA');

      //METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
      //await _configuracionInfoPagoRespaldo(email.toString().toLowerCase());

      //? EL USUARIO YA HA SIDO CREADO POR EL ADMINISTRADOR DE FIREBASE

      // ERRORES DE INICIO DE SESION
    } on FirebaseAuthException catch (e) {
      // USUARIO NO ENCONTRADO
      if (e.code == 'user-not-found') {
        //SNACKBAR

        mensajeError(context, 'USUARIO NO REGISTRADO');
        return false;

        // CONTRASEÑA ERRONEA
      } else if (e.code == 'wrong-password') {
        //SNACKBAR

        mensajeError(context, 'CONTRASEÑA ERRONEA');
        return false;
      }
    }
    return true;
  } else {
    return false;
  }
}
