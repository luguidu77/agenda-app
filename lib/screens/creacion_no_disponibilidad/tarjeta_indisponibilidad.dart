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
  String horaInicio = ''; //2024-08-09 13:00:00.000Z'
  String horaFin = '';

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

    horaInicio = (widget.argument).toString();

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
                              horaInicio,
                              horaFin,
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
                        style: tituloEstilo,
                      ),
                      Text(' - '),
                      Text(
                        horaFinPantalla,
                        style: tituloEstilo,
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
                  horaFin = aux.toString();
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
                horaFin = selectedDateTime!.toString();
              }
              DateTime aux = dateTimeElegido!.add(selectedDateTime!);
              horaFin = aux.toString();
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
