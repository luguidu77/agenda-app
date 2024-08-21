import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final tituloEstilo = GoogleFonts.bebasNeue(fontSize: 40);

final subTituloEstilo = GoogleFonts.bebasNeue(
    fontSize: 20,
    textStyle: const TextStyle(color: Color.fromARGB(255, 187, 176, 176)));

final textoEstilo = GoogleFonts.bebasNeue(
    fontSize: 15,
    textStyle: const TextStyle(color: Color.fromARGB(255, 104, 103, 103)));
final textoTelefonoEstilo = GoogleFonts.bebasNeue(
    fontSize: 20,
    textStyle: const TextStyle(color: Color.fromARGB(255, 49, 47, 47)));

final colorFondo = Colors.grey[300];

final textoPequenoEstilo = GoogleFonts.bebasNeue(
    fontSize: 10,
    textStyle: const TextStyle(color: Color.fromARGB(255, 104, 103, 103)));

const String mensajeYaExisteCliente =
    'Ya existe el teléfono asociado al contacto:';

final estiloHorarios = GoogleFonts.bebasNeue(
  fontSize: 25,
);
final estiloHorariosAlgoDifuminado = GoogleFonts.bebasNeue(
  fontSize: 24,
  color: const Color.fromARGB(255, 130, 130, 131),
);
final estiloHorariosDifuminado = GoogleFonts.bebasNeue(
  fontSize: 23,
  color: const Color.fromARGB(255, 211, 211, 212),
);
final estiloHorariosResaltado =
    GoogleFonts.bebasNeue(fontSize: 24, fontWeight: FontWeight.bold);
