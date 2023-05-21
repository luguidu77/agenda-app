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
}
