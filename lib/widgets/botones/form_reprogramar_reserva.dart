//todo: pendiente hacer este boton para confirmar la cita

import 'package:agendacitas/widgets/selecciona_dia.dart';
import 'package:flutter/material.dart';

class FormReprogramaReserva extends StatefulWidget {
  const FormReprogramaReserva(
      {Key? key, required this.idServicio, required this.cita})
      : super(key: key);
  final dynamic idServicio;
  final Map<String, dynamic> cita;
  @override
  State<FormReprogramaReserva> createState() => _FormReprogramaReservaState();
}

class _FormReprogramaReservaState extends State<FormReprogramaReserva> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SeleccionaDia(
          botonReprogramarVisible: true,
          idServicio: widget.idServicio,
          cita: widget.cita),
    );
  }
}
