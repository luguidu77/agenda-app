import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/formatear.dart';
import 'package:agendacitas/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../creacion_citas/provider/creacion_cita_provider.dart';

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
  DateTime? horaFin;
  String horaInicioTexto = ''; //2024-08-09 13:00:00.000Z'
  String horaFinTexto = '';

  @override
  void initState() {
    emailUsuario();
    traeAsuntosIndisponibilidad();
    // Formatear la fecha  para firebase
    dia = DateFormat('yyyy-MM-dd').format(widget.argument);
    // Formatear la fecha  para visualizar en pantalla
    fechaPantalla = DateFormat('dd-MM-yyyy').format(widget.argument);
    horaInicioPantalla = DateFormat('HH:mm').format(widget.argument);

    super.initState();
  }

  String _emailSesionUsuario = '';

  List<Map<String, Duration>?> _asuntos = [];

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
    Map<String, Duration> optionsMap = timeOptions.first;
    //fecha y hora de inicio elegida
    dateTimeElegido = widget.argument;

    horaInicioTexto = (widget.argument).toString();
    horaInicio = widget.argument;

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SizedBox(
          height: 500, // Puedes ajustar la altura según tus necesidades

          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ------------------- ASUNTOS----------------------------
            _listaAsuntos(),
            // ------------------- DURACION----------------------------
            _tiempo(optionsMap),

            // ------------------- PRESENTACION DE FECHA Y HORAS---------
            _presentacionFechaHoras(),

            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
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
                        child: const Text('Aceptar')),
                  ],
                ))
          ])),
    );
  }

  Expanded _presentacionFechaHoras() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //SELECTOR DEL MIEMBRO DEL EQUIPO PARA NO DISPONIBILIDAD

              const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        fechaPantalla,
                        style: subTituloEstilo,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        horaInicioPantalla,
                        style: estiloHorarios,
                      ),
                      Text(' - '),
                      /*  Text(
                        horaFinPantalla,
                        style: tituloEstilo,
                      ), */
                      CarruselDeHorarios(
                        horaInicio: horaInicio,
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _listaAsuntos() {
    return Expanded(
      flex: 2,
      child: SizedBox(
          child: PageView.builder(
        controller: PageController(
          initialPage: 0,
          viewportFraction: 0.4, // Esto ajusta el ancho de cada tarjeta
        ),
        itemCount: _asuntos.length,
        itemBuilder: (BuildContext context, int i) {
          String duracion = formateaDurationString(_asuntos, i);

          return InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = i; // Guardar el índice seleccionado
                  asunto = _asuntos[i].toString();

                  DateTime aux =
                      dateTimeElegido!.add(_asuntos[i]!.values.first);
                  horaFinTexto = aux.toString();
                  horaFinPantalla = DateFormat('HH:mm').format(aux);
                });
              },
              child: Card(
                  child: Column(
                children: [
                  Container(
                      color: _selectedIndex == i
                          ? Colors.blue[50]
                          : Colors
                              .white, // Cambia de color si está seleccionado
                      child: Text('${_asuntos[i]!.keys.first}')),
                  Text(duracion)
                ],
              )));
        },
      )),
    );
  }

  Expanded _tiempo(Map<String, Duration> optionsMap) => Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [_duracion(optionsMap)],
      ));

  _duracion(Map<String, Duration> optionsMap) {
    return Column(
      children: [
        DropdownButton<String>(
          hint: const Text('Selecciona duración'),
          value: selectedTimeOption,
          items: optionsMap.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedTimeOption = newValue;
              selectedDateTime = optionsMap[newValue];
              // Actualiza 'horaFin' con la duración seleccionada.
              if (selectedDateTime != null) {
                horaFinTexto = selectedDateTime!.toString();
              }
              DateTime aux = dateTimeElegido!.add(selectedDateTime!);
              horaFinTexto = aux.toString();
              horaFinPantalla = DateFormat('HH:mm').format(aux);
            });
          },
        ),
      ],
    );
  }

  void cerrar() {
    Navigator.pop(context);
  }
}

class CarruselDeHorarios extends StatefulWidget {
  final DateTime? horaInicio;

  const CarruselDeHorarios({super.key, this.horaInicio});

  static Map<String, DateTime> generarHorarios(horaInicio) {
    Map<String, DateTime> horarios = {};
    DateTime startTime = horaInicio; //DateTime(2024, 1, 1, 8, 0); // 08:00 AM

    for (int i = 0; i <= 14; i++) {
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

  double alturaCarrusel = 95;
  int numeroHoras = 1;

  final _estiloResaltado = const TextStyle(
      fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold);
  final _estiloNormal = const TextStyle(
    fontSize: 18,
    color: Color.fromARGB(255, 5, 5, 5),
  ); // /;

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
          print(
              "Página seleccionada: $_currentPage, Horario: ${horarios.keys.elementAt(_currentPage)}");
        });
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
    return GestureDetector(
      onTap: () {
        setState(() {});
        _visibleCarrusel = !_visibleCarrusel;
      },
      child: Container(
          width: 100,
          height: 100,
          child: _visibleCarrusel
              ? Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                      color: Colors.white,
                      height: 100,
                      width: 100, // Altura del carrusel
                      child: PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _pageController,
                          itemCount: horarios.length,
                          itemBuilder: (context, i) {
                            String horario = horarios.keys.elementAt(i);
                            _guardaHoraTexto =
                                horarios.keys.elementAt(_currentPage);

                            return Center(
                              child: Text(horario,
                                  style: _currentPage == i
                                      ? estiloHorarios
                                      : _estiloNormal),
                            );
                          })),
                )
              : Center(child: Text(_guardaHoraTexto, style: estiloHorarios))),
    );
  }
}
