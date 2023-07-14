import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../screens/screens.dart';
import '../utils/utils.dart';

class ListaCitasNuevo extends StatefulWidget {
  const ListaCitasNuevo(
      {super.key, required this.fechaElegida, required this.citas});
  final DateTime fechaElegida;
  final List<dynamic> citas;
  @override
  _ListaCitasNuevoState createState() => _ListaCitasNuevoState();
}

class _ListaCitasNuevoState extends State<ListaCitasNuevo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // ················   Config calendario ······································
        body: SfCalendar(
      appointmentTextStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      headerHeight: 0, // oculta fecha
      allowDragAndDrop: true,
      onTap: (CalendarTapDetails details) {
        DateTime date = details.date!;
        dynamic appointments = details.appointments;
        CalendarElement view = details.targetElement;

        Map<String, dynamic> cita = json.decode(appointments[0].notes);
        print(cita);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallesCitaScreen(reserva: cita),
          ),
        );
      },
      view: CalendarView.day,
      initialDisplayDate: widget.fechaElegida,
      dataSource: MeetingDataSource(getAppointments()),
    ));
  }

  List<Appointment> getAppointments() {
    List<Appointment> meetings = <Appointment>[];
    for (var cita in widget.citas) {
      String horaInicio =
          FormatearFechaHora().formatearHora(cita['horaInicio'].toString());
      String horaFinal =
          FormatearFechaHora().formatearHora(cita['horaFinal'].toString());
      print('@@@@@@@@@@@@@@@@@@@@@@');
      print(cita['id']);

      final DateTime fechaInicio = DateTime.parse(cita['horaInicio']);
      final DateTime fechaFinal = DateTime.parse(cita['horaFinal']);
      final DateTime startTime = DateTime(fechaInicio.year, fechaInicio.month,
          fechaInicio.day, fechaInicio.hour, 0, 0);
      final DateTime endTime = DateTime(fechaFinal.year, fechaFinal.month,
          fechaFinal.day, fechaFinal.hour, 0, 0);

      meetings.add(Appointment(
          notes:
              '{"id": "${cita['id']}","idCliente": "${cita['idCliente']}","idEmpleado": "${cita['idEmpleado']}","idServicio": "${cita['idServicio']}","nombre": "${cita['nombre']}", "horaInicio": "${cita['horaInicio']}", "telefono": " ${cita['telefono']}", "email":" ${cita['email']}", "servicio":" ${cita['servicio']}", "detalle":" ${cita['detalle'].toString()}" ,"precio":" ${cita['precio']}","foto" : "${cita['foto']}", "comentario":" ${cita['comentario']}"}',
          id: cita['id'],
          startTime: startTime,
          endTime: endTime,
          subject:
              '$horaInicio - $horaFinal  ${cita['nombre']} : ${cita['servicio']}',
          //location: 'es-ES',
          color: fechaFinal.isBefore(DateTime.now())
              ? Colors.red
              : Colors.blueAccent));
    }
    print(meetings);
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
