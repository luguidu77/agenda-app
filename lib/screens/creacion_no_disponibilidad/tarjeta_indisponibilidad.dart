import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/formatear.dart';

import 'package:flutter/material.dart';

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
  String horaFinTexto = ''; //2024-08-09 14:00:00.000Z'

  bool personalizado = false;

  TextEditingController personalizacionController = TextEditingController();

  @override
  void initState() {
    reseteaHoraFin();
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
    final color = Theme.of(context).primaryColor;
    final providerHoraFinCarrusel = Provider.of<HoraFinCarrusel>(context);
    horaFin = providerHoraFinCarrusel.horaFin;
    horaFinTexto = horaFin.toString();

    print('horaFinTexto para grabar cita -----------------------$horaFinTexto');

    //fecha y hora de inicio elegida
    dateTimeElegido = widget.argument;

    horaInicioTexto = (widget.argument).toString();
    horaInicio = widget.argument;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
            height: 650, // Puedes ajustar la altura según tus necesidades

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
      ),
    );
  }

  TextFormField formPersonalizaAsunto(Color color) {
    return TextFormField(
        onChanged: (value) => {asunto = personalizacionController.text},
        controller: personalizacionController,
        decoration: InputDecoration(
          iconColor: color,
          suffixIconColor: color,
          fillColor: color,
          hoverColor: color,
          prefixIconColor: color,
          focusColor: color,
          prefixIcon: const Icon(Icons.edit),
          hintText: 'Edita el asunto',
          helperText: 'Mínimo 3 letras',
        ));
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
                      const Text(' Fecha:   '),
                      Text(
                        fechaPantalla,
                        style: subTituloEstilo,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(' de   '),
                      Text(
                        horaInicioPantalla,
                        style: estiloHorarios,
                      ),
                      const Text('    a    '),
                      /*  Text(
                        horaFinPantalla,
                        style: tituloEstilo,
                      ), */
                      CarruselDeHorarios(
                        horaInicio: horaInicio,
                      ),
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

  Expanded _listaAsuntos(providerHoraFinCarrusel) {
    return Expanded(
      flex: 2,
      child: SizedBox(
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
      )),
    );
  }

  void cerrar() {
    Navigator.pop(context);
    setState(() {});
  }
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
