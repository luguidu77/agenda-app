import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/material.dart';

class PersonalizaProvider extends ChangeNotifier {
  List<PersonalizaModel> personalizaGuardado = [];

  Future<PersonalizaModel> nuevoPersonaliza(
      int id, int codpais, String mensaje, String enlace, String moneda) async {
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

    personalizaGuardado.add(personaliza);

    return personaliza;
  }

  Future<List<PersonalizaModel>> cargarPersonaliza() async {
    final personalizaGuardado = await DBProvider.db.getPersonaliza();
    this.personalizaGuardado = [...personalizaGuardado];

    return personalizaGuardado;
  }

  actualizarPersonaliza(PersonalizaModel personaliza) async {
    await DBProvider.db.actualizarPersonaliza(personaliza);
  }
}
