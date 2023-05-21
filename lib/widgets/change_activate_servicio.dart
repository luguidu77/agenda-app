import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/cita_list_provider.dart';
import 'package:agendacitas/providers/db_provider.dart';

import 'package:flutter/material.dart';

class ChangeActivateServicioButtonWidget extends StatefulWidget {
  final dynamic servicio;

  final bool iniciadaSesionUsuario;
  final String usuarioAPP;

  const ChangeActivateServicioButtonWidget(
      {Key? key,
      required this.servicio,
      required this.iniciadaSesionUsuario,
      required this.usuarioAPP})
      : super(key: key);

  @override
  State<ChangeActivateServicioButtonWidget> createState() =>
      _ChangeActivateServicioButtonWidgetState();
}

String detectChange(data) {
  debugPrint(data);
  return 'data';
}

class _ChangeActivateServicioButtonWidgetState
    extends State<ChangeActivateServicioButtonWidget> {
  bool val = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    val = /* (widget.iniciadaSesionUsuario)
        ? (widget.servicio['activo'] == 'true' &&
                widget.servicio['activo'] != null)
            ? true
            : false
        :  */
        (widget.servicio.activo == 'true' && widget.servicio.activo != null)
            ? true
            : false;

    return Column(
      children: [
        Text(
          val ? 'Activo' : 'Desactivo',
          style: const TextStyle(fontSize: 8),
        ),
        Switch.adaptive(
          //  activeThumbImage: const AssetImage('./assets/icon/sol.png'),
          //  inactiveThumbImage: const AssetImage('./assets/icon/luna.png'),
          activeColor: Colors.orange,
          value: val, //themeProvider.isLightMode,
          onChanged: (value) {
            setState(() {
              value = !val;

              if (widget.iniciadaSesionUsuario) {
                ServicioModelFB servicio = widget.servicio;

                servicio.activo = '$value';
                debugPrint('ACUTALIZO EN FIREBASE');
                FirebaseProvider()
                    .actualizarServicioFB(widget.usuarioAPP, widget.servicio);
              } else {
                ServicioModel servicio = widget.servicio;

                servicio.activo = '$value';
                debugPrint('ACUTALIZO EN DISPOSITIVO');
                CitaListProvider().acutalizarServicio(servicio);
              }
            });
          },
        ),
      ],
    );
  }
}
