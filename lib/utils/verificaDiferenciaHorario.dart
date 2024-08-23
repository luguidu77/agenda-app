import 'package:agendacitas/providers/estado_creacion_indisponibilidad.dart';

class Verificadiferenciahorario {
  static verificarBotonActivado(
      HorarioElegidoCarrusel providerHoraFinCarrusel) {
    bool botonActivado = false;

    bool nuevoEstado = !providerHoraFinCarrusel.horaInicio.isAfter(
        providerHoraFinCarrusel.horaFin.subtract(const Duration(
            minutes:
                15))); // sustrae 15 minutos para que las horas no sean las mismas
    if (botonActivado != nuevoEstado) {
      // setState(() {
      botonActivado = nuevoEstado;
      print("Estado del botón cambiado: $nuevoEstado");
      // });
    }
    return nuevoEstado;
  }
}
