import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';

import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/formatear.dart';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/providers.dart';
import '../creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';

class TarjetaIndisponibilidad extends StatefulWidget {
  final dynamic argument;
  const TarjetaIndisponibilidad({super.key, this.argument});

  @override
  State<TarjetaIndisponibilidad> createState() =>
      _TarjetaIndisponibilidadState();
}

class _TarjetaIndisponibilidadState extends State<TarjetaIndisponibilidad> {
  int _selectedIndex = 0; // Variable para almacenar el índice seleccionado
  DateTime? dateTimeElegido;
  Duration? selectedDateTime;
  String? selectedTimeOption;
  List<Map<String, Duration>> timeOptions = [
    {
      '30 minutos': const Duration(minutes: 30),
      '1 hora': const Duration(hours: 1),
      '1 hora 30 minutos': const Duration(hours: 1, minutes: 30),
      '2 horas': const Duration(hours: 2),
      '2 horas 30 minutos': const Duration(hours: 2, minutes: 30),
      '3 horas': const Duration(hours: 3),
    }
  ];
  late CreacionCitaProvider contextoCreacionCita;
  final _formKey = GlobalKey<FormState>();
  late MyLogicNoDisponible myLogic;
  CitaModel citaInicio = CitaModel();
  CitaModel citaFin = CitaModel();

  Map<String, Duration>? _asunto1;
  Map<String, Duration>? _asunto2;
  Map<String, Duration>? _asunto3;
  Map<String, Duration>? _asunto4;

  String fechaPantalla = '';
  String dia = '';
  String horaInicioPantalla = '';
  String horaFinPantalla = '';
  String fechaInicio = '';
  String fechaFin = '';
  DateTime? horaInicio;
  DateTime? fechaElegida; // provider fecha elegida
  DateTime? horaFin; // provider hora fin elegida
  String horaInicioTexto = ''; //2024-08-09 13:00:00.000Z'
  String horaFinTexto = ''; //2024-08-09 14:00:00.000Z'

  bool personalizado = true;

  TextEditingController personalizacionController = TextEditingController();

  @override
  void initState() {
    seteafechaElegida();
    reseteaHoraFin();
    emailUsuario();
    traeAsuntosIndisponibilidad();

    super.initState();
  }

  String _emailSesionUsuario = '';

  List<Map<String, Duration>?> _asuntos = [];
  seteafechaElegida() {
    // provider fecha elegida
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
    providerFechaElegida.setFechaElegida(widget.argument);

    // Formatear la fecha  para visualizar en pantalla
    horaInicioPantalla =
        DateFormat('HH:mm').format(providerFechaElegida.fechaElegida);
  }

  reseteaHoraFin() {
    final providerHoraFinCarrusel = context.read<HoraFinCarrusel>();
    providerHoraFinCarrusel.setHoraFin(widget.argument);
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  traeAsuntosIndisponibilidad() {
    // traer los textos de los asuntos de firebase
    _asunto1 = {' ✏️ personalizado ': const Duration(minutes: 0)};
    _asunto2 = {' 🥣 descanso ': const Duration(minutes: 30)};
    _asunto3 = {' 😷  médico ': const Duration(hours: 1)};
    _asunto4 = {' ➕  nuevo asunto ': const Duration(minutes: 30)};

    _asuntos = [_asunto1, _asunto2, _asunto3, _asunto4];
  }

  String asunto = ' 🩺 medico ';
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor; // color del tema

    // provider FECHA elegida
    final providerFechaElegida = Provider.of<FechaElegida>(context);
    fechaElegida = providerFechaElegida.fechaElegida;
    dia = DateFormat('yyyy-MM-dd') // fecha formateada para FIREBASE
        .format(fechaElegida!);

    // provider HORA elegidad
    final providerHoraFinCarrusel = Provider.of<HoraFinCarrusel>(context);
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();

    print('horaFinTexto para grabar cita -----------------------$horaFinTexto');

    //fecha y hora de inicio elegida
    // dateTimeElegido = widget.argument;

    horaInicioTexto = (fechaElegida).toString();
    horaInicio = fechaElegida;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.close))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                ' Agrega horario no disponible',
                style: estiloHorarios,
              ),
              const SizedBox(height: 40),
              // ------------------- ASUNTOS----------------------------
              _listaAsuntos(providerHoraFinCarrusel),

              // -------------------TEXTO PERSONALIZADO ----------------------------

              Visibility(
                visible: personalizado,
                child: Form(child: formPersonalizaAsunto(color)),
              ),
              const SizedBox(height: 20),
              // ------------------- PRESENTACION DE FECHA Y HORAS---------
              _presentacionFecha(providerFechaElegida),
              const SizedBox(height: 20),
              _presentacionHoras(),
              const SizedBox(height: 40),
              _botonGuardar()
            ]),
          ),
        ),
      ),
    );
  }

  _botonGuardar() {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: InkWell(
            onTap: () async {
              await FirebaseProvider().nuevaCita(
                  _emailSesionUsuario,
                  dia,
                  horaInicioTexto,
                  horaFinTexto,
                  '0', //precio
                  asunto, //comentario,
                  '999', //idcliente
                  [''], //idServicio,
                  'idEmpleado',
                  '' //idCitaCliente
                  );

              cerrar();
            },
            child: const Center(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            )));
  }

  formPersonalizaAsunto(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Título:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
            onChanged: (value) => {asunto = personalizacionController.text},
            controller: personalizacionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
              iconColor: color,
              suffixIconColor: color,
              fillColor: color,
              hoverColor: color,
              prefixIconColor: color,
              focusColor: color,
              hintText: 'ej.: comida de empresa',
            )),
      ],
    );
  }

  _presentacionFecha(providerFechaElegida) {
    final dia = DateFormat('dd-MM-yyyy') // FECHA FORMATEADA ESPAÑOLA
        .format(fechaElegida!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () => _mostrarTarjeta(context, 'calendario', widget.argument),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dia, style: estiloHorarios),
                const Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ),
      ],
    );
  }

  _presentacionHoras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hora:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: () => _mostrarTarjeta(context, 'hora', widget.argument),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('de'),
                Text(
                  horaInicioPantalla,
                  style: estiloHorarios,
                ),
                const Text('a'),
                Text(horaFinPantalla, style: estiloHorarios),
                const Icon(Icons.arrow_drop_down_outlined)
              ],
            ),
          ),
        ),
      ],
    );
  }

  _listaAsuntos(providerHoraFinCarrusel) {
    return SizedBox(
        height: 150,
        child: PageView.builder(
          controller: PageController(
            initialPage: 0,
            viewportFraction: 0.5, // Esto ajusta el ancho de cada tarjeta
          ),
          itemCount: _asuntos.length,
          itemBuilder: (BuildContext context, int i) {
            String duracion = formateaDurationString(_asuntos, i);

            return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = i; // Guardar el índice seleccionado

                    _selectedIndex ==
                            0 // si el asunto es PERSONALIZADO , visible el form texto personalizado
                        ? personalizado = true
                        : personalizado = false;

                    asunto = _asuntos[i]!
                        .keys
                        .first
                        .toString(); // texto del asunto elegido para grabar en firebase

                    DateTime aux =
                        dateTimeElegido!.add(_asuntos[i]!.values.first);
                    horaFinTexto = aux.toString();
                    horaFinPantalla = DateFormat('HH:mm').format(aux);

                    providerHoraFinCarrusel
                        .setHoraFin(aux); // agrega al provider la hora fin
                  });
                },
                child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15), // Radio de los bordes
                      side: BorderSide(
                        color: _selectedIndex == i
                            ? const Color(0xFF0000FF)
                            : Colors
                                .white, // Cambia de color si está seleccionado
                        width: 2, // Grosor del borde
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_asuntos[i]!.keys.first),
                        Text(
                          duracion,
                          style: subTituloEstilo,
                        )
                      ],
                    )));
          },
        ));
  }

  _mostrarTarjeta(context, tarjeta, fecha) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return tarjeta == 'calendario'
            ? TarjetaCalendario(argument: fecha)
            : TarjetaHora(argument: fecha);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled:
          true, // Si quieres que el modal pueda ser de altura completa
    ); /* .whenComplete(() =>
      Provider.of<BotonAgregarIndisponibilidadProvider>(context, listen: false)
          .setBotonPulsadoIndisponibilidad(false)); */
  }

  void cerrar() {
    Navigator.pop(context);
    setState(() {});
  }
}

/////////// TARJETA DEL CALENDARIO ///////////////////////////////////

class TarjetaCalendario extends StatefulWidget {
  final dynamic argument;
  const TarjetaCalendario({super.key, this.argument});

  @override
  State<TarjetaCalendario> createState() => _TarjetaCalendarioState();
}

class _TarjetaCalendarioState extends State<TarjetaCalendario> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(children: [
        calendario(context),
      ]),
    );
  }

  calendario(context) {
    final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);

    return TableCalendar(
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
      selectedDayPredicate: (day) => isSameDay(
          day, providerFechaElegida.fechaElegida), // fecha seleccionada
      focusedDay: DateTime.now(),
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      onDaySelected: (day, newFechaElegida) {
        //setea provider fechaElegida con la fecha seleccionada

        providerFechaElegida.setFechaElegida(newFechaElegida);

        Navigator.pop(context);
      }, //_diaSeleccionado,
      // eventLoader: _getEventsForDay,
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
    );
  }
}

/////////// TARJETA DE SELECCION DE HORARIOS /////////////////////////
class TarjetaHora extends StatefulWidget {
  final dynamic argument;
  const TarjetaHora({super.key, this.argument});

  @override
  State<TarjetaHora> createState() => _TarjetaHoraState();
}

class _TarjetaHoraState extends State<TarjetaHora> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: seleccionHorarios(context),
    );
  }

  seleccionHorarios(BuildContext context) {}
}

// ///////////////////// CARRUSEL DE HORARIO //////////////////////

class CarruselDeHorarios extends StatefulWidget {
  final DateTime? horaInicio;

  const CarruselDeHorarios({super.key, this.horaInicio});

  static Map<String, DateTime> generarHorarios(horaInicio) {
    Map<String, DateTime> horarios = {};
    DateTime startTime = horaInicio;

    while (startTime.hour < 23 ||
        (startTime.hour == 23 && startTime.minute == 0)) {
      String formattedTime = DateFormat('HH:mm').format(startTime);
      horarios[formattedTime] = startTime;
      startTime = startTime.add(const Duration(minutes: 30));
    }

    return horarios;
  }

  @override
  State<CarruselDeHorarios> createState() => _CarruselDeHorariosState();
}

class _CarruselDeHorariosState extends State<CarruselDeHorarios> {
  Map<String, DateTime> horarios = {};
  final PageController _pageController = PageController(viewportFraction: 0.3);
  int _currentPage = 0;
  String _guardaHoraTexto = '';
  DateTime? _guardaHoraFin;

  bool _visibleCarrusel = false;

  double alturaCarrusel = 140;
  int numeroHoras = 1;

  @override
  void initState() {
    horarios = CarruselDeHorarios.generarHorarios(widget.horaInicio);

    _guardaHoraTexto = horarios.keys.elementAt(0);
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (_currentPage != newPage) {
        setState(() {
          _currentPage = newPage;
          /*   print(
              "Página seleccionada: $_currentPage, Horario: ${horarios.keys.elementAt(_currentPage)}"); */
        });

        //  horarios.values.elementAt(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerHoraFinCarrusel = Provider.of<HoraFinCarrusel>(context);
    String textoHoraFin =
        DateFormat('HH:mm').format(providerHoraFinCarrusel.horaFin);
    return GestureDetector(
      onTap: () {
        providerHoraFinCarrusel
            .setHoraFin(horarios.values.elementAt(_currentPage));

        setState(() {});

        _visibleCarrusel = !_visibleCarrusel;
      },
      child: SizedBox(
          width: 80,
          height: alturaCarrusel,
          child: _visibleCarrusel
              ? Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                      color: Colors.white,
                      width: 80,
                      height: alturaCarrusel,
                      // Altura del carrusel
                      child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _pageController,
                          itemCount: horarios.length,
                          itemBuilder: (context, i) {
                            String horario = horarios.keys.elementAt(i);
                            _guardaHoraTexto =
                                horarios.keys.elementAt(_currentPage);

                            return Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(horario,
                                      style: _currentPage == i
                                          ? estiloHorariosResaltado
                                          : estiloHorariosDifuminado),
                                ],
                              ),
                            );
                          })),
                )
              : Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(textoHoraFin, style: estiloHorarios),
                    const Icon(Icons.arrow_drop_down_outlined)
                  ],
                ))),
    );
  }
}
