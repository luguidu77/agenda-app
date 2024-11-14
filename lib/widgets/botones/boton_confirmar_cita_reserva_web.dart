import 'package:agendacitas/providers/providers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _citaconfirmada = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final citaconfirmada =
        Provider.of<EstadoConfirmacionCita>(context, listen: true);
    _citaconfirmada = citaconfirmada.estadoCita;
    bool clienteTieneToken =
        widget.cita['tokenWebCliente'] != '' ? true : false;

    return ListTile(
        title: _citaconfirmada
            ? const Text('CITA CONFIRMADA',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))
            : const Text(
                'CITA SIN CONFIRMAR',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
        trailing: FloatingActionButton(
          mini: true,
          backgroundColor: _citaconfirmada ? Colors.redAccent : Colors.blue,
          onPressed: _cambiaEstadoConfirmacion,
          child: _cargando
              ? const SizedBox(
                  width: 15, height: 15, child: CircularProgressIndicator())
              : Icon(_citaconfirmada ? Icons.cancel : Icons.check,
                  color: Colors.white),
        ));

    /*   ElevatedButton(
          // color: _visto ? Colors.blueGrey : Colors.blue,
          onPressed: _cambiaEstadoConfirmacion,
          child: _cargando
              ? const SizedBox(
                  width: 15, height: 15, child: LinearProgressIndicator())
              : Text(_visto ? 'Anular' : 'Confirmar'),
        )); */
  }

  _cambiaEstadoConfirmacion() async {
    setState(() {
      _cargando = true; // Muestra el indicador de carga
    });

    //** 1 modifica el estado de confirmada en perfil  del cliente (clienteAgendoWeb)*/

    await FirebaseProvider().cambiarEstadoConfirmacionCitaCliente(
        context, widget.cita, widget.emailUsuario);
    //
    //** cambian el estado de confirmada la cita en agendadecitas */

    // Cambiar estado en Firebase
    await FirebaseProvider()
        .cambiarEstadoConfirmacionCita(widget.emailUsuario, widget.cita['id']);

    //todo: enviar notificacion (web o appcliente) al cliente en caso de existir token

    // Cambiar estado local
    setState(() {
      final citaconfirmada =
          Provider.of<EstadoConfirmacionCita>(context, listen: false);
      citaconfirmada.setEstadoCita(!_citaconfirmada);

      _citaconfirmada = citaconfirmada.estadoCita;
      _cargando = false; // Oculta el indicador de carga
    });
  }
}

/* IconButton(
                          onPressed: ()=>ConfirmaCita(),
                          icon: cita['confirmada'] == 'true'
                              ? Text('ANULAR')
                              : Text('CONFIRMAR')), */
