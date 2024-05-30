import 'package:intl/intl.dart';

Map<String, dynamic> formatearFechaYHora(DateTime fechaHora) {
  String fechaFormateada = DateFormat.yMMMMd('es').format(fechaHora);
  String horaFormateada = DateFormat.Hm().format(fechaHora);
  return {
    'fechaFormateada': fechaFormateada,
    'horaFormateada': horaFormateada,
  };
}

String formatearHora(String hora) {
  List<String> partes = hora.split(':');
  int horas = int.parse(partes[0]);
  int minutos = int.parse(partes[1]);

  if (horas > 0 && minutos > 0) {
    return '$horas h $minutos minutos';
  } else if (horas > 0) {
    return '$horas h';
  } else {
    return '$minutos minutos';
  }
}
