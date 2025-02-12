import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/utils/actualizacion_cita.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BotonGuardarCambios extends StatelessWidget {
  const BotonGuardarCambios({super.key});

  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CreacionCitaProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Alinea el botón a la derecha
      children: [
        InkWell(
          onTap: () => _alertaActualizar(context, citaProvider.contextoCita),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  static void _alertaActualizar(
      BuildContext context, CitaModelFirebase citaElegida) async {
    final citaProvider = context.read<CreacionCitaProvider>();
    final EmailAdministradorAppProvider emailUsuarioProvider =
        context.read<EmailAdministradorAppProvider>();
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(spacing: 10, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('check'),
                      Text('Notificar a ${citaElegida.nombreCliente}')
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        ////XXxxxx FUNCION actualizar la cita en Firebase  xxxxxXX
                        await ActualizacionCita.actualizar(
                          context,
                          citaElegida,
                          null,
                          citaElegida.dia,
                          citaElegida.horaInicio,
                          emailUsuarioProvider.emailAdministradorApp,
                        );
                        citaProvider.setVisibleGuardar(false);
                      },
                      child: Text('Actualizar'))
                ]),
              ));
        });
  }
}
