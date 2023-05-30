import '../config/config.dart';

class DiasDePrueba {
  static getTexto() {
    String duration = perido_de_prueba.inDays.toString();
    List<String> parts = duration.split(':');
    int days = int.parse(parts[0]);

    return '$days';
  }
}
