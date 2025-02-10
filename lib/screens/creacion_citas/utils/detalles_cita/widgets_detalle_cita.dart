import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/providers.dart';
import 'package:agendacitas/utils/formatear.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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

  static fechaCita(context, CitaModelFirebase citaElegida) {
    seleccionaDia() {
/*     // abre un menu que sale desde abajo de la pantalla con un calendario para seleccionar fecha
    showModalBottomSheet(
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
                    setState(() {
                      String dia = formatearFechaDiaCita(date);

                      // Fecha String : dia ("2025-01-26")
                      contextoCreacionCita.contextoCita.dia = dia;
                      DateTime nuevoDia = DateTime.parse(dia);
                      // hora de inicio "2025-01-26 10:30:00.000"
                      contextoCreacionCita.contextoCita.horaInicio = DateTime(
                          nuevoDia.year,
                          nuevoDia.month,
                          nuevoDia.day,
                          contextoCreacionCita.contextoCita.horaInicio!.hour,
                          contextoCreacionCita.contextoCita.horaInicio!.minute);
                      // hora de finalizacion "2025-01-26 12:30:00.000"
                      contextoCreacionCita.contextoCita.horaFinal = DateTime(
                          nuevoDia.year,
                          nuevoDia.month,
                          nuevoDia.day,
                          contextoCreacionCita.contextoCita.horaFinal!.hour,
                          contextoCreacionCita.contextoCita.horaFinal!.minute);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    ); */
    }

    seleccionHora() {
      // abre un menu que sale desde abajo de la pantalla con todas las horas del dia en formato 00:00 de 5 minutos
      /*  showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final tiempo = horafinal.difference(horainicio);
        final selectedHour = contextoCreacionCita.contextoCita.horaInicio!.hour;
        final selectedMinute =
            contextoCreacionCita.contextoCita.horaInicio!.minute;
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
                        setState(() {
                          final dia = contextoCreacionCita.contextoCita.dia;
                          DateTime fecha = DateTime.parse(dia!);

                          contextoCreacionCita.contextoCita.horaInicio =
                              DateTime(fecha.year, fecha.month, fecha.day, hour,
                                  minute);

                          contextoCreacionCita.contextoCita.horaFinal =
                              contextoCreacionCita.contextoCita.horaInicio!
                                  .add(tiempo);
                        });
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
    ); */
    }

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
                  onTap: () => seleccionaDia(),
                  child: Text(DateFormat.MMMEd('es_ES').format(
                      DateTime.parse(citaElegida.horaInicio.toString()))),
                ),
                const SizedBox(
                  width: 80,
                ),
                const Icon(Icons.watch_later_outlined),
                InkWell(
                  onTap: () => seleccionHora(),
                  child: Text(
                    DateFormat.Hm('es_ES').format(
                        DateTime.parse(citaElegida.horaInicio.toString())),
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

    Widget cardServicios(String idservicio, citaElegida) {
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
                        '${servicio!.servicio} : $tiempo',
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
                    precio.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                    child: cardServicios(idservicios[index], citaElegida));
              },
            ),
          ),
        ],
      ),
    );
  }
}
