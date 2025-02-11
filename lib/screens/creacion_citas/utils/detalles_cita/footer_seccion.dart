import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/widgets/botones/form_reprogramar_reserva.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';
import 'package:agendacitas/widgets/elimina_cita.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActionButtons extends StatelessWidget {
  final CitaModelFirebase reserva;
  final String emailUsuario;
  final CitasProvider contextoCitaProvider;

  const ActionButtons({
    required this.reserva,
    required this.emailUsuario,
    required this.contextoCitaProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildShareButton(),
            _buildReassignButton(context),
            _buildDeleteButton(context),
            Text(reserva.precio!)
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    String fechaCorta =
        DateFormat('EEE d MMM', 'es_ES').add_Hm().format((reserva.horaInicio!));
    return CompartirCitaConCliente(
      cliente: reserva.nombreCliente!,
      telefono: reserva.telefonoCliente!,
      email: reserva.email,
      fechaCita: reserva.horaInicio!.toString(),
      servicio: reserva.servicios!
          .join(', ')
          .toString(), // [servicio1, servicio2] por lo que le quito los corchetes

      precio: reserva.precio,
    );
  }

  Widget _buildReassignButton(context) {
    return FloatingActionButton(
      heroTag: 'reassignButtonTag',
      mini: true,
      backgroundColor: Colors.deepPurpleAccent,
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: SizedBox(
              height: 400,
              child: ListView(
                children: [
                  FormReprogramaReserva(cita: reserva),
                ],
              ),
            ));
          }),

      // toggleFormulario,
      child: const Icon(Icons.change_circle_outlined),
    );
  }

  Widget _buildDeleteButton(context) {
    return FloatingActionButton(
      heroTag: 'deleteButton',
      mini: true,
      backgroundColor: Colors.redAccent,
      onPressed: () async {
        final res = await mensajeAlerta(context, contextoCitaProvider, 0,
            [reserva], (emailUsuario == '') ? false : true, emailUsuario);

        if (res == true) {
          await FirebaseProvider()
              .cancelacionCitaCliente(reserva, emailUsuario);
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
