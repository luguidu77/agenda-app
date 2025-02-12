import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/providers.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_confirmar.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/utils/actualizacion_cita.dart';
import 'package:agendacitas/utils/formatear.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WidgetsDetalleCita {
  static vercliente(context, CitaModelFirebase citaElegida) {
    final boxDecoration = BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255, 216, 215, 215), // Color del borde
        width: 1.0, // Grosor del borde
      ),
      borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
      color: Colors.white, // Fondo opcional
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      height: 80.0, // Altura agradable para la vista
      decoration: boxDecoration, // Bordes redondeados
      child: ClipRect(
        child: SizedBox(
          //Banner aqui -----------------------------------------------
          child: Column(
            children: [
              ListTile(
                leading:
                    citaElegida.email != '' && citaElegida.fotoCliente != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(150.0),
                            child: Image.network(
                              citaElegida.fotoCliente.toString(),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(150.0),
                            child: Image.asset(
                              "./assets/images/nofoto.jpg",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                title: Text(
                  citaElegida.nombreCliente.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(citaElegida.telefonoCliente.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static fechaCita(BuildContext context, CitaModelFirebase citaElegida) {
    final citaProvider = context.watch<CreacionCitaProvider>();

    final boxDecoration = BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255, 216, 215, 215), // Color del borde
        width: 1.0, // Grosor del borde
      ),
      borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
      color: Colors.white, // Fondo opcional
    );
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        height: 80.0, // Altura agradable para la vista
        decoration: boxDecoration, // Bordes redondeados
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.calendar_today),
                InkWell(
                  onTap: () =>
                      seleccionaDia(context, citaElegida, citaProvider),
                  child: Text(DateFormat.MMMEd('es_ES').format(
                      DateTime.parse(citaElegida.horaInicio.toString()))),
                ),
                const SizedBox(
                  width: 80,
                ),
                const Icon(Icons.watch_later_outlined),
                InkWell(
                  onTap: () =>
                      seleccionHora(context, citaElegida, citaProvider),
                  child: Text(
                    DateFormat.Hm('es_ES').format(DateTime.parse(
                        citaProvider.contextoCita.horaInicio.toString())),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  static servicios(BuildContext context, CitaModelFirebase citaElegida,
      PersonalizaModelFirebase personaliza) {
    final contextoServiciosOfrecidos =
        context.read<ServiciosOfrecidosProvider>();
    List<ServicioModelFB> _serviciosOfrecidos =
        contextoServiciosOfrecidos.getServicios;

    ///traer los tiempos de servicios  con el idservicio/////////////////////////////
    ServicioModelFB? traeServicioPorId(
        List<ServicioModelFB> todosLosServicios, String idServicio) {
      try {
        final servicio = todosLosServicios
            .firstWhere((servicio) => servicio.id == idServicio);
        return servicio;
      } catch (e) {
        print(
            'Servicio con ID $idServicio no encontrado en _serviciosOfrecidos'); // Mensaje de debug (opcional)
        return null; // Devuelve null si no se encuentra el servicio
      }
    }
    /////////////////////////////////////////////////////////////////////////////////

    Widget cardServicios(BuildContext context, String idservicio, citaElegida) {
      final personalizaProvider = context.read<PersonalizaProviderFirebase>();
      final servicio = traeServicioPorId(_serviciosOfrecidos, idservicio);

      print(servicio!.id);

      print('__________________________________________________');

      final precio = servicio.precio!;
      final tiempo = servicio.tiempo;
      /* */
      ; // contextoServiciosOfrecidos.getServicios.first.tiempo;
      final empleado = citaElegida.nombreEmpleado;
      final horaInicio = citaElegida.horaInicio;
      final hora =
          FormatearFechaHora.formatearFechaYHora(horaInicio!)['horaFormateada'];

      // contextoCreacionCita.getServiciosElegidos[index]['SERVICIO'];

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Eliminar servicio'),
                  content: const Text(
                      '¿Estás seguro de que deseas eliminar este servicio?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el diálogo
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        /*   // Eliminar servicio del contexto
                            contextoCreacionCita
                                .setEliminaItemListaServiciosElegidos = [
                              contextoCreacionCita.getServiciosElegidos[index]
                            ];
                            // Resetear la suma de tiempos
                            sumaTiempos = const Duration(hours: 0, minutes: 0);
                            // Actualizar precio total y tiempo total
                            contextoCita();
                            setState(() {});
                            Navigator.of(context).pop(); // Cerrar el diálogo */
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                            color: Color.fromARGB(
                                255, 206, 45, 34)), // Color rojo para enfatizar
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.blue,
                  width: 5,
                ),
              ),
            ),
            height: 50,
            child: Row(
              // Use Row as the main child of Container
              children: [
                const SizedBox(
                    width:
                        16.0), // Left padding equivalent to ListTile contentPadding
                Expanded(
                  // Use Expanded to take available space and center content
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Vertically center content
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Align text to the start (left)
                    children: [
                      Text(
                        '${servicio.servicio} : $tiempo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis, // Handle long text
                      ),
                      Text(
                        empleado,
                        overflow: TextOverflow.ellipsis, // Handle long text
                      ),
                    ],
                  ),
                ),
                Padding(
                  // Trailing padding equivalent to ListTile contentPadding
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    precio.toString() +
                        personalizaProvider.getPersonaliza.moneda!,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final idservicios = citaElegida.idservicio;
    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Servicios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: idservicios!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    child: cardServicios(
                        context, idservicios[index], citaElegida));
              },
            ),
          ),
          // salva al footer
          const SizedBox(
            height: 150,
          )
        ],
      ),
    );
  }

  // selección del dia mediante calendario
  static seleccionaDia(BuildContext context, CitaModelFirebase citaElegida,
      CreacionCitaProvider citaProvider) async {
    // abre un menu que sale desde abajo de la pantalla con un calendario para seleccionar fecha
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Selecciona una fecha',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (DateTime date) {
                    String dia = formatearFechaDiaCita(date);

                    // Fecha String : dia ("2025-01-26")
                    citaElegida.dia = dia;
                    DateTime nuevoDia = DateTime.parse(dia);
                    // hora de inicio "2025-01-26 10:30:00.000"
                    citaElegida.horaInicio = DateTime(
                        nuevoDia.year,
                        nuevoDia.month,
                        nuevoDia.day,
                        citaElegida.horaInicio!.hour,
                        citaElegida.horaInicio!.minute);

                    // hora de finalizacion "2025-01-26 12:30:00.000"
                    citaElegida.horaFinal = DateTime(
                        nuevoDia.year,
                        nuevoDia.month,
                        nuevoDia.day,
                        citaElegida.horaFinal!.hour,
                        citaElegida.horaFinal!.minute);

                    // guarda en el contexto
                    citaProvider.setContextoCita(citaElegida);
                    // visualiza el footer_guardar_cambios.dart
                    citaProvider.setVisibleGuardar(true);

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static seleccionHora(BuildContext context, CitaModelFirebase citaElegida,
      CreacionCitaProvider citaProvider) {
    // abre un menu que sale desde abajo de la pantalla con todas las horas del dia en formato 00:00 de 5 minutos
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final tiempo =
            citaElegida.horaFinal!.difference(citaElegida.horaInicio!);
        final selectedHour = citaProvider.contextoCita.horaInicio!.hour;
        final selectedMinute = citaProvider.contextoCita.horaInicio!.minute;
        final initialIndex = selectedHour * 12 + (selectedMinute ~/ 5);

        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Selecciona una hora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: ScrollController(
                    initialScrollOffset: initialIndex * 56.0,
                  ),
                  itemCount: 24 * 12, // 24 hours * 12 intervals per hour
                  itemBuilder: (context, index) {
                    final hour = index ~/ 12;
                    final minute = (index % 12) * 5;
                    final time = DateFormat.Hm('es_ES').format(
                      DateTime(0, 0, 0, hour, minute),
                    );
                    final isSelected =
                        selectedHour == hour && selectedMinute == minute;
                    return ListTile(
                      title: Text(
                        time,
                        style: isSelected
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : const TextStyle(color: Colors.grey),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        final dia = citaProvider.contextoCita.dia;
                        DateTime fecha = DateTime.parse(dia!);

                        DateTime horaInicio = DateTime(
                            fecha.year, fecha.month, fecha.day, hour, minute);

                        DateTime horaFinal = horaInicio.add(tiempo);

                        // hora de inicio "2025-01-26 10:30:00.000"
                        citaElegida.horaInicio = DateTime(
                            fecha.year,
                            fecha.month,
                            fecha.day,
                            horaInicio.hour,
                            horaInicio.minute);

                        // hora de finalizacion "2025-01-26 12:30:00.000"
                        citaElegida.horaFinal = DateTime(
                            fecha.year,
                            fecha.month,
                            fecha.day,
                            horaFinal.hour,
                            horaFinal.minute);

                        // guarda en el contexto
                        citaProvider.setContextoCita(citaElegida);
                        // visualiza el footer_guardar_cambios.dart
                        citaProvider.setVisibleGuardar(true);

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
