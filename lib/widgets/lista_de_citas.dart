import 'dart:convert';
import 'dart:math';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/screens/creacion_no_disponibilidad/tarjeta_indisponibilidad.dart';
import 'package:agendacitas/screens/detalles_horario_no_disponible_screen.dart';
import 'package:agendacitas/utils/extraerServicios.dart';
import 'package:agendacitas/widgets/empleado/empleado.dart';
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
  final List<CitaModelFirebase> citas;
  @override
  _ListaCitasNuevoState createState() => _ListaCitasNuevoState();
}

class _ListaCitasNuevoState extends State<ListaCitasNuevo> {
  var servicios;
  List<Appointment> meetings = <Appointment>[];
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;
  final bool _leerEstadoBotonIndisponibilidad = false;
  emailUsuarioApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  List<CalendarResource> _employeeCollection = [];
  List<TimeRegion> _specialTimeRegions = [];

  @override
  void initState() {
    emailUsuarioApp();

    _employeeCollection = <CalendarResource>[];
    _addResources();
    //_addSpecialRegions(); // agrega zonas de descansos ejemplo HORA DE COMER

    super.initState();
  }

  void _addResources() {
    final empleadosProvider =
        Provider.of<EmpleadosProvider>(context, listen: false);
    List<EmpleadoModel> empleados = empleadosProvider.getEmpleados;

    for (var i = 0; i < empleados.length; i++) {
      print(empleados[i].nombre);

      _employeeCollection.add(CalendarResource(
        displayName: empleados[i].nombre,
        id: empleados[i].id,
        color: Colors.white,
      ));
    }
  }

  // agrega horas de descansos
  void _addSpecialRegions() {
    final DateTime date = DateTime.now();
    Random random = Random();
    for (int i = 0; i < _employeeCollection.length; i++) {
      _specialTimeRegions.add(TimeRegion(
          startTime: DateTime(date.year, date.month, date.day, 13, 0, 0),
          endTime: DateTime(date.year, date.month, date.day, 14, 0, 0),
          text: 'Lunch',
          resourceIds: <Object>[_employeeCollection[i].id],
          recurrenceRule: 'FREQ=DAILY;INTERVAL=1'));

      if (i % 2 == 0) {
        continue;
      }

      final DateTime startDate = DateTime(DateTime.now().year,
          DateTime.now().month, DateTime.now().day, 7, 0, 0);

      _specialTimeRegions.add(TimeRegion(
        startTime: startDate,
        endTime: startDate.add(Duration(hours: 3)),
        text: 'Not Available',
        enablePointerInteraction: false,
        resourceIds: <Object>[_employeeCollection[i].id],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;
    print(
        'este es el estado del boton de indisponibilidad $leerEstadoBotonIndisponibilidad  <__________________________');
    int tiempoServicios = 1;

    return Scaffold(
        body: SfCalendar(
      backgroundColor: leerEstadoBotonIndisponibilidad
          ? Colors.red.withOpacity(0.1)
          : Colors.white,

      view: CalendarView
          .day, //············· CAMBIA LA VISTA: VISUALIZA EMPLEADOS :timelineDay ------------------------------------------------

      specialRegions:
          _specialTimeRegions, // tramos especiales como descansos entre turnos (comidas, descansos..)
      allowedViews: const [
        CalendarView.day,
        CalendarView.timelineDay,
      ],

      resourceViewSettings: ResourceViewSettings(
          showAvatar: false,
          visibleResourceCount: _employeeCollection.length,
          size: 55,
          displayNameTextStyle: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 9,
              fontWeight: FontWeight.w400)),
      resourceViewHeaderBuilder:
          (BuildContext context, ResourceViewHeaderDetails details) {
        return Container(
          color: Color.fromARGB(71, 6, 79, 236),
          child: Text(details.resource.displayName),
        );
      },
      // DETECTO LA FECHA ELEGIDA AL DESPLAZAR LAS PAGINAS DEL CALENDARIO
      onViewChanged: (ViewChangedDetails details) {
        // DateTime fechaVisibleInicio = details.visibleDates.first;
        DateTime fechaVisibleFin = details.visibleDates.last;
        var calendarioProvider =
            Provider.of<CalendarioProvider>(context, listen: false);
        calendarioProvider.setFechaSeleccionada(fechaVisibleFin);

        //  print("Fecha visible de inicio: $fechaVisibleInicio");
        print("Fecha visible de fin: $fechaVisibleFin");
      },

      // appointmentBuilder: appointmentBuilder,//? ########### CUSTOMIZACION DE LAS TARJETAS
      // ················   Config calendario ······································

      // CONFIGURA HORARIO
      timeSlotViewSettings: const TimeSlotViewSettings(
        timeFormat: 'HH:mm', // FORMATO 24H
        startHour: 7, // INICIO LABORAL
        endHour: 22, // FINAL LABORAL
        timeInterval: Duration(minutes: 15), //INTERVALOS DE TIEMPO
        timeIntervalHeight: 20, // tamaño de las casillas
      ),
      //cellBorderColor: Colors.deepOrange,

      viewNavigationMode: ViewNavigationMode
          .snap, // permite pasar fechas arrastrando a los lados

      appointmentTextStyle: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      headerHeight: 0, // oculta fecha
      allowDragAndDrop: true,
      onLongPress: (calendarLongPressDetails) => print('fdfdf'),

      onTap: (CalendarTapDetails details) async {
        print('object');
        // DateTime date = details.date!;
        dynamic appointments = details.appointments;
        // CalendarElement view = details.targetElement;

        //###### SI AL HACER CLIC EN EL CALENDARIO, EXISTE UNA CITA NAVEGA A LOS DETALLES DE LA CITA, SI NO HAY CITA NAVEGA A CREACION DE UNA NUEVA CITA-----------
        if (appointments != null) {
          Map<String, dynamic> cita = json.decode(appointments[0].notes);
          print(cita);
          if (cita['nombre'] != '') {
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
            //############# DETALLE HORARIO NO DISPONIBLE      ########################
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesHorarioNoDisponibleScreen(
                    emailUsuario: _emailSesionUsuario, reserva: cita),
              ),
            );
          }
        } else {
          //############# CREACION DE HORARIO NO DISPONIBLE --  ########################
          if (leerEstadoBotonIndisponibilidad) {
            Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TarjetaIndisponibilidad(argument: details.date),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(
                        1.0, 0.0); // Inicia fuera de la pantalla a la derecha
                    const end = Offset.zero; // Termina en la posición normal
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ));

            /*  Navigator.pushNamed(context, 'creacionNoDisponibilidad',
                arguments: details.date); */
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

          ////XXxxxx FUNCION actualizar la cita en Firebase  xxxxxXX
          ActualizacionCita.actualizar(
              context,
              cita,
              appointmentDragEndDetails.droppingTime!,
              null,
              null,
              _emailSesionUsuario);

          Navigator.pushNamed(context, '/');
        } else {
          setState(() {});
          mensajeError(context, 'No disponible para esta versión');
        }
      },

      initialDisplayDate: widget.fechaElegida,
      dataSource: MeetingDataSource(getAppointments(), _employeeCollection),
    ));
  }

  List<Appointment> getAppointments() {
    for (var cita in widget.citas) {
      print('oooooooooooooooooooooo veo las citas oooooooooooooooooooooooooo');
      print(cita.nombreCliente);
      String horaInicio =
          FormatearFechaHora().formatearHora(cita.horaInicio.toString());
      String horaFinal =
          FormatearFechaHora().formatearHora(cita.horaFinal.toString());
      print('@@@@@@@@@@@@@@@@@@@@@@');
      print(cita.id);

      final DateTime fechaInicio = DateTime.parse(cita.horaInicio!);
      final DateTime fechaFinal = DateTime.parse(cita.horaFinal!);
      final DateTime startTime = DateTime(fechaInicio.year, fechaInicio.month,
          fechaInicio.day, fechaInicio.hour, fechaInicio.minute, 0);
      final DateTime endTime = DateTime(fechaFinal.year, fechaFinal.month,
          fechaFinal.day, fechaFinal.hour, fechaFinal.minute, 0);
      bool citaConfirmada = _iniciadaSesionUsuario
          ? cita.confirmada.toString() == 'true'
              ? true
              : false
          : true;

      //SERVICIOS DEPENDENRA DE SI ES CON SESION O EN DISPOSITIVO

      if (_iniciadaSesionUsuario) {
        final List<String> employeeIds = [];
        for (var i = 0; i < _employeeCollection.length; i++) {
          if (cita.idEmpleado == _employeeCollection[i].id) {
            employeeIds.add(_employeeCollection[i].id.toString());
          }
        }

        servicios = cita.servicios!.map((serv) => serv).join(', ');

        print(servicios);

        // **** DONDE CREAMOS LA NOTA QUE TRAE TODOS LOS DATOS NECESARIOS PARA LA GESTION DE CITA ****************
        meetings.add(Appointment(
            // TRAEMOS TODOS LOS DATOS QUE NOS HARA FALTA PARA TRABAJAR CON ELLOS POSTERIORMENTE en Detalles de la cita
            notes: '''
                     {
                         "id": "${cita.id}",
                         "idCliente": "${cita.idcliente}",
                         "idEmpleado": "${cita.idEmpleado}",
                         "nombreEmpleado" :  "${cita.nombreEmpleado}",
                         "idServicio": "${cita.idservicio}",  
                         "servicios":  "${cita.servicios}",                   
                         "nombre": "${cita.nombreCliente}",
                         "nota": "${cita.notaCliente}",
                         "horaInicio": "${cita.horaInicio}",
                         "horaFinal": "${cita.horaFinal}",
                         "telefono": "${cita.telefonoCliente}",
                         "email": "${cita.emailCliente}",               
                         "detalle": "${cita.comentario.toString()}",
                         "precio": "${cita.precio}",
                         "foto": "${cita.fotoCliente}",
                         "comentario": "${cita.comentario}",
                         "confirmada": "${cita.confirmada.toString()}",
                         "idCitaCliente": "${cita.idCitaCliente.toString()}",
                         "tokenWebCliente": "${cita.tokenWebCliente.toString()}"
                    }
                    ''',
            resourceIds: employeeIds,
            id: cita.id,
            startTime: startTime,
            endTime: endTime,
            // DATOS QUE SE VISUALIZAN EN EL CALENDARIO DE LA CITA
            subject: textoCita(cita),

            //location: 'es-ES',
            color: cita.idcliente == '999'
                ? const Color.fromARGB(255, 113, 151, 102)
                : !citaConfirmada
                    ? const Color.fromARGB(255, 133, 130, 130)
                    : fechaFinal.isBefore(DateTime.now())
                        ? const Color.fromARGB(255, 247, 125, 116)
                        : const Color.fromARGB(255, 100, 127, 172)));
      }
    }

    debugPrint(meetings.toString());
    return meetings;
  }

  String textoCita(CitaModelFirebase cita) {
    bool citaConfirmada = _iniciadaSesionUsuario
        ? cita.confirmada.toString() == 'true'
            ? true
            : false
        : true;

    // print('$citaConfirmada ---- $_iniciadaSesionUsuario');

    String textoConfirmada =
        citaConfirmada ? '✔️ cofirmada' : '❌ sin confirmar';

    // ###### COMPROBACION SI SE TRATA DE UNA CITA O UNA HORA INDISPONIBLE
    return (cita.nombreCliente != '')

        // ------------TARJETA CITA RESERVADA         ---------------------
        ? '$textoConfirmada con ${cita.nombreEmpleado}'
            '\n 🧒 ${cita.nombreCliente}'
            '\n 🤝 $servicios' //.join(', ') => para que no quitar los ()
            '\n 🗨️ ${cita.comentario}'
            '\n 💰 ${cita.precio}'

        // ------------TARJETA HORARIO NO DISPONIBLE ---------------------
        : ' ${cita.comentario}';
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(
      List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
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
