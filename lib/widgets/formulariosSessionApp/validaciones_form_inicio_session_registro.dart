import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<String> validateLoginInput(
    BuildContext context, String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return "Email y contraseña son obligatorios";
  }

  try {
    // 🚀 INICIO SESIÓN EN FIREBASE
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user?.uid ?? "Usuario autenticado, pero sin UID";
  } on FirebaseAuthException catch (e) {
    return e.code; // Devuelve el código de error de Firebase
  } catch (e) {
    return "Error inesperado: $e"; // Maneja cualquier otro error
  }
}

// ? LOS NUEVOS USUARIOS PAGO 1ª OPCION
Future<bool> creaCuentaUsuarioApp(
    BuildContext context, String email, String password) async {
  debugPrint('FORMULARIO REGISTRO VALIDO');

  // ? activa el onSave de TextFormField
  debugPrint(email.toString());

  //METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  //  await configuracionInfoPagoRespaldo(email.toString().toLowerCase());

  try {
    // REGISTRO AUTHENTICATION FIREBASE POR EMAIL Y CONTRASEÑA
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    //SI EL INICIO DE SESION HA SIDO CORRECTO, EJECUTA LO SIGUIENTE: (retorna true como formulario validado) */
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      mensajeError(context, 'El usuario ya existe');
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
