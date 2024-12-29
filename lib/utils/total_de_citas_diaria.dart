import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/calendario_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<int> getNumCitas(BuildContext context, String idEmpleado) async {
  int numCitas = 0;

  // TRAIGO TODAS LAS CITAS
  final contextoCitas = context.watch<CitasProvider>();
  List<CitaModelFirebase> todasLasCitas = contextoCitas.getCitas;

  // TRAIGO LA FECHA SELECCIONADA DEL CALENDARIO y FORMATEO LA FECHA SELECCIONADA
  var calendarioProvider = context.watch<CalendarioProvider>();
  DateTime fechaElegida = calendarioProvider.fechaSeleccionada;
  String fechaElegidaFormateada = DateFormat('yyyy-MM-dd').format(fechaElegida);

  // Filtra las citas que coinciden con la fecha elegida y el idEmpleado
  numCitas = todasLasCitas
      .where((value) =>
          value.dia == fechaElegidaFormateada && value.idEmpleado == idEmpleado)
      .length;

  return numCitas;
}
