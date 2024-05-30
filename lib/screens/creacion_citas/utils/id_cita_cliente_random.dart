import 'dart:math';

String generarCadenaAleatoria(int longitud) {
  const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random _rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      longitud, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
