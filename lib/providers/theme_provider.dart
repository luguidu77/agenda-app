import 'package:agendacitas/providers/db_provider.dart';
import 'package:flutter/material.dart';

import '../models/tema_model.dart';

class ThemeProvider extends ChangeNotifier {
  List<TemaModel> colorGuardado =
      []; // lista para interactuar con la base de datos Tema

  ThemeMode themeMode = ThemeMode.light;

  bool get isLightMode => themeMode == ThemeMode.light;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  ThemeData _mitemalight = ThemeData();
  ThemeData get mitemalight => _mitemalight;
  set themeData(ThemeData themeData) {
    _mitemalight = themeData;
    notifyListeners(); // Notificar a los consumidores sobre el cambio
  }

  Future<TemaModel> nuevoTema(int color) async {
    final nuevoColor = TemaModel(
      id: 0,
      color: color,
    );

    final id = await DBProvider.db.nuevoTema(nuevoColor);

    //asinar el ID de la base de datos al modelo
    nuevoColor.id = id;

    colorGuardado.add(nuevoColor);
    notifyListeners();

    return nuevoColor;
  }

  Future<List<TemaModel>> cargarTema() async {
    final colorGuardado = await DBProvider.db.getTema();

    this.colorGuardado = [...colorGuardado];
    notifyListeners();

    return colorGuardado;
  }

  acutalizarTema(int color) async {
    await DBProvider.db.actualizarTema(color);
    cargarTema();
  }
}

class MyTheme {
  static final darkTheme = ThemeData(
    // useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(),
    textTheme: const TextTheme(
      // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ),
  );
}
