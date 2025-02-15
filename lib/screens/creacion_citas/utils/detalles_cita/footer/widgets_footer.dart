import 'package:flutter/material.dart';

class WidgetsFooter {
  static Widget boton(String texto, Function funcion) {
    return InkWell(
      onTap: () => funcion(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          texto,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
