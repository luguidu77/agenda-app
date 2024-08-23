import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/providers/estado_creacion_indisponibilidad.dart';

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
  String horaInicioPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
  String horaFinPantalla = ''; // se presenta cuadro Hora: de 09:00 a 10:00
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
    reseteaHoraElegida();
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
  }

  reseteaHoraElegida() {
    final providerHoraFinCarrusel = context.read<HorarioElegidoCarrusel>();
    // hora inicio
    providerHoraFinCarrusel.setHoraInicio(widget.argument);
    // hora fin
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
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);
    // hora inicio
    horaInicio = providerHoraFinCarrusel.horaInicio;
    horaInicioPantalla = DateFormat('HH:mm').format(horaInicio!);

    // hora fin
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();
    horaFinPantalla = DateFormat('HH:mm').format(horaFin!);

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
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close))
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
              _listaAsuntos(context, fechaElegida, providerHoraFinCarrusel),

              // -------------------TEXTO PERSONALIZADO ----------------------------

              Visibility(
                visible: personalizado,
                child: Form(child: formPersonalizaAsunto(color)),
              ),
              const SizedBox(height: 20),
              // ------------------- PRESENTACION DE FECHA Y HORAS---------
              _presentacionFecha(),
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
                  ['indispuesto'], //idServicio,
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

  _presentacionFecha() {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
          onTap: () => _mostrarTarjeta(context, 'hora', fechaElegida),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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

  _listaAsuntos(context, fechaElegida, providerHoraFinCarrusel) {
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
                    // si el asunto es PERSONALIZADO , visible el form texto personalizado
                    _selectedIndex == 0
                        ? personalizado = true
                        : personalizado = false;
                    // texto del asunto elegido para grabar en firebase
                    asunto = _asuntos[i]!.keys.first.toString();

                    DateTime aux = fechaElegida!.add(_asuntos[i]!.values.first);
                    horaFinTexto = aux.toString();
                    horaFinPantalla = DateFormat('HH:mm').format(aux);
                    // agrega al provider la hora fin
                    providerHoraFinCarrusel.setHoraFin(aux);
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
      isDismissible: false,
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
    );
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

    final providerHorario =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);

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
        // Combina la nueva fecha con la hora original
        DateTime fechaConHoraRespetada = DateTime(
          newFechaElegida.year,
          newFechaElegida.month,
          newFechaElegida.day,
          providerFechaElegida.fechaElegida.hour,
          providerFechaElegida.fechaElegida.minute,
        );
        //setea provider fechaElegida y horario con la fecha seleccionada respetando la hora
        providerFechaElegida.setFechaElegida(fechaConHoraRespetada);
        providerHorario.setHoraInicio(fechaConHoraRespetada);
        providerHorario.setHoraFin(fechaConHoraRespetada);

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
  bool botonActivado = false;

  @override
  Widget build(BuildContext context) {
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);
    // Verifica el estado del botón antes de construir la interfaz
    verificarBotonActivado(providerHoraFinCarrusel);
    return SizedBox(
      height: 500,
      child: seleccionHorarios(),
    );
  }

  void verificarBotonActivado(HorarioElegidoCarrusel providerHoraFinCarrusel) {
    bool nuevoEstado = !providerHoraFinCarrusel.horaInicio.isAfter(
        providerHoraFinCarrusel.horaFin.subtract(const Duration(
            minutes:
                15))); // sustrae 15 minutos para que las horas no sean las mismas
    if (botonActivado != nuevoEstado) {
      setState(() {
        botonActivado = nuevoEstado;
        print("Estado del botón cambiado: $nuevoEstado");
      });
    }
  }

  seleccionHorarios() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CarruselDeHorarios(
                    horaSeleccionada: widget.argument, carrusel: 'horaInicio'),
                const Text('a'),
                CarruselDeHorarios(
                    horaSeleccionada: widget.argument, carrusel: 'horaFinal'),
              ],
            ),
            _botonEstablecerHorario()
          ],
        ),
      ),
    );
  }

  _botonEstablecerHorario() {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: botonActivado ? Colors.black : Colors.grey,
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: InkWell(
            onTap: () {
              botonActivado ? Navigator.pop(context) : null;
            },
            child: const Center(
              child: Text(
                'Establecer',
                style: TextStyle(color: Colors.white),
              ),
            )));
  }
}

// ///////////////////// CARRUSEL DE HORARIO //////////////////////

class CarruselDeHorarios extends StatefulWidget {
  final DateTime? horaSeleccionada;
  final String? carrusel;

  const CarruselDeHorarios({super.key, this.horaSeleccionada, this.carrusel});

  static Map<String, DateTime> generarHorarios(DateTime horaSeleccionada) {
    final horaRef = DateTime(horaSeleccionada.year, horaSeleccionada.month,
        horaSeleccionada.day, 7, 0);

    Map<String, DateTime> horarios = {};
    DateTime startTime = horaRef; // 07:00h

    while (startTime.hour < 23 ||
        (startTime.hour == 23 && startTime.minute == 0)) {
      String formattedTime = DateFormat('HH:mm').format(startTime);
      horarios[formattedTime] = startTime;
      startTime = startTime.add(const Duration(minutes: 15));
    }

    return horarios;
  }

  @override
  State<CarruselDeHorarios> createState() => _CarruselDeHorariosState();
}

class _CarruselDeHorariosState extends State<CarruselDeHorarios> {
  DateTime? fechaElegida;

  Map<String, DateTime> horarios = {};
  final _pageController = PageController(viewportFraction: 0.2);
  int _currentPage = 0;

  double alturaCarrusel = 240;
  int numeroHoras = 1;

  @override
  void didChangeDependencies() {
    //seteaFechaElegida();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    horarios = CarruselDeHorarios.generarHorarios(widget.horaSeleccionada!);

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    // Navegar a la página deseada después de que el widget se haya construido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clave específica que queremos buscar
      String horaBuscada = DateFormat('HH:mm').format(widget.horaSeleccionada!);

      // Convertimos las claves en una lista y encontramos el índice de la clave deseada
      int indice = horarios.keys.toList().indexOf(horaBuscada);

      // Navega a la pagina numero:  índice
      // print('El índice de $horaBuscada es: $indice');
      _pageController.animateToPage(
        indice,
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceIn,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerHoraFinCarrusel =
        Provider.of<HorarioElegidoCarrusel>(context);
    print(horarios);
    return GestureDetector(
        onTap: () {},
        child: SizedBox(
            width: 80,
            height: alturaCarrusel,
            child: Card(
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
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });

                        // Actualizar Provider en base al carrusel
                        if (widget.carrusel == 'horaInicio') {
                          providerHoraFinCarrusel
                              .setHoraInicio(horarios.values.elementAt(index));
                        }

                        if (widget.carrusel == 'horaFinal') {
                          providerHoraFinCarrusel
                              .setHoraFin(horarios.values.elementAt(index));
                        }

                        print('INICIO: ${providerHoraFinCarrusel.horaInicio}');
                        print('FIN: ${providerHoraFinCarrusel.horaFin}');
                      },
                      itemBuilder: (context, i) {
                        String horario = horarios.keys.elementAt(i);

                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                horario,
                                style: estilo(i),
                              )
                            ],
                          ),
                        );
                      })),
            )));
  }

  void seteaFechaElegida() {
    // provider FECHA elegida
    /*  final providerFechaElegida =
        Provider.of<FechaElegida>(context, listen: false);
     providerFechaElegida.setFechaElegida(hora); */

    final providerHorario =
        Provider.of<HorarioElegidoCarrusel>(context, listen: false);
    providerHorario.setHoraInicio(widget.horaSeleccionada!);
    providerHorario.setHoraFin(widget.horaSeleccionada!);
  }

  estilo(int i) {
    if (_currentPage == i) {
      return estiloHorariosResaltado;
    } else if (_currentPage == i - 1 || _currentPage == i + 1) {
      return estiloHorariosAlgoDifuminado;
    } else {
      return estiloHorariosDifuminado;
    }
  }
}
