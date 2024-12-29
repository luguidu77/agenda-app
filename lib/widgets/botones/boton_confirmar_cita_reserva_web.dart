import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/providers.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BotonConfirmarCitaWeb extends StatefulWidget {
  final CitaModelFirebase cita;
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
  late bool _citaconfirmada;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _citaconfirmada = widget.cita.confirmada ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        context.watch<EstadoConfirmacionCita>().estadoCita
            ? 'CITA CONFIRMADA'
            : 'CITA SIN CONFIRMAR',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      trailing: context.watch<EstadoConfirmacionCita>().estadoCita
          ? null
          : _cargando
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _cambiaEstadoConfirmacion,
                  child: const Text('CONFIRMAR'),
                ),
    );
  }

  Future<void> _cambiaEstadoConfirmacion() async {
    setState(() {
      _cargando = true;
    });

    try {
      // Paso 1: Actualizar estado de confirmación en el perfil del cliente
      await FirebaseProvider().cambiarEstadoConfirmacionCitaCliente(
        context,
        widget.cita,
        widget.emailUsuario,
      );

      // Paso 2: Cambiar estado de confirmación en la colección de citas
      await FirebaseProvider().cambiarEstadoConfirmacionCita(
        widget.emailUsuario,
        widget.cita.id,
      );

      // Paso 3: Enviar notificación (si el cliente tiene un token web)
      /*  if (widget.cita.tokenWebCliente?.isNotEmpty ?? false) {
        // Implementar el envío de notificaciones
        await FirebaseProvider().enviarNotificacionConfirmacionCita(
          token: widget.cita.tokenWebCliente!,
          mensaje: 'Tu cita ha sido confirmada.',
        );
      } */

      // Paso 4: Actualizar el estado global
      context.read<CitasProvider>().actualizaEstadoConfirmacionCitaContexto(
            widget.cita,
            true,
          );

      context.read<EstadoConfirmacionCita>().setEstadoCita(true);

      // Actualizar el estado local
      setState(() {
        _citaconfirmada = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar cita: $e')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }
}
