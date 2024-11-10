import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';

import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class PersonalizaProviderFirebase extends ChangeNotifier {
  PersonalizaModelFirebase _personaliza =
      PersonalizaModelFirebase(); // si la inicializo con:   = PersonalizaModelFirebase(); no funciona porque estoy creando un nueva instancia si lo quito me da error de inicializacion

  PersonalizaModelFirebase get getPersonaliza => _personaliza;

  setPersonaliza(PersonalizaModelFirebase nuevoPersonaliza) {
    _personaliza = nuevoPersonaliza;

    notifyListeners();
  }

  Future<PersonalizaModelFirebase> nuevoPersonaliza(
      String emailUsuarioAPP, String mensaje) async {
    final personaliza = PersonalizaModelFirebase(
        mensaje: mensaje // mensaje que se envia al confirmar las citas
        );

    //TODO  CREAR NUEVO POR DEFECTO SI NO HAY TODAVIA DATOS

    await FirebaseProvider().nuevoPersonaliza(emailUsuarioAPP, mensaje);

    return personaliza;
  }

  actualizarPersonaliza(context, String emailUsuario, msm) async {
    try {
      // guardo en Fierebase el mensaje a enviar acutalizado
      await FirebaseProvider().actualizarMensajeCita(emailUsuario, msm);
    } catch (e) {
      mensajeError(
          context, 'Vaya!, algo salió mal, tal vez reiniciar puede ayudar');
    }
  }
}
