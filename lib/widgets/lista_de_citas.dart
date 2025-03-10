import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/emailHtml/emails_html.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_no_disponibilidad/tarjeta_indisponibilidad.dart';
import 'package:agendacitas/screens/detalles_horario_no_disponible_screen.dart';
import 'package:agendacitas/widgets/guardarCitaModificada/GuardarCitaModificada.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart';

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
  // Variable para almacenar el controlador del mensaje persistente gardar cambios
  PersistentBottomSheetController? _bottomSheetController;

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
    _addSpecialRegions(); // agrega zonas de descansos ejemplo HORA DE COMER
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
    List<String> textoALista(String texto) {
      // Dividir el texto por comas y eliminar espacios adicionales
      List<String> lista = texto.split(',').map((e) => e.trim()).toList();
      return lista;
    }

    // _citasFiltradas = widget.citasFiltradas;
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();
    final calendarioProvider = context.watch<CalendarioProvider>();
    final citaconfirmada = context.watch<EstadoConfirmacionCita>();
    final horaInicioCita = contextoCreacionCita.horaVariante;

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
      headerHeight: 0, // oculta fecha
      viewHeaderHeight: 0, // quita el marco superior donde iria la fecha
      showCurrentTimeIndicator: true,

      controller: _calendarController,
      //color fondo del calendario
      backgroundColor: leerEstadoBotonIndisponibilidad
          ? Colors.red.withOpacity(0.1)
          : Colors.white,

      /*   view: vistaProvider
          .vista, */ //············· CAMBIA LA VISTA: VISUALIZA EMPLEADOS :timelineDay ------------------------------------------------

      specialRegions: [
        TimeRegion(
            startTime: DateTime(2025, 1, 1, 6, 0, 0),
            endTime: DateTime(2025, 1, 1, 7, 0, 0),
            text: '',
            recurrenceRule: 'FREQ=DAILY;INTERVAL=1')
      ], // tramos especiales como descansos entre turnos (comidas, descansos..)
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
        dayFormat: '',
        dateFormat: 'd',
        timeFormat: 'HH:mm', // FORMATO 24H
        startHour: 6, // INICIO LABORAL
        endHour: 22, // FINAL LABORAL
        timeInterval: Duration(minutes: 15), //INTERVALOS DE TIEMPO
        timeIntervalHeight: 30, // tamaño de las casillas
      ),

      //cellBorderColor: Colors.deepOrange,

      viewNavigationMode: ViewNavigationMode
          .snap, // permite pasar fechas arrastrando a los lados

      appointmentTextStyle: const TextStyle(
          color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),

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

          List<String> listaServicios = textoALista(cita['servicios']);

          // el idServicio es un string que contiene una lista de ids de servicios, lo convertimos en una lista de strings
          String idServicio = cita['idServicio'];
          List<String> idServicioLista = idServicio
              .substring(1, idServicio.length - 1)
              .split(',')
              .map((item) =>
                  item.trim()) // Elimina espacios en blanco con trim()
              .toList();
          print(cita);
          if (cita['idCliente'] != '999') {
            // print(cita);
            //############# DETALLE DE LA CITA                   ########################
            final citaElegida = CitaModelFirebase(
                id: cita['id'],
                dia: cita['dia'],
                horaInicio: DateTime.parse(cita['horaInicio']),
                horaFinal: DateTime.parse(cita['horaFinal']),
                comentario: cita['comentario'],
                email: cita['email'],
                idcliente: cita['idCliente'],
                idservicio:
                    idServicioLista, // Divide los elementos si hay comas
                servicios: listaServicios,
                idEmpleado: cita['idEmpleado'],
                nombreEmpleado: cita['nombreEmpleado'],
                colorEmpleado: int.parse(cita['colorEmpleado']),
                precio: cita['precio'],
                confirmada: cita['confirmada'] == 'true' ? true : false,
                tokenWebCliente: cita['tokenWebCliente'],
                idCitaCliente: cita['idCitaCliente'],
                nombreCliente: cita['nombre'],
                // fotoCliente: cita['foto'],
                telefonoCliente: cita['telefono'],
                emailCliente: cita['email'],
                notaCliente: cita['nota']);

            String dia = formatearFechaDiaCita(citaElegida.horaInicio!);
            // Puedes incluir una verificación para que solo se ejecute una vez si es necesario.

            // Puedes incluir una verificación para que solo se ejecute una vez si es necesario.
            final citaContexto = context.read<CreacionCitaProvider>();
            citaContexto.contextoCita.dia = dia;
            citaContexto.setContextoCita(citaElegida);
            // Reemplaza el showModalBottomSheet con esto:
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    DetallesCitaWidget(
                  reserva: citaElegida,
                  fechaCorta: 'anular',
                  citaconfirmada: citaconfirmada.estadoCita,
                  // personaliza: personaliza,
                  emailUsuario: _emailSesionUsuario,
                  iniciadaSesionUsuario: _iniciadaSesionUsuario,
                ),
                /*   DetallesCitaScreen(
                  emailUsuario: _emailSesionUsuario,
                  reserva: citaElegida,
                ), */
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Comienza desde la derecha
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
                fullscreenDialog:
                    true, // Para comportamiento de diálogo completo
              ),
            );
          } else {
            final citaElegida = CitaModelFirebase(
                id: cita['id'],
                dia: cita['dia'],
                horaInicio: DateTime.parse(cita['horaInicio']),
                horaFinal: DateTime.parse(cita['horaFinal']),
                comentario: cita['comentario'],
                email: cita['email'],
                idcliente: cita['idCliente'],
                idservicio:
                    idServicioLista, // Divide los elementos si hay comas
                servicios: listaServicios,
                idEmpleado: cita['idEmpleado'],
                nombreEmpleado: cita['nombreEmpleado'],
                colorEmpleado: int.parse(cita['colorEmpleado']),
                precio: cita['precio'],
                confirmada: cita['confirmada'] == 'true' ? true : false,
                tokenWebCliente: cita['tokenWebCliente'],
                idCitaCliente: cita['idCitaCliente'],
                nombreCliente: cita['nombre'],
                // fotoCliente: cita['foto'],
                telefonoCliente: cita['telefono'],
                emailCliente: cita['email'],
                notaCliente: cita['nota']);
            //############# DETALLE HORARIO NO DISPONIBLE      ########################
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesHorarioNoDisponibleScreen(
                    emailUsuario: _emailSesionUsuario, reserva: citaElegida),
              ),
            );
          }
        } else {
          //############# CREACION DE CITA / CREACION HORARIO NO DISPONIBLE ########################
          //########################################################################################

          // verifica que se ha seleccionado a un empleado antes de iniciar la creacion de cita o indisponibilidad
          if (contextoCreacionCita.contextoCita.idEmpleado !=
              'TODOS_EMPLEADOS') {
            //############# CREACION DE HORARIO NO DISPONIBLE --  ########################
            if (leerEstadoBotonIndisponibilidad) // si el boton de indisponibilidad esta activado

            {
              // Paso al provider fecha elegida Fecha y hora para usarlas en la vista TarjetaIndisponibilidad
              _seteaProviderFechaElegida(context, details);

              // navega a la vista TarjetaIndisponibilidad
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
            } else // si el boton de indisponibilidad no esta activado

            {
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
          } else {
            // si no se ha seleccionado un empleado, muestra un mensaje de error
            mensajeError(context, 'Selecciona un empleado');
          }
        }
      },
      onDragStart: (AppointmentDragStartDetails appointmentDragStartDetails) {
        // Muestra el mensaje de arrastre
      },
      onDragUpdate:
          (AppointmentDragUpdateDetails appointmentDragUpdateDetails) async {
        print(appointmentDragUpdateDetails.draggingTime);
        //? desabilitada porque no se visualiza el mensaje de guardado tengo problemas con el contexto
        /*   GuardarCitaModificada(
          funcion: () {
            // Acción al guardar cambios
            _bottomSheetController?.close();
            _bottomSheetController = null;
          },
        ); */
      },
      // ****** reasiganacion de cita**********************************************
      onDragEnd: (AppointmentDragEndDetails appointmentDragEndDetails) async {
        // cita seleccionada
        dynamic appointment = appointmentDragEndDetails.appointment!;

        // * LOS DATOS SE TRAJERON DE FIREBASE AL SELECCIONAR EL DIA :
        //*     lib\widgets\selecciona_dia.dart
        //*     lib\providers\Firebase\firebase_provider.dart

        // extraemos los datos de (notes) para obtener la cita
        Map<String, dynamic> cita = json.decode(appointment.notes);
        print(appointmentDragEndDetails.droppingTime);
        _mostrarMensajeDrag(
            context,
            () => dialogoEsperayActualizarCita(context, cita,
                        appointmentDragEndDetails, _emailSesionUsuario)
                    .whenComplete(() {
                  // Navigator.pushReplacementNamed(context, '/');
                }));
      },

      initialDisplayDate: DateTime.now(),
      dataSource: MeetingDataSource(
        getAppointments(
          horaInicioCita,
        ),
        _employeeCollection,
      ),
    ));
  }

  void _seteaProviderFechaElegida(
      BuildContext context, CalendarTapDetails details) {
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
    providerFechaElegida.setFechaElegida(details.date!);
    final providerHoraFinCarrusel = context.read<HorarioElegidoCarrusel>();
    // hora inicio
    providerHoraFinCarrusel.setHoraInicio(details.date!);
    // hora fin
    providerHoraFinCarrusel.setHoraFin(details.date!);
    print(
        ' setea la fecha elegida en 340-lista_de_citas.dart--------------------');
  }

  List<Appointment> getAppointments(horaInicioCita) {
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

      /* 
      // color segun el estado de la cita
      cita.idcliente == '999' // no es un cita, es un indispuesto
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

      // Color del empleado
      int colorEmpleado = cita.colorEmpleado ?? 0xFF000000;
      // si la cita es un horario no disponible color gris
      if (cita.idcliente == '999') {
        colorEmpleado = 0xFFD3D3D3;
      }

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
    bool confirmada = cita.confirmada.toString() == 'true' ? true : false;

    // print('$citaConfirmada ---- $_iniciadaSesionUsuario');

    String textoConfirmada = confirmada ? '✔️' : '❌';
    String hayComentario = cita.comentario!.isNotEmpty ? '🗨️' : '';
    String horaInicioTexto = formatearHora(cita.horaInicio.toString());

    String horaFinTexto = formatearHora(cita.horaFinal.toString());

    // ###### COMPROBACION SI SE TRATA DE UNA CITA O UNA HORA INDISPONIBLE
    return (cita.nombreCliente != '')

        // ------------TARJETA CITA RESERVADA         ---------------------
        ? ' $horaInicioTexto-$horaFinTexto · $textoConfirmada '
            '\n ${cita.nombreCliente} $hayComentario'

        // ------------TARJETA HORARIO NO DISPONIBLE ---------------------
        : ' ${cita.comentario}';
  }

  // Función para mostrar el bottom sheet persistente al iniciar el arrastre
  void _mostrarMensajeDrag(BuildContext context, Function funcion) {
    // Evitar mostrar múltiples bottom sheets
    if (_bottomSheetController != null) return;

    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          // Asegúrate de asignar un color de fondo para que se distinga
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Desea guardar los cambios?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.redAccent),
                    ),
                    onPressed: () {
                      // Acción al cancelar
                      setState(() {});
                      _bottomSheetController?.close();
                      _bottomSheetController = null;
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Acción al guardar cambios
                      _bottomSheetController?.close();
                      _bottomSheetController = null;
                      funcion();
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        );
      },
    );
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

Future<void> dialogoEsperayActualizarCita(context, Map<String, dynamic> cita,
    appointmentDragEndDetails, emailSesionUsuario) async {
  // Llama a la función actualizar la cita y cierra el dialogo.
  _actualizaciondelacita(
          context, cita, appointmentDragEndDetails, emailSesionUsuario)
      .whenComplete(() {
    // Una vez completada la tarea, cierra el diálogo.
    // Navigator.pop(context);
    // Navigator.pushReplacementNamed(context, '/');
  });
}

Future<void> _actualizaciondelacita(
    BuildContext context,
    Map<String, dynamic> cita,
    appointmentDragEndDetails,
    emailSesionUsuario) async {
  CitaModelFirebase nuevaCita = CitaModelFirebase();

  print(cita['idServicio']);
  print(cita['servicios']);
  String idServicio = cita['idServicio'];
  List<String> idservicios = idServicio
      .substring(1, idServicio.length - 1) // Elimina los corchetes
      .split(
          ', '); // Divide los elementos si hay comas y los convierte en una lista

  nuevaCita = CitaModelFirebase(
    id: cita['id'],
    dia: cita['dia'],
    horaInicio: DateTime.parse(cita['horaInicio']),
    horaFinal: DateTime.parse(cita['horaFinal']),
    comentario: cita['comentario'],
    email: cita['email'],
    idcliente: cita['idCliente'],
    idservicio: idservicios,
    servicios: cita['servicios'].split(', '),
    idEmpleado: cita['idEmpleado'],
    nombreEmpleado: cita['nombreEmpleado'],
    colorEmpleado: int.parse(cita['colorEmpleado']),
    precio: cita['precio'],
    confirmada: true,
    tokenWebCliente: cita['tokenWebCliente'],
    idCitaCliente: cita['idCitaCliente'],
    nombreCliente: cita['nombre'],
    telefonoCliente: cita['telefono'],
    emailCliente: cita['email'],
    notaCliente: cita['nota'],
  );

  ////XXxxxx FUNCION actualizar la cita en Firebase  xxxxxXX
  await ActualizacionCita.actualizar(context, nuevaCita,
      appointmentDragEndDetails.droppingTime!, null, null, emailSesionUsuario);
}
