import 'dart:math';

String generarCadenaAleatoria(int longitud) {
  const String chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      longitud, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
