/* import 'package:intl/intl.dart';

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
    return '$horas h $minutos';
  } else if (horas > 0) {
    return '$horas h';
  } else {
    return '$minutos min';
  }
}

// formato campo dia de las citas agendacitasapp
String formatearFechaDiaCita(DateTime fechaOriginal) {
  // Formatear la fecha en el formato deseado // fecha formateada para FIREBASE
  return DateFormat('yyyy-MM-dd').format(fechaOriginal); // "2020-11-12"
} */
