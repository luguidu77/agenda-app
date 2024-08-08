import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/mylogic_formularios/my_logic_cita.dart';
import 'package:agendacitas/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../creacion_citas/provider/creacion_cita_provider.dart';

class CreacionNoDisponibilidadScreen extends StatefulWidget {
  const CreacionNoDisponibilidadScreen({super.key});

  @override
  State<CreacionNoDisponibilidadScreen> createState() =>
      _CreacionNoDisponibilidadScreenState();
}

class _CreacionNoDisponibilidadScreenState
    extends State<CreacionNoDisponibilidadScreen> {
  late CreacionCitaProvider contextoCreacionCita;
  final _formKey = GlobalKey<FormState>();
  late MyLogicNoDisponible myLogic;
  CitaModel citaInicio = CitaModel();
  CitaModel citaFin = CitaModel();

  String fechaInicio = '';
  String fechaFin = '';
  String horaInicio = '';
  String horaFin = '';
  String asunto = '';
  @override
  void initState() {
    emailUsuario();
    myLogic = MyLogicNoDisponible(citaInicio, citaFin, asunto);
    myLogic.init();
    super.initState();
  }

  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  List<dynamic> _conceptos = [
    Text(' 🩺 medico '),
    Text(' 🥣 descanso '),
    Text(' 🚙 vacaciones '),
    Text('otro ')
  ];

  @override
  Widget build(BuildContext context) {
    //fecha y hora de inicio elegida
    final fecha = ModalRoute.of(context)?.settings.arguments;
    // LEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    final cita = contextoCreacionCita.getCitaElegida;
    print(fecha);
    print(cita);
    return SafeArea(
        child: Scaffold(
            floatingActionButton: FloatingActionButonWidget(
                icono: const Icon(Icons.check),
                texto: 'No disponible',
                funcion: () async {
                  if (_formKey.currentState!.validate()) {
                    //SI EL FORMULARIO ES VALIDO
                    debugPrint('formulario valido');
                    /*  grabaNoDisponible(fechaInicio, horaInicio, horaFin,
                    myLogic.textControllerAsunto.text, '999', '999'); */

                    // mensaje(context);
                  } else {
                    debugPrint('formulario NO valido');
                  }
                }),
            appBar: AppBar(
              title: const Text('No disponible'),
            ),
            body:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ------------------- ASUNTOS----------------------------
              Expanded(
                flex: 2,
                child: Container(
                    color: Colors.red,
                    child: PageView.builder(
                      itemCount: 4,
                      itemBuilder: (BuildContext context, int i) {
                        return Card(child: _conceptos[i]);
                      },
                    )),
              ),

              // ------------------- TIEMPO----------------------------
              Expanded(
                flex: 8,
                child: Container(
                    color: const Color.fromARGB(255, 158, 54, 244),
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
                          const SizedBox(
                            height: 20,
                          ),

                          const SizedBox(height: 50),
                          const Text('FECHA'),
                          Text('${fecha.toString()}'),
                          //FECHA INICIO

                          //HORA INICIO

                          const Text('TRAMO HORARIO'),

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
              )
            ])));
  }
}
