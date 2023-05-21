

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

  var mitemalight = ThemeData();

  void cambiaColor(color) {
    MaterialColor colorPrimarySwatch = MaterialColor(
      color,
      const <int, Color>{
        50: const Color(0xFFFFFFFF),
        100: const Color(0xFFFFFFFF),
        200: const Color(0xFFFFFFFF),
        300: const Color(0xFFFFFFFF),
        400: const Color(0xFFFFFFFF),
        500: const Color(0xFFFFFFFF),
        600: const Color(0xFFFFFFFF),
        700: const Color(0xFFFFFFFF),
        800: const Color(0xFFFFFFFF),
        900: const Color(0xFFFFFFFF),
      },
    );

    mitemalight = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: colorPrimarySwatch), // const ColorScheme.light(),

      primaryColor: colorPrimarySwatch,
      fontFamily: 'Hind',
      listTileTheme: const ListTileThemeData(textColor: Colors.grey),
      textTheme: const TextTheme(
          // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 14.0, fontStyle: FontStyle.normal),
          bodyMedium: TextStyle(
            fontSize: 18.0,
            fontStyle: FontStyle.normal,
            color: Colors.blueGrey,
          )),
    );

    notifyListeners();
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
    // TemaModel(id: 0, color: color);
    // Map<String, int> tema = {'id': 0, 'color': color};

/*     final newColor = TemaModel(id: 0, color: color);
    print(newColor.color); */
    await DBProvider.db.actualizarTema(color);
  }
}

class MyTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(),
    textTheme: const TextTheme(
      // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    ),
  );
}
