import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class BotoLeidoNotifAdministrador extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final String emailSesionUsuario;

  const BotoLeidoNotifAdministrador({
    required this.notificacion,
    required this.emailSesionUsuario,
    Key? key,
  }) : super(key: key);

  @override
  State<BotoLeidoNotifAdministrador> createState() =>
      _BotoLeidoNotifAdministradorState();
}

class _BotoLeidoNotifAdministradorState
    extends State<BotoLeidoNotifAdministrador> {
  bool _visto = false;
  final bool _cargando = false;

  @override
  void initState() {
    // para verficar si el usuario ha leido la notificacion del administrador, comprueba si existe su email en la lista vistoPor
    List<dynamic> vistoPor = widget.notificacion['vistoPor'];
    _visto = vistoPor.contains(widget.emailSesionUsuario);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: _visto ? Colors.blueGrey : Colors.blue,
      onPressed: () async {},
      icon: _cargando
          ? const SizedBox(
              width: 15, height: 15, child: CircularProgressIndicator())
          : Icon(
              _visto ? Icons.circle_outlined : Icons.circle,
            ),
    );
  }

  void mensaje(texto) {
    mensajeSuccess(context, texto);
  }
}
