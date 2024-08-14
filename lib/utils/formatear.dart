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

//? FECHA LARGA EN ESPAÑOL miércoles, 5 de junio 16:49
String formateaFechaLarga(fecha) {
  String? fechaLarga;

  DateTime resFecha =
      DateTime.parse(fecha); // horaInicio trae 2022-12-05 20:27:00.000Z
  //? FECHA LARGA EN ESPAÑOL
  fechaLarga = DateFormat.MMMMEEEEd('es_ES')
      .add_Hm()
      .format(DateTime.parse(resFecha.toString()));
  return fechaLarga;
}

String formateaDurationString(List<Map<String, Duration>?> asuntos, int i) {
  Duration duration = asuntos[i]!.values.first;

  // Calcula horas y minutos
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);

  // Genera el texto formateado según las horas y minutos
  String formattedDuration = '';
  if (hours > 0) {
    formattedDuration += '$hours hora${hours > 1 ? 's' : ''}';
  }
  if (minutes > 0) {
    if (hours > 0) formattedDuration += ', ';
    formattedDuration += '$minutes minuto${minutes > 1 ? 's' : ''}';
  }

  return formattedDuration;
}

String suma(String tiempo1, String valor) {
  // Definir la cadena de tiempo en el formato "02:00".
  // String tiempo1 = '00:00';
  String tiempo2 = valor;

  // Dividir las cadenas en horas y minutos.
  List<String> partes1 = tiempo1.split(":");
  List<String> partes2 = tiempo2.split(":");

  // Convertir las partes en valores numéricos.
  int horas1 = int.parse(partes1[0]);
  int minutos1 = int.parse(partes1[1]);
  int horas2 = int.parse(partes2[0]);
  int minutos2 = int.parse(partes2[1]);

  // Realizar la suma de horas y minutos.
  int totalHoras = horas1 + horas2;
  int totalMinutos = minutos1 + minutos2;

  // Manejar el desbordamiento de minutos (más de 60) ajustando las horas.
  if (totalMinutos >= 60) {
    totalHoras += totalMinutos ~/ 60;
    totalMinutos = totalMinutos % 60;
  }

  // Formatear el resultado en el formato deseado.
  String resultado =
      "${totalHoras.toString().padLeft(2, '0')}:${totalMinutos.toString().padLeft(2, '0')}";

  // print("Resultado de la suma: $resultado");

  return resultado;
}
