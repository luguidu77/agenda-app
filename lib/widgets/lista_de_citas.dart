import 'dart:convert';
import 'dart:math';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_no_disponibilidad/tarjeta_indisponibilidad.dart';
import 'package:agendacitas/screens/detalles_horario_no_disponible_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../models/models.dart';
import '../providers/providers.dart';

import '../screens/detalles_cita_screen.dart';
import '../utils/utils.dart';

class ListaCitasNuevo extends StatefulWidget {
  const ListaCitasNuevo({super.key, required this.citasFiltradas});

  final List<CitaModelFirebase> citasFiltradas;
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
  final List<TimeRegion> _specialTimeRegions = [];

  List<CitaModelFirebase> _citasFiltradas = [];

  @override
  void initState() {
    emailUsuarioApp();

    _employeeCollection = <CalendarResource>[];
    //_addResources();
    //_addSpecialRegions(); // agrega zonas de descansos ejemplo HORA DE COMER
    _calendarController = CalendarController();
    super.initState();
  }

  void _addResources() {
    final empleadosProvider = context.watch<EmpleadosProvider>();

    List<EmpleadoModel> empleados = empleadosProvider.getEmpleados;

    for (var i = 0; i < empleados.length; i++) {
      print(empleados[i].nombre);

      _employeeCollection.add(CalendarResource(
        image: NetworkImage(empleados[i].foto),
        displayName: empleados[i].nombre,
        id: empleados[i].id,
        color: Color(empleados[i].color),
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
        endTime: startDate.add(const Duration(hours: 3)),
        text: 'Not Available',
        enablePointerInteraction: false,
        resourceIds: <Object>[_employeeCollection[i].id],
      ));
    }
  }

  late CalendarController _calendarController;

  @override
  Widget build(BuildContext context) {
    // _citasFiltradas = widget.citasFiltradas;
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();
    final calendarioProvider = context.watch<CalendarioProvider>();

    _addResources();

    var vistaProvider = Provider.of<VistaProvider>(context, listen: true);

    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;
    print(
        'este es el estado del boton de indisponibilidad $leerEstadoBotonIndisponibilidad  <__________________________');
    int tiempoServicios = 1;
    _calendarController.selectedDate = calendarioProvider.fechaSeleccionada;
    _calendarController.displayDate = calendarioProvider.fechaSeleccionada;

    return Scaffold(
        body: SfCalendar(
      controller: _calendarController,

      backgroundColor: leerEstadoBotonIndisponibilidad
          ? Colors.red.withOpacity(0.1)
          : Colors.white,

      /*   view: vistaProvider
          .vista, */ //············· CAMBIA LA VISTA: VISUALIZA EMPLEADOS :timelineDay ------------------------------------------------

      specialRegions:
          _specialTimeRegions, // tramos especiales como descansos entre turnos (comidas, descansos..)
      /*   allowedViews: const [
        CalendarView.day,
        CalendarView.timelineDay,
      ], */

      resourceViewSettings: ResourceViewSettings(
          showAvatar: true,
          visibleResourceCount: _employeeCollection.length,
          size: 55,
          displayNameTextStyle: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 9,
              fontWeight: FontWeight.w400)),
      resourceViewHeaderBuilder:
          (BuildContext context, ResourceViewHeaderDetails details) {
        return Container(
            color: Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (details.resource.image),
                ),
                Text(
                  details.resource.displayName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ));
      },
      // DETECTO LA FECHA ELEGIDA AL DESPLAZAR LAS PAGINAS DEL CALENDARIO
      onViewChanged: (ViewChangedDetails details) {
        // DateTime fechaVisibleInicio = details.visibleDates.first;
        DateTime fechaVisibleFin = details.visibleDates.last;

        // Llama a la función externa que decide si actualizar o no
        Future.delayed(Duration.zero, () {
          actualizarFechaSeleccionada(fechaVisibleFin, calendarioProvider);
        });

        //  print("Fecha visible de inicio: $fechaVisibleInicio");
        print("Fecha visible de fin: ${fechaVisibleFin.toString()}");
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

            // verifica que se ha seleccionado a un empleado antes de iniciar la creacion de cita
            if (contextoCreacionCita.contextoCita.idEmpleado !=
                'TODOS_EMPLEADOS') {
              Navigator.pushNamed(context, 'creacionCitaCliente',
                  arguments: details.date);
            } else {
              mensajeError(context, 'Selecciona un empleado');
            }
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

          _dialogoEsperayActualizarCita(
                  context, cita, appointmentDragEndDetails, _emailSesionUsuario)
              .whenComplete(() {
            // Navigator.pushReplacementNamed(context, '/');
          });
        } else {
          setState(() {});
          mensajeError(context, 'No disponible para esta versión');
        }
      },

      initialDisplayDate: DateTime.now(),
      dataSource: MeetingDataSource(getAppointments(), _employeeCollection),
    ));
  }

  List<Appointment> getAppointments() {
    // **** DONDE CREAMOS LA NOTA QUE TRAE TODOS LOS DATOS NECESARIOS PARA LA GESTION DE CITA ****************
    meetings = widget.citasFiltradas.map((cita) {
      final List<String> employeeIds = [];

      for (var i = 0; i < _employeeCollection.length; i++) {
        if (cita.idEmpleado == _employeeCollection[i].id) {
          employeeIds.add(_employeeCollection[i].id.toString());
        }
      }

      /*  servicios = cita.servicios!.map((serv) => serv).join(', ');
      

        print(servicios); */
      servicios = cita.servicios.toString().replaceAll(RegExp(r'[\[\]]'), '');

      /* cita.idcliente == '999' // no es un cita, es un indispuesto
                ? const Color.fromARGB(255, 113, 151, 102)
                : !citaConfirmada
                    // si la cita esta confirmada, obtiene el color asignado al empleado
                    ? Color(cita.colorEmpleado!)
                    : fechaFinal.isBefore(DateTime.now())
                        // si la cita es pasada
                        ? Color.lerp(
                            Color(cita.colorEmpleado!), Colors.white, 0.7)!
                        // si la cita es futura
                        : Color(cita.colorEmpleado!))); */
      int colorEmpleado = cita.colorEmpleado ?? 0xFF000000;

      return Appointment(
          // TRAEMOS TODOS LOS DATOS QUE NOS HARA FALTA PARA TRABAJAR CON ELLOS POSTERIORMENTE en Detalles de la cita
          notes: '''
                     {
                         "id": "${cita.id}",
                         "idCliente": "${cita.idcliente}",
                         "idEmpleado": "${cita.idEmpleado}",
                         "nombreEmpleado" :  "${cita.nombreEmpleado}",
                         "colorEmpleado":"${cita.colorEmpleado}",
                         "idServicio": "${cita.idservicio}",  
                         "servicios":  "$servicios",                   
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
          startTime: cita.horaInicio!,
          endTime: cita.horaFinal!,
          // DATOS QUE SE VISUALIZAN EN EL CALENDARIO DE LA CITA
          subject: textoCita(cita),

          //location: 'es-ES',
          color: Color(colorEmpleado));
      // Aquí construyes cada Appointment
    }).toList();

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

void actualizarFechaSeleccionada(
    DateTime nuevaFecha, CalendarioProvider calendarioProvider) {
  if (calendarioProvider.fechaSeleccionada != nuevaFecha) {
    calendarioProvider.setFechaSeleccionada(nuevaFecha);
  }
}

Future<void> _dialogoEsperayActualizarCita(
    context, cita, appointmentDragEndDetails, emailSesionUsuario) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // No permite cerrar el diálogo al tocar fuera.
    builder: (BuildContext context) {
      // Llama a la función actualizar la cita y cierra el dialogo.
      _actualizaciondelacita(
              context, cita, appointmentDragEndDetails, emailSesionUsuario)
          .whenComplete(() {
        // Una vez completada la tarea, cierra el diálogo.
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/');
      });

      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Actualizando, por favor espera...'),
          ],
        ),
      );
    },
  );
}

Future<void> _actualizaciondelacita(BuildContext context, cita,
    appointmentDragEndDetails, emailSesionUsuario) async {
  ////XXxxxx FUNCION actualizar la cita en Firebase  xxxxxXX
  await ActualizacionCita.actualizar(context, cita,
      appointmentDragEndDetails.droppingTime!, null, null, emailSesionUsuario);
}
