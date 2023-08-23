import 'package:flutter/material.dart';

AppBar appBarCreacionCita(
    String titulo, bool automaticallyImplyLeading, {Widget? action}) {
  return AppBar(
    automaticallyImplyLeading: automaticallyImplyLeading,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.black,
    title: Text(titulo),
    actions: [action ?? Container()],
  );
}
