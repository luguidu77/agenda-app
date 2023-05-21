import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:flutter/foundation.dart';

class CompruebaPago {
  compruebaPago() async {
    Map<String, dynamic> pago;
  
      // comprueba pago en dispositivo
      final p = await PagoProvider().cargarPago();
      debugPrint('datos gardados en tabla Pago (home.dart) $p');

      pago = p;    

    return pago;
  }
}
