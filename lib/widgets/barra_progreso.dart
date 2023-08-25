import 'package:flutter/material.dart';

class BarraProgreso {
  progreso(context, double progreso, Color color) {
    return SizedBox(
      child: LinearProgressIndicator(
        color: color,
        minHeight: 5,
        value: progreso,
        backgroundColor: const Color.fromARGB(255, 245, 230, 230),
      ),
    );
  }
}
