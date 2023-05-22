import 'package:agendacitas/providers/pago_dispositivo_provider.dart';

class CompruebaPago {
  // devuelve los datos guardados en dispositivos  {pago: false, email: loli@gmail.com}
  static Future<Map<String, dynamic>> getPagoEmailDispositivo() async {
    Map<String, dynamic> pago;

    final p = await PagoProvider().cargarPago();
    pago = p;

    return pago;
  }
}
