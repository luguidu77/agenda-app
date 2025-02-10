import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/estado_confirmacion_cita.dart';
import 'package:agendacitas/widgets/botones/boton_confirmar_cita_reserva_web.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String fecha;
  final CitaModelFirebase reserva;
  final bool citaconfirmada;

  const HeaderSection({
    required this.fecha,
    required this.reserva,
    required this.citaconfirmada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: citaconfirmada ? Colors.blue : Colors.red,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                fecha,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
