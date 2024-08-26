import 'package:flutter/material.dart';

class BotonAgregarIndisponibilidadProvider extends ChangeNotifier {
  bool _botonPulsado = false;

  bool get botonPulsado => _botonPulsado;

  setBotonPulsadoIndisponibilidad(bool p) async {
    _botonPulsado = p;
    notifyListeners();
  }
}

class BotonGuardarAgregarNoDisponible extends ChangeNotifier {
  bool _visible = true;

  bool get forularioVisible => _visible;

  setBotonGuardar(bool p) async {
    _visible = p;
    notifyListeners();
  }
}

class FechaElegida extends ChangeNotifier {
  DateTime _fechaElegida = DateTime(0);

  DateTime get fechaElegida => _fechaElegida;

  setFechaElegida(DateTime hora) async {
    _fechaElegida = hora;
    notifyListeners();
  }
}

class HorarioElegidoCarrusel extends ChangeNotifier {
  DateTime _horaInicio = DateTime(0);
  DateTime _horaFin = DateTime(0);

  DateTime get horaInicio => _horaInicio;
  DateTime get horaFin => _horaFin;

  setHoraInicio(DateTime hora) async {
    _horaInicio = hora;
    notifyListeners();
  }

  setHoraFin(DateTime hora) async {
    _horaFin = hora;
    notifyListeners();
  }
}

class ControladorTarjetasAsuntos extends ChangeNotifier {
  PageController _pageController;
  int _paginaActual = 0; // Almacena la página actual

  ControladorTarjetasAsuntos()
      : _pageController = PageController(
          initialPage: 0,
          viewportFraction: 0.5,
        );

  PageController get controller => _pageController;

  void paginaAnterior() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
    _paginaActual = _pageController.page?.toInt() ?? 0;
    notifyListeners();
  }

  void paginaSiguiente() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
    _paginaActual = _pageController.page?.toInt() ?? 0;
    notifyListeners();
  }

  void setea(int pagina) {
    _paginaActual = pagina;
    _pageController.jumpToPage(_paginaActual);
    notifyListeners();
  }
}
