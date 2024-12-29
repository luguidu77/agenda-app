import 'dart:math';

Future<String> generarCadenaAleatoria(int longitud) async {
  const String chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      longitud, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
