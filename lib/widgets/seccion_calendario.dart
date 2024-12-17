import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/calendario_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_creacion_indisponibilidad.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/widgets/lista_de_citas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SeccionCalendario extends StatefulWidget {
  const SeccionCalendario({
    super.key,
  });

  @override
  State<SeccionCalendario> createState() => _SeccionCalendarioState();
}

class _SeccionCalendarioState extends State<SeccionCalendario> {
  @override
  Widget build(BuildContext context) {
    final calendarioProvider = context.watch<CalendarioProvider>();
    DateTime fechaElegida = calendarioProvider.fechaSeleccionada;

    final citasProvider = context.watch<CitasProvider>();
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    var fecha = dateFormat.format(fechaElegida);
    return todasLasCitas(
      context,
      fecha,
      fechaElegida,
      citasProvider,
      contextoCreacionCita,
    );
  }

  todasLasCitas(
    BuildContext context,
    String fecha,
    DateTime fechaElegida,
    CitasProvider citasProvider,
    CreacionCitaProvider contextoCreacionCita,
  ) {
    print("Total citas en el contexto: ${citasProvider.getCitas.length}");

    final citas = citasProvider.getCitas; // Lista de citas actualizada
    String idEmpleado =
        contextoCreacionCita.contextoCita.idEmpleado ?? 'TODOS_EMPLEADOS';

    // Filtrar citas por fecha y empleado
    List<CitaModelFirebase> citasFiltradas =
        citasProvider.getCitas.where((cita) {
      // Filtrar por fecha
      bool mismoDia = cita.dia == fecha;
      // Filtrar por empleado si corresponde
      bool mismoEmpleado =
          idEmpleado == 'TODOS_EMPLEADOS' || cita.idEmpleado == idEmpleado;
      return mismoDia && mismoEmpleado;
    }).toList();

    print("Total citas filtradas: ${citasFiltradas.length}");
    final empleados = context.watch<EmpleadosProvider>().getEmpleados;

    return vercitas(
      context,
      citasFiltradas,
      empleados,
      todasLasCitasConteoPorEmpleado: citas,
    );
  }

  vercitas(BuildContext context, List<CitaModelFirebase> citas, empleados,
      {List<CitaModelFirebase> todasLasCitasConteoPorEmpleado = const []}) {
    return
        // ########## TARJETAS DE LAS CITAS CONCERTADAS ##############################
        //  SYNCFUSION
        Expanded(child: ListaCitasNuevo(citasFiltradas: citas));
  }
}
