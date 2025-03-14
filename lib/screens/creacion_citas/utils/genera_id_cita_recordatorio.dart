class UtilsRecordatorios {
  static Future<int> idRecordatorio(DateTime fecha) async {
    // Sumar año, mes, día, hora y minutos, y reducir a 4 dígitos
    int id =
        (fecha.year + fecha.month + fecha.day + fecha.hour + fecha.minute) %
            10000;
    return id; // Ejemplo: 2083
  }
}
