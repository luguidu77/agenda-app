import 'package:intl/intl.dart';

class FormatearFechaHora {
  formatearHora(String datetime) {
    final horaFormateada =
        '${DateTime.parse(datetime.toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(datetime.toString()).minute.toString().padLeft(2, '0')}';
   
    return horaFormateada;
  }

  formatearFecha(String datetime) {
    DateTime dTime = DateTime.parse(datetime);
    String formatearFecha =
        '${dTime.day.toString()}-${dTime.month.toString().padLeft(2, '0')}';

    return formatearFecha;
  }

  // formateo para la reasignacion de citas en clienteAgendoWeb
 static Map<String, dynamic> formatearFechaYHora(DateTime fechaHora) {
  String fechaFormateada = DateFormat.yMMMMd('es').format(fechaHora);
  String horaFormateada = DateFormat.Hm().format(fechaHora);
  return {
    'fechaFormateada': fechaFormateada,
    'horaFormateada': horaFormateada,
  };

}
// formateo para la reasignacion de citas en clienteAgendoWeb (duracion de la cita)
//? (de momento no lo utilizo. Para cuando sea necesario el cambio de la duracion de la cita)
 static String formatearHora2(String hora) {
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

}
