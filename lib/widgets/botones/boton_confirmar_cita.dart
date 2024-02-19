import 'package:agendacitas/providers/Firebase/firebase_provider.dart';

import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';

class BotonConfirmarCita extends StatefulWidget {
  final Map<String, dynamic> cita;
  final String emailUsuario;

  const BotonConfirmarCita({
    required this.cita,
    required this.emailUsuario,
    Key? key,
  }) : super(key: key);

  @override
  State<BotonConfirmarCita> createState() => _BotonConfirmarCitaState();
}

class _BotonConfirmarCitaState extends State<BotonConfirmarCita> {
  bool _visto = false;
  bool _cargando = false;

  @override
  void initState() {
    _visto = widget.cita['confirmada'] == 'true' ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () async {
            setState(() {
              _cargando = true; // Muestra el indicador de carga
            });

            //** 1 envia notificacion al cliente agendo web y modifica el estado de confirmada la cita en su perfil */
            // necesito email del idCliente, idCita y tokenclienteweb
            //todo------------------------------

            //
            //** 2 cambian el estado de confirmada la cita en agendadecitas */

            // Cambiar estado en Firebase
            await FirebaseProvider().cambiarEstadoConfirmacionCita(
                widget.emailUsuario, widget.cita['id']);

            // Cambiar estado local
            setState(() {
              _visto = !_visto;
              _cargando = false; // Oculta el indicador de carga
            });
            // Mostrar mensaje
            mensaje(_visto ? 'Cita confirmada' : 'Cita anulada');
          },
          child: _cargando
              ? const SizedBox(
                  width: 15, height: 15, child: LinearProgressIndicator())
              : Text(_visto ? 'Anular' : 'Confirmar'),
        ));
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