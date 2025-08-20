
import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/content/widgets_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HeaderSection extends StatelessWidget {
  // final String fecha;
  final CitaModelFirebase reserva;
  final bool citaconfirmada;

  const HeaderSection({super.key, 
    //required this.fecha,
    required this.reserva,
    required this.citaconfirmada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          color: citaconfirmada ? Colors.blue : Colors.red,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // FECHA DE LA CITA
              InkWell(
                onTap: () {
                  WidgetsDetalleCita.seleccionaDia(
                      context, reserva, context.read<CreacionCitaProvider>());
                },
                child: Row(
                  spacing: 5,
                  children: [
                    Text(
                      DateFormat('EEE d MMM', 'es_ES').format(context
                          .read<CreacionCitaProvider>()
                          .contextoCita
                          .horaInicio!),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              //TODO BONTON CONFIRMAR CITA
              /*  Container(
                  height: 50,
                  width: 120,
                  child: BotonConfirmarCitaWeb(
                      cita: reserva, emailUsuario: reserva.email!)), */
              ElevatedButton(
                style: botonHeaderDetalleCita,
                onPressed: null,
                child: const Text(
                  'Reservada',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
