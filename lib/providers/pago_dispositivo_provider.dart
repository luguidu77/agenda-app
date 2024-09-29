import 'package:agendacitas/models/pago_model.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/foundation.dart';

class PagoProvider extends ChangeNotifier {
  List<PagoModel> pagadoList = [];

  Map<String, dynamic> _pagado = {'pago': false, 'email': ''};

// pagado ES LA DATA QUE SE ENVIA AL HACER UN  final estadopago = await Provider.of<PagoProvider>(context, listen: false);
  Map<String, dynamic> get pagado => _pagado;

  set pagado(Map<String, dynamic> newpagado) {
    _pagado = {'pago': newpagado['pago'], 'email': newpagado['email']};

    notifyListeners();
  }

// guarda en bd dispositibo
  guardaPagado(bool pago, String email) async {
    debugPrint(
        'Se ha guardado pago: $pago - email: $email  (pago_provider.dart)');

    final npago = pago == true ? 'true' : 'false';

    final np = PagoModel(
      id: 0,
      pago: npago,
      email: email,
    );
    await DBProvider.db.guardaPago(np);
  }

  Future<Map<String, dynamic>> cargarPago() async {
    var p = await DBProvider.db.getPago();

    bool auxPago;
    ((p['pago'] == 'true')) ? auxPago = true : auxPago = false;

    _pagado = {'pago': auxPago, 'email': p['email']};

    debugPrint('App PAGADA (pago_provider) : ${_pagado['pago']}');
    debugPrint('App EMAILUSUARIOAPP (pago_provider) :${_pagado['email']}');

    pagado = _pagado;

    return pagado;
  }
}
