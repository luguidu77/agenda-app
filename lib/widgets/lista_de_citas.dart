import 'dart:convert';

import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/models.dart';
import '../providers/providers.dart';

import '../screens/detalles_cita_screen.dart';
import '../utils/utils.dart';

class ListaCitasNuevo extends StatefulWidget {
  const ListaCitasNuevo(
      {super.key, required this.fechaElegida, required this.citas});
  final DateTime fechaElegida;
  final List<Map<String, dynamic>> citas;
  @override
  _ListaCitasNuevoState createState() => _ListaCitasNuevoState();
}

class _ListaCitasNuevoState extends State<ListaCitasNuevo> {
  List<Appointment> meetings = <Appointment>[];
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;
  bool _leerEstadoBotonIndisponibilidad = false;
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
    final _leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;
    print(
        'este es el estado del boton de indisponibilidad $_leerEstadoBotonIndisponibilidad  <__________________________');
    int tiempoServicios = 1;

    return Scaffold(
        body: SfCalendar(
      backgroundColor: _leerEstadoBotonIndisponibilidad
          ? Colors.red.withOpacity(0.1)
          : Colors.white,

      // appointmentBuilder: appointmentBuilder,//? ########### CUSTOMIZACION DE LAS TARJETAS
      // ················   Config calendario ······································

      // CONFIGURA VISTA TIEMPO
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeFormat: 'HH:mm', // FORMATO 24H
        startHour: 7, // INICIO LABORAL
        endHour: 22, // FINAL LABORAL
        timeInterval: Duration(minutes: 15), //INTERVALOS DE TIEMPO
        timeIntervalHeight: 20, // tamaño de las casillas
      ),
      //cellBorderColor: Colors.deepOrange,

      viewNavigationMode: ViewNavigationMode.none,
      appointmentTextStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      headerHeight: 0, // oculta fecha
      allowDragAndDrop: true,
      onTap: (CalendarTapDetails details) {
        // DateTime date = details.date!;
        dynamic appointments = details.appointments;
        // CalendarElement view = details.targetElement;

        //###### SI AL HACER CLIC EN EL CALENDARIO, EXISTE UNA CITA NAVEGA A LOS DETALLES DE LA CITA, SI NO HAY CITA NAVEGA A CREACION DE UNA NUEVA CITA-----------
        if (appointments != null) {
          Map<String, dynamic> cita = json.decode(appointments[0].notes);

          // print(cita);
          //############# DETALLE DE LA CITA                   ########################

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesCitaScreen(
                  emailUsuario: _emailSesionUsuario, reserva: cita),
            ),
          );
        } else {
          // print(details.date);

          if (_leerEstadoBotonIndisponibilidad) {
            //############# CREACION DE CITA -- ELECCION DE CLIENTE ########################
            Navigator.pushNamed(context, 'creacionNoDisponibilidad',
                arguments: details.date);
          } else {
            //############# CREACION DE CITA -- ELECCION DE CLIENTE ########################
            Navigator.pushNamed(context, 'creacionCitaCliente',
                arguments: details.date);
          }
        }
      },

      // ****** reasiganacion de cita**********************************************
      onDragEnd: (AppointmentDragEndDetails appointmentDragEndDetails) async {
        // cita seleccionada
        dynamic appointment = appointmentDragEndDetails.appointment!;

        if (_iniciadaSesionUsuario) {
          // * LOS DATOS SE TRAJERON DE FIREBASE AL SELECCIONAR EL DIA :
          //*     lib\widgets\selecciona_dia.dart
          //*     lib\providers\Firebase\firebase_provider.dart

          // extraemos los datos de (notes) para obtener la cita
          Map<String, dynamic> cita = json.decode(appointment.notes);

          // OBTENER LA DIFERENCIA ENTRE LA HORA DE INICIO Y LA FINAL PARA CONOCER EL TIEMPO DE LA CITA
          List<int> tiempoServicios =
              calculaTiempo(cita['horaInicio'], cita['horaFinal']);

          final nuevaHora = appointmentDragEndDetails.droppingTime!;

          String textoDia =
              '${nuevaHora.year}-${nuevaHora.month.toString().padLeft(2, '0')}-${nuevaHora.day.toString().padLeft(2, '0')}';
          String textoFechaHoraInicio =
              ('$textoDia ${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}:00Z');
          // a la hora final le sumo el tiempoServicios
          String textoFechaHoraFinal =
              ('$textoDia ${(nuevaHora.hour + tiempoServicios[0]).toString().padLeft(2, '0')}:${(nuevaHora.minute + tiempoServicios[1]).toString().padLeft(2, '0')}:00Z');

          String fecha =
              '${DateTime.parse(textoFechaHoraInicio).year.toString()}-${DateTime.parse(textoFechaHoraInicio).month.toString().padLeft(2, '0')}-${DateTime.parse(textoFechaHoraInicio).day.toString().padLeft(2, '0')}';
          // print(textoFechaHoraInicio);

          debugPrint(cita.toString()); // print cita

          //? la funcion extraerServicios, resuelve el problema de que el json no tiene comillas en sus claves: [{idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semiperman
          List<String> idServicios =
              extraerIdServiciosdeCadenaTexto(cita['idServicio']);

          CitaModelFirebase newCita = CitaModelFirebase();

          newCita.email = cita['email'];
          newCita.id = cita['id'];
          newCita.dia = fecha;
          newCita.horaInicio = textoFechaHoraInicio;
          newCita.horaFinal = textoFechaHoraFinal;
          newCita.comentario = cita['comentario'] +
              ' 🔃​'; //todo añadir un nuevo campo REPROGRAMACION
          newCita.idcliente = cita['idCliente'];
          newCita.idservicio = idServicios;
          newCita.idEmpleado = cita['idEmpleado'];
          newCita.confirmada =
              cita['confirmada'] == 'true'; // Convertir cadena a booleano

          newCita.idCitaCliente = cita['idCitaCliente'];
          newCita.tokenWebCliente = cita['tokenWebCliente'];
          debugPrint('$fecha  $textoFechaHoraInicio $textoFechaHoraFinal');

          //* ACUTALIZA LAS BASE DE DATOS DE agandadecitaspp y clienteAgendoWeb
          await FirebaseProvider().actualizarCita(_emailSesionUsuario, newCita);
          await FirebaseProvider()
              .actualizaCitareasignada(_emailSesionUsuario, newCita);

          // ignore: use_build_context_synchronously
          mensajeSuccess(context,
              'Cita reprogramada para las ${nuevaHora.hour.toString().padLeft(2, '0')}:${nuevaHora.minute.toString().padLeft(2, '0')}');

          Navigator.pushNamed(context, '/');
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
          fechaInicio.day, fechaInicio.hour, fechaInicio.minute, 0);
      final DateTime endTime = DateTime(fechaFinal.year, fechaFinal.month,
          fechaFinal.day, fechaFinal.hour, fechaFinal.minute, 0);
      bool citaConfirmada = _iniciadaSesionUsuario
          ? cita['confirmada'].toString() == 'true'
              ? true
              : false
          : true;

      //SERVICIOS DEPENDENRA DE SI ES CON SESION O EN DISPOSITIVO
      var servicios = _iniciadaSesionUsuario
          ? cita['idServicio'].map((serv) => serv['servicio']).join(', ')
          : cita['servicio'];

      // **** DONDE CREAMOS LA NOTA QUE TRAE TODOS LOS DATOS NECESARIOS PARA LA GESTION DE CITA ****************
      //

      meetings.add(Appointment(
          // TRAEMOS TODOS LOS DATOS QUE NOS HARA FALTA PARA TRABAJAR CON ELLOS POSTERIORMENTE en Detalles de la cita
          notes: '''
{
  "id": "${cita['id']}",
  "idCliente": "${cita['idCliente']}",
  "idEmpleado": "${cita['idEmpleado']}",
  "idServicio": "${cita['idServicio']}",
  "nombre": "${cita['nombre']}",
  "nota": "${cita['nota']}",
  "horaInicio": "${cita['horaInicio']}",
  "horaFinal": "${cita['horaFinal']}",
  "telefono": "${cita['telefono']}",
  "email": "${cita['email']}",
  "servicio": "$servicios",
  "detalle": "${cita['detalle'].toString()}",
  "precio": "${cita['precio']}",
  "foto": "${cita['foto']}",
  "comentario": "${cita['comentario']}",
  "confirmada": "${cita['confirmada'].toString()}",
  "idCitaCliente": "${cita['idCitaCliente'].toString()}",
  "tokenWebCliente": "${cita['tokenWebCliente'].toString()}"
}
''',
          id: cita['id'],
          startTime: startTime,
          endTime: endTime,
          // DATOS QUE SE VISUALIZAN EN EL CALENDARIO DE LA CITA
          subject: textoCita(cita),

          //location: 'es-ES',
          color: cita['idServicio'] == 999 ||
                  cita['idServicio'] ==
                      null //todo: comprueba solo el primer servicio de la lista
              ? const Color.fromARGB(255, 113, 151, 102)
              : !citaConfirmada
                  ? const Color.fromARGB(255, 133, 130, 130)
                  : fechaFinal.isBefore(DateTime.now())
                      ? const Color.fromARGB(255, 247, 125, 116)
                      : const Color.fromARGB(255, 100, 127, 172)));
    }
    debugPrint(meetings.toString());
    return meetings;
  }

  List<int> calculaTiempo(timestamp1, timestamp2) {
    DateTime dateTime1 = DateTime.parse(timestamp1);
    DateTime dateTime2 = DateTime.parse(timestamp2);
    Duration difference = dateTime2.difference(dateTime1);

    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;
    return [hours, minutes];
  }

  String textoCita(cita) {
    bool citaConfirmada = _iniciadaSesionUsuario
        ? cita['confirmada'].toString() == 'true'
            ? true
            : false
        : true;

    print('$citaConfirmada ---- $_iniciadaSesionUsuario');
    String textoConfirmada =
        citaConfirmada ? 'CONFIRMADA' : 'PENDIENTE CONFIRMAR';
    var servicios = _iniciadaSesionUsuario
        ? cita['idServicio'].map((serv) => serv['servicio']).join(', ')
        : cita['servicio'];
    return (cita['nombre'] != null)
        ? '${textoConfirmada.padLeft(60)}'
            '\n😀 ${cita['nombre']}'
            '\n 🤝 $servicios' //.join(', ') => para que no quitar los ()
            '\n 📇 ${cita['comentario']}'
            '\n 💰 ${cita['precio']}'
        : '🌴⛵🍍🦀 NO DISPONIBLE \n\n MOTIVO: ${cita['comentario']}';
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}

//############ CUSTOMIZACION DE LA TARJETA DE CITAS ##################################################
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  return Column(
    children: [
      Container(
          width: calendarAppointmentDetails.bounds.width,
          height: calendarAppointmentDetails.bounds.height / 2,
          color: appointment.color,
          child: const Center(
            child: Icon(
              Icons.group,
              color: Colors.black,
            ),
          )),
      Container(
        width: calendarAppointmentDetails.bounds.width,
        height: calendarAppointmentDetails.bounds.height / 2,
        color: appointment.color,
        child: Text(
          '${appointment.subject}${DateFormat(' (hh:mm a').format(appointment.startTime)}-${DateFormat('hh:mm a)').format(appointment.endTime)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      )
    ],
  );
}
