import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../providers/Firebase/notificaciones.dart';
import '../../providers/buttom_nav_notificaciones_provider.dart';
import '../../providers/providers.dart';

class BNavigator extends StatefulWidget {
  final int index;
  final Function currentIndex;
  const BNavigator({Key? key, required this.currentIndex, required this.index})
      : super(key: key);

  @override
  State<BNavigator> createState() => _BNavigatorState();
}

class _BNavigatorState extends State<BNavigator> {
  int index = 0;

  IconData iconoNotificaciones = Icons.notification_important_outlined;
  String textoNotificaciones = '';
  Color colorIconoNotificaciones = Colors.red;
  late String _emailSesionUsuario;

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  @override
  void initState() {
    inicializacion();
    contadorNotificacionesCitasNoLeidas(context, _emailSesionUsuario);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    hayNorificacionesNoleidas(_emailSesionUsuario);
    int index = widget.index;
    Color colorTema = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          backgroundColor: Colors.transparent,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          gap: 7,
          duration: const Duration(milliseconds: 900),
          tabBackgroundColor: colorTema.withOpacity(0.3),
          color: Colors.grey,
          activeColor: Colors.white,
          curve: Curves.easeInCubic,
          tabBorderRadius: 15,
          tabs: [
            const GButton(
              icon: Icons.calendar_month_outlined,
              text: 'Citas',
            ),
            GButton(
              iconColor: colorIconoNotificaciones,
              icon: iconoNotificaciones,
              text: textoNotificaciones,
            ),
            const GButton(
              icon: Icons.people_alt,
              text: 'Clientes',
            ),
            const GButton(
              icon: Icons.menu,
              text: 'Menu',
            ),
          ],
          selectedIndex: index,
          onTabChange: (i) {
            setState(() {
              index = i;
              widget.currentIndex(i);
            });
          },
        ),
      ),
    );
  }

  hayNorificacionesNoleidas(email) async {
    final contadorNotificaciones =
        context.watch<ButtomNavNotificacionesProvider>();
    int contNotif = contadorNotificaciones.contadorNotificaciones;

    print(
        '**************************************hay notificaciones no leidas ?   ${contadorNotificaciones}');

    contNotif != 0
        ? iconoNotificaciones = Icons.notifications_active_outlined
        : iconoNotificaciones = Icons.notifications_none;

    contNotif != 0
        ? textoNotificaciones = 'Buzón🔸$contNotif'
        : textoNotificaciones = 'Buzón';

    contNotif != 0
        ? colorIconoNotificaciones = Colors.red
        : colorIconoNotificaciones = Colors.grey;
  }
}
