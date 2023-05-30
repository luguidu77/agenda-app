import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<String> validateLoginInput(context, email, password) async {
  //  ! RESPALDO  ( DESCARGA DATOS DE FIREBASE )
  var data;
  try {
    //INICIALIZA FIREBASE
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    //1º INICIO SESION FIREBASE CON EMAIL Y CONTRASEÑA
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      //value trae los credenciales del usuario. Se puede utilizar para agregarlo al provider
      /*  UserCredential(additionalUserInfo: AdditionalUserInfo(isNewUser: false, profile: {}, providerId: null, username: null), credential: null, user: User(displayName: null, email: loli@gmail.com, emailVerified: false, isAnonymous: false, metadata: UserMetadata(creationTime: 2023-05-27 10:13:07.348Z, lastSignInTime: 2023-05-27 10:19:22.222Z), phoneNumber: null, photoURL: null, providerData, [UserInfo(displayName: null, email: loli@gmail.com, phoneNumber: null, photoURL: null, providerId: password, uid: loli@gmail.com)], refreshToken: , tenantId: null, uid: Z3TCba6YfwMCERs6oqpqIghtyWc2)) */

      data = value.toString();
    });
  } on FirebaseAuthException catch (e) {
    // ERRORES DE INICIO DE SESION
    //'wrong-password'
    // 'user-not-found'
    //'too-many-requests'(BLOQUEADO USUARIO TEMPORALMENTE POR MAS DE 10 INTENTOS DESDE UNA MISMA IP)
    return e.code;
  }

  return data;
}

// ? LOS NUEVOS USUARIOS PAGO 1ª OPCION
validateRegisterInput(context, email, password) async {
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
