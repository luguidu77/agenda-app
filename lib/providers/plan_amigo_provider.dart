import 'package:agendacitas/models/plan_amigo_model.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/material.dart';

class PlanAmigoProvider extends ChangeNotifier {
  Map<String, dynamic> _planAmigo = {'email': ''};

  Map<String, dynamic> get planAmigo => _planAmigo;

  set planAmigo(Map<String, dynamic> newPlanAmigo) {
    _planAmigo = {'email': newPlanAmigo['email']};

    notifyListeners();
  }

  //##### GUARDA EN DISPOSITIVO EMAIL PLAN AMIGO ##################
  guardaEmailPlanAmigo(String email) async {
    debugPrint(
        'Se ha guardado email plan amigo : $email  (plan_amigo_provider.dart)');

    final nPlanAmigo = PlanAmigoModel(id: 0, email: email);

    await DBProvider.db.guardaPlanAmigo(nPlanAmigo);
  }

  //##### TRAE DE DISPOSITIVO EMAIL PLAN AMIGO ##################
  Future<Map<String, dynamic>> cargarPlanAmigo() async {
    var p = await DBProvider.db.getPlanAmigo();

    _planAmigo = {'email': p['email']};

    debugPrint(
        'EMAIL PLAN AMIGO (plan_amigo_provider) : ${_planAmigo['email'].toString()}');

    return _planAmigo;
  }
}
