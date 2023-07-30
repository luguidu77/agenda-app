import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/models.dart';
import '../providers/providers.dart';
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
  List<Appointment> meetings = <Appointment>[];
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;
  emailUsuarioApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuarioApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      // ················   Config calendario ······································
      viewNavigationMode: ViewNavigationMode.none,
      appointmentTextStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      headerHeight: 0, // oculta fecha
      allowDragAndDrop: true,
      onTap: (CalendarTapDetails details) {
        // DateTime date = details.date!;
        dynamic appointments = details.appointments;
        // CalendarElement view = details.targetElement;

        Map<String, dynamic> cita = json.decode(appointments[0].notes);
        print(cita);
        Navigator.push(
          context,
          MaterialPageRoute(
            //todo :   email del usuario
            builder: (context) => DetallesCitaScreen(
                emailUsuario: _emailSesionUsuario, reserva: cita),
          ),
        );
      },

      onDragEnd: (AppointmentDragEndDetails appointmentDragEndDetails) {
        if (_iniciadaSesionUsuario) {
          Map<String, dynamic> cita = json.decode(meetings.first.notes!);
          print(cita);

          final nuevaHora = appointmentDragEndDetails.droppingTime!;
          String textoDia =
              '${nuevaHora.year}-${nuevaHora.month.toString().padLeft(2, '0')}-${nuevaHora.day.toString().padLeft(2, '0')}';
          String textoFechaHoraInicio =
              ('$textoDia ${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}:00Z');
          String textoFechaHoraFinal =
              ('$textoDia ${(nuevaHora.hour + 3).toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}:00Z');

          String fecha =
              '${DateTime.parse(textoFechaHoraInicio).year.toString()}-${DateTime.parse(textoFechaHoraInicio).month.toString().padLeft(2, '0')}-${DateTime.parse(textoFechaHoraInicio).day.toString().padLeft(2, '0')}';
          print(textoFechaHoraInicio);

          CitaModelFirebase newCita = CitaModelFirebase();
          newCita.id = cita['id'];
          newCita.dia = fecha;
          newCita.horaInicio = textoFechaHoraInicio;
          newCita.horaFinal =
              textoFechaHoraFinal; // no la obtengo real. le sumo 3 horas
          newCita.comentario = cita['comentario'] + ' *cita reprogramada';
          newCita.idcliente = cita['idCliente'];
          newCita.idservicio = cita['idServicio'];
          newCita.idEmpleado = cita['idEmpleado'];

          debugPrint('$fecha  $textoFechaHoraInicio $textoFechaHoraFinal');

          FirebaseProvider().actualizarCita(_emailSesionUsuario, newCita);

          mensajeSuccess(context, 'Cita reprogramada');
        } else {
          setState(() {});
          mensajeError(context, 'No disponible para esta versión');
        }
      },
      view: CalendarView.day,
      initialDisplayDate: widget.fechaElegida,
      dataSource: MeetingDataSource(getAppointments()),
    ));
  }

  List<Appointment> getAppointments() {
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
