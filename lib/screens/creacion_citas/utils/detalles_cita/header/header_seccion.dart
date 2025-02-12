import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/estado_confirmacion_cita.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/content/widgets_content.dart';
import 'package:agendacitas/widgets/botones/boton_confirmar_cita_reserva_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HeaderSection extends StatelessWidget {
  // final String fecha;
  final CitaModelFirebase reserva;
  final bool citaconfirmada;

  const HeaderSection({
    //required this.fecha,
    required this.reserva,
    required this.citaconfirmada,
  });

  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CreacionCitaProvider>();

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
                      context, reserva, citaProvider);
                },
                child: Row(
                  spacing: 5,
                  children: [
                    Text(
                      DateFormat('EEE d MMM', 'es_ES')
                          .format(citaProvider.contextoCita.horaInicio!),
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
              // BONTON CONFIRMAR CITA
              Container(
                  height: 50,
                  width: 120,
                  child: BotonConfirmarCitaWeb(
                      cita: reserva, emailUsuario: reserva.email!)),
            ],
          ),
        ),
      ],
    );
  }
}
