import 'package:flutter/material.dart';

const titulo = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

final botonHeaderDetalleCita = ButtonStyle(
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(8.0), // Ajusta el radio del borde si lo deseas
      side: BorderSide(color: Colors.white), // Borde blanco
    ),
  ),
  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
  elevation: WidgetStateProperty.all<double>(0),
);
