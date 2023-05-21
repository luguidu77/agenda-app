import 'package:agendacitas/screens/calendario_screen.dart';
import 'package:agendacitas/screens/clientes_screen.dart';
import 'package:agendacitas/screens/informes_screen.dart';
import 'package:agendacitas/screens/menu_aplicacion.dart';
import 'package:flutter/material.dart';

class RutasNav extends StatelessWidget {
  final int index;
  const RutasNav({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> myList = const [
      CalendarioCitasScreen(),
      InformesScreen(),
      ClientesScreen(),
      MenuAplicacion(),
    ];
    return myList[index];
  }
}
