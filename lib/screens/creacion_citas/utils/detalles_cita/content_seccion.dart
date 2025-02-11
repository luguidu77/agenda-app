import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/widgets_detalle_cita.dart';
import 'package:flutter/material.dart';

class ContentSection extends StatelessWidget {
  final CitaModelFirebase reserva;
  final PersonalizaModelFirebase personaliza;
  final emailUsuario;
  const ContentSection({
    required this.reserva,
    required this.personaliza,
    required this.emailUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECCION DEL CLIENTE
        WidgetsDetalleCita.vercliente(context, reserva),
        // SECCION DE LA CITA
        WidgetsDetalleCita.fechaCita(context, reserva),
        // SECCION DE SERVICIOS
        WidgetsDetalleCita.servicios(context, reserva, personaliza),
      ],
    );
  }
}
