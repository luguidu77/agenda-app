import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class PersonalizaProvider extends ChangeNotifier {
  var _personaliza = {};

  get getPersonaliza => _personaliza;

  set setPersonaliza(nuevoPersonaliza) {
    _personaliza = nuevoPersonaliza;

    notifyListeners();
  }

  List<PersonalizaModel> _personalizaGuardado = [];
  Future<PersonalizaModel> nuevoPersonaliza(
    int id,
    int codpais,
    String mensaje,
    String enlace,
    String moneda,
  ) async {
    final personaliza = PersonalizaModel(
      id: 0,
      codpais: codpais, //codigo pais para telefonos
      mensaje: mensaje, //mensaje remision a clientes para configuar usuario
      enlace: enlace, //
      moneda: moneda, // moneda de pais de usuario
    );

    final id = await DBProvider.db.guardarPersonaliza(personaliza);

    //asinar el ID de la base de datos al modelo
    personaliza.id = id;

    _personalizaGuardado.add(personaliza);

    return personaliza;
  }

  Future<List<PersonalizaModel>> cargarPersonaliza() async {
    final personalizaGuardado = await DBProvider.db.getPersonaliza();
    _personalizaGuardado = [...personalizaGuardado];

    return personalizaGuardado;
  }

  actualizarPersonaliza(PersonalizaModel personaliza) async {
    await DBProvider.db.actualizarPersonaliza(personaliza);
  }
}

class PersonalizaProviderFirebase extends ChangeNotifier {
  var _personaliza = {};

  get getPersonaliza => _personaliza;

  set setPersonaliza(Map<String, String> nuevoPersonaliza) {
    _personaliza = nuevoPersonaliza;

    notifyListeners();
  }

  Future<PersonalizaModelFirebase> nuevoPersonaliza(
      String emailUsuarioAPP, String mensaje) async {
    final personaliza = PersonalizaModelFirebase(
        mensaje: mensaje // mensaje que se envia al confirmar las citas
        );

    // final id = await DBProvider.db.guardarPersonaliza(personaliza);

    //asinar el ID de la base de datos al modelo
    // personaliza.id = id;

    await FirebaseProvider().nuevoPersonaliza(emailUsuarioAPP, mensaje);

    return personaliza;
  }

  Future<Map<String, dynamic>> cargarPersonaliza(String emailUsuarioAPP) async {
    /*  final personalizaGuardado = await DBProvider.db.getPersonaliza();
    _personalizaGuardado = [...personalizaGuardado];

    return personalizaGuardado; */

    final Map<String, dynamic> personalizaGuardado =
        await FirebaseProvider().cargarPersonaliza(emailUsuarioAPP);

    print(
        'DATOS PERSONALIZA -----------------------${personalizaGuardado['mensaje']}');

    return personalizaGuardado;
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
