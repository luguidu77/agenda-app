import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String? selectedTimeOption;
  List<String> timeOptions = [
    '30 minutos',
    '1 hora',
    '1 hora 30 minutos',
    '2 horas',
    '2 horas 30 minutos',
    '3 horas',
  ];
  late CreacionCitaProvider contextoCreacionCita;
  final _formKey = GlobalKey<FormState>();
  late MyLogicNoDisponible myLogic;
  CitaModel citaInicio = CitaModel();
  CitaModel citaFin = CitaModel();

  String _asunto1 = '';
  String _asunto2 = '';
  String _asunto3 = '';
  String _asunto4 = '';

  String fechaInicio = '';
  String fechaFin = '';
  String horaInicio = '2024-08-09 13:00:00.000Z';
  String horaFin = '2024-08-09 14:00:00.000Z';

  @override
  void initState() {
    emailUsuario();
    traeAsuntosIndisponibilidad();
    myLogic = MyLogicNoDisponible(citaInicio, citaFin, asunto);
    myLogic.init();
    super.initState();
  }

  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';

  List<String> _asuntos = [];

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  traeAsuntosIndisponibilidad() {
    // traer los textos de los asuntos de firebase
    _asunto1 = ' 🩺 medico ';
    _asunto2 = ' 🥣 descanso ';
    _asunto3 = ' 🚙 vacaciones ';
    _asunto4 = 'otro ';
    _asuntos = [_asunto1, _asunto2, _asunto3, _asunto4];
  }

  String asunto = ' 🩺 medico ';
  @override
  Widget build(BuildContext context) {
    //fecha y hora de inicio elegida
    final fecha = widget.argument;
    // LEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    final cita = contextoCreacionCita.getCitaElegida;
    print(fecha);
    print(cita);
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SizedBox(
          height: 500, // Puedes ajustar la altura según tus necesidades

          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ------------------- ASUNTOS----------------------------

            Expanded(
              flex: 2,
              child: SizedBox(
                  child: PageView.builder(
                controller: PageController(
                  initialPage: 1,
                  viewportFraction: 0.4, // Esto ajusta el ancho de cada tarjeta
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int i) {
                  return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = i; // Guardar el índice seleccionado
                          asunto = _asuntos[i].toString();
                        });
                      },
                      child: Card(
                          child: Container(
                              color: _selectedIndex == i
                                  ? Colors.blue[50]
                                  : Colors
                                      .white, // Cambia de color si está seleccionado
                              child: Text(_asuntos[i]))));
                },
              )),
            ),

            // ------------------- TIEMPO----------------------------
            Expanded(
              flex: 6,
              child: Center(
                child: Container(
                    child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //SELECTOR DEL MIEMBRO DEL EQUIPO PARA NO DISPONIBILIDAD
                      //todo: _miembroEquipo(),
                      Text(
                        asunto,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),

                      const SizedBox(height: 50),
                      const Text('FECHA'),
                      Text('${fecha.toString()}'),
                      //FECHA INICIO

                      //HORA INICIO

                      const Text('TRAMO HORARIO'),
                      _duracion(),
                      SizedBox(height: 20),

                      //  const Text('Hasta'),
                      //FECHA FINAL
                      //HORA FINAL
                      // selectDia(context, 'final'),
                      // selectHora(context, 'final'),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )),
              ),
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseProvider().nuevaCita(
                          _emailSesionUsuario,
                          '2024-08-10',
                          horaInicio,
                          horaFin,
                          '0', //precio
                          asunto, //comentario,
                          '999', //idcliente
                          [''], //idServicio,
                          'idEmpleado',
                          '' //idCitaCliente
                          );
                    },
                    child: Text('Aceptar')))
          ])),
    );
  }

  _duracion() {
    return Column(
      children: [
        DropdownButton<String>(
            hint: Text('Selecciona duración'),
            value: selectedTimeOption,
            items: timeOptions.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedTimeOption = newValue;
              });
            }),
      ],
    );
  }
}
