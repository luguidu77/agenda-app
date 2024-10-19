import 'package:agendacitas/screens/calendario_screen.dart';
import 'package:agendacitas/screens/clientes_screen.dart';
import 'package:agendacitas/screens/menu_aplicacion.dart';
import 'package:agendacitas/screens/notificaciones_screen.dart';
import 'package:flutter/material.dart';

class RutasNav extends StatelessWidget {
  final int index;
  const RutasNav({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> myList = const [
      CalendarioCitasScreen(),
      PaginaNotificacionesScreen(),
      //* InformesScreen(),
      ClientesScreen(),
      MenuAplicacion(),
    ];
    return myList[index];
  }
}
