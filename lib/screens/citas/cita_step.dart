import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class CitaStep extends StatefulWidget {
  const CitaStep({Key? key}) : super(key: key);

  @override
  State<CitaStep> createState() => _CitaStepState();
}

class _CitaStepState extends State<CitaStep> {
  // DISPONIBILIDAD SEMANAL
  //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
  Set<int> diasNoDisponibles = {}, diasNoDisponiblesProvider = {};

  // bool _pagado = false;
  bool _iniciadaSesionUsuario = false;
  CitaModel cita = CitaModel();
  final _formKey = GlobalKey<FormState>();
  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);
  String textoErrorValidacionFecha = '',
      textoErrorValidacionHora = '',
      alertaHora = '';

  late MyLogicCita myLogic;

  String textoDia = '';
  String textoFechaHora = '';
  bool _disponible = false;

  String _emailSesionUsuario = '';

  emailUsuarioApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    myLogic = MyLogicCita(cita);
    myLogic.init();

    emailUsuarioApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // LLEER MICONTEXTO DE CITALISTPROVIDER
    var micontexto = context.read<CitaListProvider>();
    // LLEER DIAS SEMANALES NO DISPONIBLES
    //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
    diasNoDisponiblesProvider =
        context.read<DispoSemanalProvider>().diasNoDisponibles;

    return Scaffold(
      floatingActionButton: FloatingActionButonWidget(
        icono: const Icon(Icons.check),
        texto: 'Reservar',
        funcion: () async {
          if (_formKey.currentState!.validate()) {
            Map resp = await seleccionaCita(context, micontexto);

            _disponible = await resp['disp'];
            // setState(() {});
            if (_disponible) {
              //_pagado ? null : Publicidad().publicidad();

              _irConfirmarStep();
            } else {
              String descripDisponibilidad = resp['descrip'];
              _alertaNoDisponibilidad(descripDisponibilidad);
            }
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 10.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          height: MediaQuery.of(context).size.height - 150,
          // color: Colors.white,
          child: Stack(children: [
            //DECORACION DE FONDO -----------------------------------
            Padding(
              padding: const EdgeInsets.only(right: 38.0),
              child: ClipPath(
                  clipper: const Clipper1(),
                  child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    // height: 200,
                  )),
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: ClipPath(
                  clipper: const Clipper2(),
                  child: Container(
                    width: 295,
                    height: 317,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  )),
            ), //DECORACION DE FONDO -----------------------------------
            Column(
              children: [
                Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BarraProgreso().progreso(
                          context,
                          0.9,
                          Colors.green,
                        ),
                        const SizedBox(height: 50),
                        selectDia(context),
                        const SizedBox(height: 50),
                        selectHora(context),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      recordatorios(context),
                    ],
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  //traer horas y minutos de trabajo para sumarlas
  seleccionaCita(context, micontexto) async {
    DateTime fechaInicio = DateTime.parse(textoFechaHora);
    var servicio = micontexto.getServicioElegido;
    String tiempoServicio = servicio['TIEMPO'];
    int tiempoServicioHoras =
        int.parse('${tiempoServicio[0]}${tiempoServicio[1]}');

    int tiempoServicioMinutos =
        int.parse('${tiempoServicio[3]}${tiempoServicio[4]}');

    DateTime fechaFinal = fechaInicio.add(
        Duration(hours: tiempoServicioHoras, minutes: tiempoServicioMinutos));

    debugPrint('fecha1  $fechaInicio ');

    micontexto.setCitaElegida = {
      'FECHA': textoDia,
      'HORAINICIO': fechaInicio,
      'HORAFINAL': fechaFinal
    };
    // COMPRUEBA DISPONIBILIDAD SEMANAL
    Map resp = await _compruebaDisponibilidad(context, tiempoServicioHoras,
        tiempoServicioMinutos, _emailSesionUsuario);

    _disponible = resp['disp'];

    debugPrint('disponible: $_disponible');
    setState(() {});
    return resp;
  }

  var resp = {'disp': false, 'descrip': ''};
  _compruebaDisponibilidad(context, tiempoServicioHoras, tiempoServicioMinutos,
      String emailusuario) async {
    bool disp = true;

    //? PREGUNTO SI HAY USUARIO LOGEADO
    debugPrint(
        'pregunto si hay usuario antes de ver disponibilidad:->  $emailusuario  <-');
    _iniciadaSesionUsuario
        ? diasNoDisponibles =
            diasNoDisponiblesProvider // diasNoDisponibles desde la carpeta utils //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7
        : debugPrint('NO HAY USURIO LOGEADO!!!!');

    debugPrint(
        ' comprobando disponibilidad semanal ${diasNoDisponibles.contains(DateTime.parse(textoFechaHora).weekday).toString()}');
    debugPrint(' dia de la semana  ${DateTime.parse(textoFechaHora).weekday}');

    //? COMPROBAR SI EL DIA DE LA SEMANA ESTA DISPONIBLE PARA EL SERVICIO SI LA CONDICION ES TRUE QUIERE DECIR QUE ESTE DIA SEMANAL NO ESTA DISPONIBLE
    if (diasNoDisponibles.contains(DateTime.parse(textoFechaHora).weekday)) {
      debugPrint(' DIA SEMANAL NO DISPONIBLE');
      //  disp = false;
      resp['disp'] = false;
      resp['descrip'] =
          'Los ${obtenerNombreDiaSemana(textoFechaHora)} no están disponibles para citar ';
      return resp;
    } else {
      debugPrint(' DIA SEMANAL DISPONIBLE');

      List<Map<String, dynamic>> citas_ = [];
      if (_iniciadaSesionUsuario) {
        citas_ = await FirebaseProvider()
            .getCitasHoraOrdenadaPorFecha(_emailSesionUsuario, textoDia);
      } else {
        citas_ = await CitaListProvider().cargarCitasPorFecha(textoDia);
      }

      //comprobar disponibilidad PARA  TODAS LAS CITAS PREVIAS
      if (citas_.isNotEmpty) {
        List auxInicio = citas_.map((e) => (e['horaInicio'])).toList();
        List auxFinal = citas_.map((e) => (e['horaFinal'])).toList();
        debugPrint(auxInicio.toString());
        debugPrint(auxFinal.toString());

        for (var i = 0; i < citas_.length && disp != false; i++) {
          DateTime ip = DateTime.parse(auxInicio[i].toString());
          DateTime fp = DateTime.parse(auxFinal[i].toString());

          alertaHora =
              '${ip.hour}:${ip.minute.toString().padLeft(2, '0')} a ${fp.hour}:${fp.minute.toString().padLeft(2, '0')}';
          debugPrint('hora inicio cita cogida $ip');
          debugPrint('hora final cita cogida $fp');

          DateTime in_ = DateTime.parse(textoFechaHora);
          DateTime fn_ = in_.add(Duration(
              hours: tiempoServicioHoras, minutes: tiempoServicioMinutos));

          debugPrint('hora INICIO nueva cita $in_');
          debugPrint('hora FINAL nueva cita $fn_');

          bool valIpIn = ip.isBefore(in_);
          bool valFpIn = fp.isBefore(in_) || fp == in_;
          bool valIpFn = ip.isAfter(fn_) || ip.isAtSameMomentAs(fn_);

          /* LOGICA:   p(COGIDA)   n(NUEVA)

                 ?   Ip < In
                 ?         SI ES TRUE :   Fp <= In  -> FALSE (CITA ENCONTRADA)
                 ?         SI ES FALSE:   Ip >= Fn  -> FALSE (CITA ENCONTRADA)
         */

          if (valIpIn) {
            valFpIn ? disp = true : disp = false;
          } else {
            valIpFn ? disp = true : disp = false;
          }
        }
      }
      resp['disp'] = disp;
      return resp;
    }
  }

  void _alertaNoDisponibilidad(String descripDisponibilidad) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              content: descripDisponibilidad == ''
                  ? Text('Tienes una cita de $alertaHora')
                  : Text(descripDisponibilidad),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            ));
  }

  Future<void> _irConfirmarStep() async {
    await Navigator.pushNamedAndRemoveUntil(
        context, 'confirmarStep', ModalRoute.withName('/'));
  }

  Widget selectDia(context) {
    return Column(
      children: [
        Container(
          width: 300,
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.blue)),
          child: Stack(alignment: Alignment.centerRight, children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextFormField(
                decoration: const InputDecoration(
                    hintStyle: TextStyle(color: Colors.black87),
                    labelText: 'Día de la cita',
                    border: UnderlineInputBorder(borderSide: BorderSide.none)),
                validator: (value) => _validacionFecha(value),
                enabled: false,
                controller: myLogic.textControllerDia,
                // decoration: const InputDecoration(labelText: 'Día de la cita'),
              ),
            ),
            TextButton.icon(
                onPressed: () {
                  funcionDia(context);
                },
                icon: const Icon(Icons.date_range),
                label: const Text(''))
          ]),
        ),
        //? hago esta validación porque no se ve TEXTO VALIDATOR si está inabilitado a la escritura
        Text(
          textoErrorValidacionFecha,
          style: estilotextoErrorValidacion,
        )
      ],
    );
  }

  Widget selectHora(context) {
    return Column(
      children: [
        Container(
          width: 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.blue)),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextFormField(
                  validator: (value) => _validacionHora(value),
                  enabled: false,
                  controller: myLogic.textControllerHora,
                  decoration: const InputDecoration(
                      labelText: 'Hora de la cita',
                      border:
                          UnderlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),
              TextButton.icon(
                  onPressed: () => funcionHorarios(context),
                  icon: const Icon(Icons.timer_sharp),
                  label: const Text(''))
            ],
          ),
        ),
        //? hago esta validación porque no se ve TEXTO VALIDATOR si está inabilitado a la escritura
        Text(
          textoErrorValidacionHora,
          style: estilotextoErrorValidacion,
        )
      ],
    );
  }

  Widget recordatorios(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Recordatorio'),
        SizedBox(width: 10),
        ConfigRecordatorios()
      ],
    );
  }

  funcionDia(context) async {
    DateTime? diaSeleccionado =
        await SeleccionFechaHora().seleccionFecha(context);
    if (diaSeleccionado != null) {
      setState(() {
        String fecha = DateFormat.MMMMEEEEd('es_ES')
            .format(DateTime.parse(diaSeleccionado.toString()));
        myLogic.textControllerDia.text = fecha; //'${value.day}-${value.month}';
        textoDia =
            '${diaSeleccionado.year}-${diaSeleccionado.month.toString().padLeft(2, '0')}-${diaSeleccionado.day.toString().padLeft(2, '0')}';
        myLogic.textControllerHora.text = '';
      });
    }
  }

  funcionHorarios(context) async {
    TimeOfDay? newTime = await SeleccionFechaHora().seleccionHora(context);
    if (newTime != null) {
      setState(() {
        myLogic.textControllerHora.text =
            ('${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}');

        textoFechaHora =
            ('$textoDia ${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}:00Z');
      });
    }
  }

  _validacionFecha(value) {
    if (value.isEmpty) {
      textoErrorValidacionFecha = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      textoErrorValidacionFecha = '';
      setState(() {});
    }
  }

  _validacionHora(value) {
    if (value.isEmpty) {
      textoErrorValidacionHora = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      textoErrorValidacionHora = '';
      setState(() {});
    }
  }

  String obtenerNombreDiaSemana(String textoFechaHora) {
    DateTime fechaHora = DateTime.parse(textoFechaHora);
    List<String> nombresDiasSemana = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    int numeroDiaSemana = fechaHora.weekday;
    return nombresDiasSemana[numeroDiaSemana - 1];
  }
}
