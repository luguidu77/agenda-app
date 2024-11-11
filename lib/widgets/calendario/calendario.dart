import 'dart:collection';

import 'package:agendacitas/models/cita_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/providers.dart';
import '../../utils.dart';

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  late final ValueNotifier<List<Event>> selectedEvents;
  List<Map<String, dynamic>> todasLasCitasFB = [];
  List<CitaModel> todasLasCitasDispositivo = [];
  DateTime focusedDay = DateTime.now();
  DateTime? _selectedDay;
  var kEventSource = ({
    DateTime.utc(2023): [
      const Event('Today\'s Event 1'),
    ],
  });

  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar
    _emailSesionUsuario = context.read<EstadoPagoAppProvider>().emailUsuarioApp;
    _iniciadaSesionUsuario =
        context.read<EstadoPagoAppProvider>().iniciadaSesionUsuario;

    await cargaCitas(_emailSesionUsuario);
  }

  cargaCitas(emailSesionUsuario) async {
    if (_iniciadaSesionUsuario && mounted) {
      await FirebaseProvider()
          .getTodasLasCitas(emailSesionUsuario)
          .then((citas) {
        todasLasCitasFB = citas;
        // print('citas $citas');

        setState(() {});
      });
    } else {
      await CitaListProvider().cargarCitas().then((citas) {
        todasLasCitasDispositivo = citas;
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    emailUsuario();

    // cargaCitas();
    _selectedDay = focusedDay;
    selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    /// Example events.
    ///

    int getHashCode(DateTime key) {
      return key.day * 1000000 + key.month * 10000 + key.year;
    }

    /// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
    final kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    List listaFechas = [];
    List<Event> listaEventos = [const Event('title')];
    DateTime fecha = DateTime(2023);
    listaEventos.clear();
    // COMPROBAR INICIO SESION PARA TRAER LAS CITAS DE FIREBASE O DISPOSITIVO
    if (_iniciadaSesionUsuario) {
      for (var item in todasLasCitasFB) {
        fecha = DateTime.parse(item['dia']);
        Event evento = Event(item['comentario'].toString());
        debugPrint('fecha___________$day');
        debugPrint('lista de todas las fechas___________$listaFechas');
        debugPrint('fecha seleccionada _________________$fecha');
        debugPrint('evento seleccionada _________________$evento');

        // AÑADE EVENTO AL CALENDARIO CON SU FECHA CORRESPONDIENTE Y SIEMPRE QUE NO SEA UN NO DISPONIBLE('999')
        if (fecha.day == day.day && item['idCliente'] != '999') {
          // LISTA DE EVENTOS:
          // {2023-03-09 00:00:00.000: [cervicalES], 2023-02-23 00:00:00.000: [cervicalES], 2023-02-14 00:00:00.000: [cervicalES], 2023-03-11 00:00:00.000: [cervicalES], 2023-03-05 00:00:00.000: [cervicalES], 2023-02-15 00:00:00.000: [cervicalES], 2023-02-21 00:00:00.000: [cervicalES]}
          listaEventos.add(evento);
        }

        kEvents.addAll({
          fecha: listaEventos,
        });
      }
    } else {
      for (var item in todasLasCitasDispositivo) {
        fecha = DateTime.parse(item.horaInicio.toString().split(" ")[0]);
        Event evento = Event(item.comentario.toString());
        // AÑADE EVENTO AL CALENDARIO CON SU FECHA CORRESPONDIENTE Y SIEMPRE QUE NO SEA UN NO DISPONIBLE('999')
        if (fecha.day == day.day && item.idservicio != 999) {
          // LISTA DE EVENTOS:
          // {2023-03-09 00:00:00.000: [cervicalES], 2023-02-23 00:00:00.000: [cervicalES], 2023-02-14 00:00:00.000: [cervicalES]}
          listaEventos.add(evento);
        }

        kEvents.addAll({
          fecha: listaEventos,
        });
      }
    }

    // Implementation example
    return kEvents[day] ?? [];
  }

  DateTime today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    /*  print(
        'citas traidas de calendario xxxxxxxxxxxxx ${citas!.map((e) => e['dia'])}'); */

    return Container(
      child: TableCalendar(
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: "es_ES",
        rowHeight: 65, // separacion entre los numeros diarios
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        daysOfWeekHeight: 50, //altura contenedor de los dias semanales
        daysOfWeekStyle: const DaysOfWeekStyle(
          decoration: BoxDecoration(color: Color.fromARGB(255, 210, 207, 219)),
          weekdayStyle: TextStyle(color: Color.fromARGB(255, 92, 91, 94)),
          weekendStyle: TextStyle(color: Color.fromARGB(255, 134, 6, 6)),
        ),
        availableGestures: AvailableGestures.all,
        selectedDayPredicate: (day) => isSameDay(day, today),
        focusedDay: today,
        firstDay: today.subtract(const Duration(days: 30)),
        lastDay: today.add(const Duration(days: 547)), // un año y medio aprox
        onDaySelected: _diaSeleccionado,
        eventLoader: _getEventsForDay,
        calendarBuilders: CalendarBuilders(markerBuilder: (_, datetime, event) {
          return event.isEmpty
              ? Container()
              : Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 197, 75, 75)),
                  child: Center(
                    child: Text(
                      (event.length).toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
        }),
      ),
    );
  }

  void _diaSeleccionado(DateTime day, DateTime focusedDay) {
    setState(() {});
    var calendarioProvider =
        Provider.of<CalendarioProvider>(context, listen: false);
    calendarioProvider.setFechaSeleccionada(day);

    calendarioProvider.setVisibleCalendario(false);
  }
}
