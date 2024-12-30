//todo: pendiente hacer este boton para confirmar la cita

import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/selecciona_dia.dart';
import 'package:flutter/material.dart';

class FormReprogramaReserva extends StatefulWidget {
  const FormReprogramaReserva({Key? key, required this.cita}) : super(key: key);

  final CitaModelFirebase cita;
  @override
  State<FormReprogramaReserva> createState() => _FormReprogramaReservaState();
}

class _FormReprogramaReservaState extends State<FormReprogramaReserva> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Reasignación de la cita',
          style: textoEstilo,
        ),
        Text(
          '* También puedes reasignarla arrastrando las tarjetas en el calendario',
          style: textoPequenoEstilo,
        ),
        SeleccionaDia(botonReprogramarVisible: true, cita: widget.cita),
      ],
    );
  }
}
