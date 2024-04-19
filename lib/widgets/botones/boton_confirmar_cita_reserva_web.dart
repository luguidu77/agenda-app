import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/Firebase/notificaciones.dart';

import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class BotonConfirmarCitaWeb extends StatefulWidget {
  final dynamic cita;
  final String emailUsuario;

  const BotonConfirmarCitaWeb({
    required this.cita,
    required this.emailUsuario,
    Key? key,
  }) : super(key: key);

  @override
  State<BotonConfirmarCitaWeb> createState() => _BotonConfirmarCitaWebState();
}

class _BotonConfirmarCitaWebState extends State<BotonConfirmarCitaWeb> {
  bool _visto = false;
  bool _cargando = false;

  @override
  void initState() {
    _visto = widget.cita['confirmada'] == 'true' ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool clienteTieneCuentaWeb =
        widget.cita['tokenWebCliente'] != '' ? true : false;

    return ListTile(
        title: _visto
            ? const Text('🗓️ CONFIRMADA')
            : const Text(
                '❌ NO CONFIRMADA',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
        trailing: ElevatedButton(
          // color: _visto ? Colors.blueGrey : Colors.blue,
          onPressed: clienteTieneCuentaWeb ? _cambiaEstadoConfirmacion : null,
          child: _cargando
              ? const SizedBox(
                  width: 15, height: 15, child: LinearProgressIndicator())
              : Text(_visto ? 'Anular' : 'Confirmar'),
        ));
  }

  _cambiaEstadoConfirmacion() async {
    setState(() {
      _cargando = true; // Muestra el indicador de carga
    });

    //** 1 modifica el estado de confirmada en perfil  del cliente (clienteAgendoWeb)*/

    FirebaseProvider()
        .cambiarEstadoConfirmacionCitaCliente(widget.cita, widget.emailUsuario);
    //
    //** cambian el estado de confirmada la cita en agendadecitas */

    // Cambiar estado en Firebase
    await FirebaseProvider()
        .cambiarEstadoConfirmacionCita(widget.emailUsuario, widget.cita['id']);

    // Cambiar estado local
    setState(() {
      _visto = !_visto;
      _cargando = false; // Oculta el indicador de carga
    });
    // Mostrar mensaje
    mensaje(_visto ? 'Cita confirmada' : 'Cita anulada');
  }

  void mensaje(texto) {
    mensajeSuccess(context, texto);
  }
}

/* IconButton(
                          onPressed: ()=>ConfirmaCita(),
                          icon: cita['confirmada'] == 'true'
                              ? Text('ANULAR')
                              : Text('CONFIRMAR')), */