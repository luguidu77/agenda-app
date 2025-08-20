import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/footer/estilo_footer.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/footer/boton_guardar_cambios.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';
import 'package:agendacitas/widgets/elimina_cita.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FooterSeccion extends StatelessWidget {
  final CitaModelFirebase reserva;
  final String emailUsuario;
  final CitasProvider contextoCitaProvider;

  const FooterSeccion({super.key, 
    required this.reserva,
    required this.emailUsuario,
    required this.contextoCitaProvider,
  });

  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CreacionCitaProvider>();
    final personalizaProvider = context.read<PersonalizaProviderFirebase>();
    return Container(
        decoration: estiloBorde,
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Ajusta el espacio entre los textos
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontWeight: FontWeight.bold)), // Texto en negrita
                  Text(
                    citaProvider.contextoCita.precio! +
                        personalizaProvider.getPersonaliza.moneda!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ), // Texto en negrita
                ],
              ),
              // botones compartir / boton guardar
              citaProvider.visibleGuardar
                  ? const BotonGuardarCambios()
                  : Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildShareButton(),
                        _buildDeleteButton(context),
                      ],
                    ),
            ],
          ),
        ));
  }

  Widget _buildShareButton() {
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
