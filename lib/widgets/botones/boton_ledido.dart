import 'package:agendacitas/providers/Firebase/firebase_provider.dart';

import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class BotonLedido extends StatefulWidget {
  final Map<String, dynamic> notificacion;
  final String emailSesionUsuario;

  const BotonLedido({
    required this.notificacion,
    required this.emailSesionUsuario,
    Key? key,
  }) : super(key: key);

  @override
  State<BotonLedido> createState() => _BotonLedidoState();
}

class _BotonLedidoState extends State<BotonLedido> {
  bool _visto = false;
  bool _cargando = false;

  @override
  void initState() {
    _visto = widget.notificacion['visto'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: _visto ? Colors.blueGrey : Colors.blue,
      onPressed: () async {
        setState(() {
          _cargando = true; // Muestra el indicador de carga
        });

        // Cambiar estado en Firebase
        await FirebaseProvider().cambiarEstadoVisto(
            widget.emailSesionUsuario, widget.notificacion['id']);

        // Cambiar estado local
        setState(() {
          _visto = !_visto;
          _cargando = false; // Oculta el indicador de carga
        });
        // Mostrar mensaje
        mensaje(_visto
            ? 'Notificación marcada como leída'
            : 'Notificación marcada como no leída');
      },
      icon: _cargando
          ? const SizedBox(
              width: 15, height: 15, child: LinearProgressIndicator())
          : Icon(
              _visto
                  ? Icons.mark_chat_read_outlined
                  : Icons.mark_chat_unread_outlined,
            ),
    );
  }

  void mensaje(texto) {
    mensajeSuccess(context, texto);
  }
}
