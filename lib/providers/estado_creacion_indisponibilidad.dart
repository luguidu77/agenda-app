import 'package:agendacitas/utils/alertasSnackBar.dart';
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

  int get paginaActual => _paginaActual;

  void paginaAnterior() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
      _actualizarPaginaActual();
    }
  }

  void paginaSiguiente() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
      _actualizarPaginaActual();
    }
  }

  void setea(int pagina) {
    if (_pageController.hasClients) {
      if (pagina < 0 || pagina >= _pageController.positions.length) {
        print('Página fuera de los límites: $pagina');
        return; // Si la página está fuera de los límites, no hacer nada
      }

      _paginaActual = pagina;
      _pageController.jumpToPage(_paginaActual);
      notifyListeners();
    } else {
      print('El PageController no tiene clientes.');
    }
  }

  void resetPagina() {
    if (_pageController.hasClients) {
      _paginaActual = 0; // Restablece la página a la inicial (0)
      _pageController.jumpToPage(_paginaActual);
      notifyListeners();
    }
  }

  void _actualizarPaginaActual() {
    if (_pageController.hasClients) {
      _paginaActual = _pageController.page?.toInt() ?? 0;
      notifyListeners();
    }
  }
}

class TextoTituloIndispuesto extends ChangeNotifier {
  String _titulo = '';

  String get getTitulo => _titulo;

  void setTitulo(String titulo) {
    _titulo = titulo;
    notifyListeners();
  }
}
