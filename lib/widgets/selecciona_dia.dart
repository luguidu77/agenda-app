import 'package:agendacitas/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';
import '../utils/extraerServicios.dart';
import '../utils/publicidad.dart';
import '../utils/utils.dart';

class SeleccionaDia extends StatefulWidget {
  const SeleccionaDia(
      {Key? key,
      required this.botonReprogramarVisible,
      required this.idServicio,
      required this.cita})
      : super(key: key);
  final bool botonReprogramarVisible;
  final dynamic idServicio;
  final Map<String, dynamic> cita; //? cita original a reprogramar

  @override
  State<SeleccionaDia> createState() => _SeleccionaDiaState();
}

class _SeleccionaDiaState extends State<SeleccionaDia> {
  late MyLogicCita myLogic;

  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);

  String textoErrorValidacionFecha = '';

  String textoErrorValidacionHora = '';

  String alertaHora = '';
  String textoDia = '';
  String textoFechaHora = '';
  String textoHoraF = '';
  bool _disponible = false;
  Color? color;
  CitaModel cita = CitaModel();
  final _formKey = GlobalKey<FormState>();
  final bool _pagado = false;
  bool _iniciadaSesionUsuario =
      false; // ?  VARIABLE PARA VERIFICAR SI HAY USUARIO CON INCIO DE SESION
  String _emailSesionUsuario = '';
  String _estadoPagadaApp = '';
  DateTime horaInicioProgramable = DateTime.now();
  DateTime horaFinalProgramable = DateTime.now();

  @override
  void initState() {
    inicializacion();
    // traeColorPrimarioTema();
    myLogic = MyLogicCita(cita);

    myLogic.init();
    /*  servicio = _getServicio();
    print(servicio); */
    super.initState();

    // _askPermissions('/nuevacita');
  }

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    _estadoPagadaApp = estadoPagoProvider.estadoPagoApp;
  }

  @override
  Widget build(BuildContext context) {
    // var micontexto = Provider.of<CitaListProvider>(context);
    // var cita = micontexto.getCitaElegida;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            //SELECCION DE DIA //////////////////////////////////
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
                        border:
                            UnderlineInputBorder(borderSide: BorderSide.none)),
                    validator: (value) => _validacionFecha(value),
                    enabled: false,
                    controller: myLogic.textControllerDia,
                    // decoration: const InputDecoration(labelText: 'Día de la cita'),
                  ),
                ),
                TextButton.icon(
                    onPressed: () => funcionDia(context),
                    icon: const Icon(Icons.date_range),
                    label: const Text(''))
              ]),
            ),
            //? hago esta validación porque no se ve TEXTO VALIDATOR si está inabilitado a la escritura
            Text(
              textoErrorValidacionFecha,
              style: estilotextoErrorValidacion,
            ),
            //SELECCION DE HORA//////////////////////////////////
            Column(
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
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide.none)),
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
            ),
            //boton reprogramar cita, es visible si viene llamado de formReprogramarReserva.dart
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                botonReprogramar(
                    context, _emailSesionUsuario, _iniciadaSesionUsuario)
              ],
            )
          ],
        ),
      ),
    );
  }

  funcionDia(context) {
    // var firsDdate = DateTime.now().subtract(const Duration(days: 20));
    // var lastDate = DateTime.now().add(const Duration(hours: 720));
    Intl.defaultLocale = 'es';

    Picker(
        title: const Text("Selecciona una fecha"),
        confirmText: 'Aceptar',
        cancelText: 'Cancelar',
        hideHeader: true,
        adapter: DateTimePickerAdapter(
          type: PickerDateTimeType.kYMD,
          isNumberMonth: true,
        ),
        onConfirm: (Picker picker, List<int> selectedValues) {
          DateTime selectedDate =
              (picker.adapter as DateTimePickerAdapter).value!;
          // Aquí puedes hacer algo con la fecha seleccionada
          setState(() {
            //? FECHA LARGA EN ESPAÑOL
            String fecha = DateFormat.MMMMEEEEd('es_ES')
                .format(DateTime.parse(selectedDate.toString()));
            myLogic.textControllerDia.text =
                fecha; //'${value.day}-${value.month}';
          });
          //todo: pasar por formatar fecha
          //textoDia lo pasamos al contexto
          textoDia =
              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

          // print(selectedDate);
        }).showDialog(context);
  }

  funcionHorarios(context) {
    //  var time = TimeOfDay.now();
    Intl.defaultLocale = 'es';

    Picker(
        confirmText: 'Aceptar',
        cancelText: 'Cancelar',
        hideHeader: true,
        adapter: DateTimePickerAdapter(
          minHour: 8,
          maxHour: 21,
          type: PickerDateTimeType.kHM,
          isNumberMonth: true,
        ),
        title: const Text("Selecciona una hora"),
        onConfirm: (Picker picker, List<int> selectedValues) {
          DateTime selectedTime =
              (picker.adapter as DateTimePickerAdapter).value!;
          // Aquí puedes hacer algo con la fecha seleccionada
          setState(() {
            myLogic.textControllerHora.text =
                ('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}');

            textoFechaHora =
                ('$textoDia ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00Z');
          });
          //todo: pasar por formatar fecha
          //textoDia lo pasamos al contexto
          textoDia =
              '${selectedTime.year}-${selectedTime.month.toString().padLeft(2, '0')}-${selectedTime.day.toString().padLeft(2, '0')}';

          //print(selectedTime);
        }).showDialog(context);
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

// traer horas y minutos de trabajo para sumarlas
  seleccionaCita(BuildContext context, idServicio, usuarioAPP,
      iniciadaSesionUsuario) async {
    DateTime fechaInicio = DateTime.parse(textoFechaHora);
    DateTime fechaFinal;
    DateTime tiempoTotal = fechaInicio;
    int totalTiempoHoras = int.parse('00');
    int totalTiempoMinutos = int.parse('00');
    print('idservicio  = $idServicio');
    //COMPRUEBO EL TIEMPO DEL SERVICIO A PRESTAR
    ServicioModel resServicio = ServicioModel();
    //TRAE SERVICIO DE FIREBASE O DE DISPOSITIVO
    if (iniciadaSesionUsuario) {
      Map<String, dynamic> resServicioFB = {};
      //idServicio VIENE COMO UN TEXTO [{idServicio: QF3o14RyJ5KbSSb0d6bB, activo: true, servicio: Semipermanente con refuerzo, detalle: , precio: 20, tiempo: 01:00}]
      List<String> idServicios = extraerIdServiciosdeCadenaTexto(idServicio);
      for (var idservicio in idServicios) {
        resServicioFB = await FirebaseProvider()
            .cargarServicioPorId(usuarioAPP, idservicio);

        //TIEMPO DEL SERVICIO
        resServicio.tiempo = resServicioFB['tiempo'];
        print('tiempo del Servicio  = ${resServicio.tiempo}');
        // DateTime fechaInicio = DateTime.parse(textoFechaHora);

        // String tiempoServicio = servicio['TIEMPO'];
        var tiempoServicio = resServicio.tiempo!;
        // tiempo servicio en horas
        int tiempoServicioHoras =
            int.parse('${tiempoServicio[0]}${tiempoServicio[1]}');
        // tiempo servicio en minutos
        int tiempoServicioMinutos =
            int.parse('${tiempoServicio[3]}${tiempoServicio[4]}');
        // la hora final se obtiene sumandole a la de inicio el tiempo del servicio
        tiempoTotal = tiempoTotal.add(Duration(
            hours: tiempoServicioHoras, minutes: tiempoServicioMinutos));

        totalTiempoHoras = totalTiempoHoras + tiempoServicioHoras;
        totalTiempoMinutos = totalTiempoMinutos + tiempoServicioMinutos;
        /*  fechaFinal = fechaInicio.add(Duration(
            hours: tiempoServicioHoras, minutes: tiempoServicioMinutos)); */
        // HORA FINAL
      }
      fechaFinal = tiempoTotal;
      textoHoraF = fechaFinal.toString();
      // COMPROBAR LA FECHA NUEVA ESTÁ DISPONIBLE

      _disponible = await _compruebaDisponibilidad(totalTiempoHoras,
          totalTiempoMinutos, usuarioAPP, iniciadaSesionUsuario);
      _disponible = true;
      print('disponible: $_disponible');
      print('fecha1  $fechaInicio ');
    } else {
      resServicio =
          await CitaListProvider().cargarServicioPorId(int.parse(idServicio));

      print('tiempo del Servicio  = ${resServicio.tiempo}');

      // String tiempoServicio = servicio['TIEMPO'];
      var tiempoServicio = resServicio.tiempo!;
      // tiempo servicio en horas
      int tiempoServicioHoras =
          int.parse('${tiempoServicio[0]}${tiempoServicio[1]}');
      // tiempo servicio en minutos
      int tiempoServicioMinutos =
          int.parse('${tiempoServicio[3]}${tiempoServicio[4]}');
      // la hora final se obtiene sumandole a la de inicio el tiempo del servicio
      DateTime fechaFinal = fechaInicio.add(
          Duration(hours: tiempoServicioHoras, minutes: tiempoServicioMinutos));
      // HORA FINAL
      textoHoraF = fechaFinal.toString();

      print('fecha1  $fechaInicio ');

      /*  micontexto.setCitaElegida = {
      'FECHA': textoDia,
      'HORAINICIO': fechaInicio,
      'HORAFINAL': fechaFinal
    }; */

      // COMPROBAR LA FECHA NUEVA ESTÁ DISPONIBLE
      _disponible = await _compruebaDisponibilidad(tiempoServicioHoras,
          tiempoServicioMinutos, usuarioAPP, iniciadaSesionUsuario);
      print('disponible: $_disponible');
    }

    setState(() {});

    // RETORNA SI ESTÁ DISPONIBLE LA FECHA
    return _disponible;
  }

  //? ALGORISMO DE COMPROBACION DE FECHA DISPONIBLE, RETORNA TRUE O FALSE
  _compruebaDisponibilidad(tiempoServicioHoras, tiempoServicioMinutos,
      String usuarioAPP, bool iniciadaSesionUsuario) async {
    bool disp = true;

    List<Map<String, dynamic>> citas = [];
    // TRAE LAS CITAS DE FIREBASE O DISPOSITIVO
    if (iniciadaSesionUsuario) {
      citas = await FirebaseProvider()
          .getCitasHoraOrdenadaPorFecha(usuarioAPP, textoDia);
    } else {
      citas = await CitaListProvider().cargarCitasPorFecha(textoDia);
    }

    //  traigo tanto la id de la cita establecida como la id de la cita reprogramada para posteriormente poder
    // hacer la comparacion en el sentido de que si se trata de la misma no hacer comprobacion de disponibilidad
    // ya que se trata de la cita que vamos a reprogramar; pero si por el contrario si las id son diferentes,
    // quiere decir que puede haber otra cita ocupando el hueco que queremos coger, y en este caso si es necesario
    // ver disponibilidad

    if (citas.isNotEmpty) {
      List auxInicio = citas.map((e) => (e['horaInicio'])).toList();
      List auxFinal = citas.map((e) => (e['horaFinal'])).toList();
      debugPrint('todas las horas de inicio de fecha elegida $auxInicio');
      debugPrint('todas las horas de final de fecha elegida $auxFinal');

      //? id de todoas las citas
      List idCitaOld = citas.map((e) => e['id']).toList();
      //? id de la cita que esto reprogramando
      final idCitaNew = widget.cita['id'];

      for (var i = 0; i < citas.length && disp != false; i++) {
        // ALGORITMO DE COMPROBACION DE HORAS POR CADA CITA YA ESTABLECIDA EN FECHA

        DateTime horaInicioEstablecida =
            DateTime.parse(auxInicio[i].toString());
        DateTime horaFinalEstablecida = DateTime.parse(auxFinal[i].toString());

        alertaHora =
            '${horaInicioEstablecida.hour}:${horaInicioEstablecida.minute.toString().padLeft(2, '0')} a ${horaFinalEstablecida.hour}:${horaFinalEstablecida.minute.toString().padLeft(2, '0')}';
        debugPrint('hora inicio cita cogida $horaInicioEstablecida');
        debugPrint('hora final cita cogida $horaFinalEstablecida');

        horaInicioProgramable = DateTime.parse(textoFechaHora);
        horaFinalProgramable = horaInicioProgramable.add(Duration(
            hours: tiempoServicioHoras, minutes: tiempoServicioMinutos));

        debugPrint('hora INICIO nueva cita $horaInicioProgramable');
        debugPrint('hora FINAL nueva cita $horaFinalProgramable');

        //----------------------------------------------------------------------

        eslamismacita() {
          // FUNCION QUE COMPRUEBA SI LA CITA ENCONTRADA SE TRATA DE LA MISMA CITA A PROGRAMAR

          debugPrint(
              'compruebo si la encontrada se trata de la misma cita :$idCitaNew == ${idCitaOld[i]}');
          if (idCitaNew == idCitaOld[i]) {
            // SE TRATA DE LA MISMA CITA (LOS ID SON IGUALES) , RETORNA DISPONIBLE (SE PUEDE REPROGRAMAR)
            return true;
          } else {
            // SE TRATA DE DIFERENTE CITA (LOS ID SON DIFERENTE) , RETORNA NO DISPONIBLE (NO SE PUEDE REPROGRAMAR)
            return false;
          }
        }
        // LOGICA:
        //---------------------------------------------------------------------
        //  ?   horaInicioEstablecida < horaInicioProgramable
        //  ?        ( SI ES TRUE ):   horaFinalEstablecida  <= horaInicioProgramable  -> FALSE (CITA ENCONTRADA)
        //  ?        ( SI ES FALSE):   horaInicioEstablecida >= horaFinalProgramable  -> FALSE (CITA ENCONTRADA)

        //  ?  SI ENCUENTRA UNA CITA EN LA HORA ELEGIDA, COMPRUEBA QUE NO SE TRATE DE LA MISMA CITA (ID IGUALES)

        bool valIpIn = horaInicioEstablecida.isBefore(horaInicioProgramable);
        bool valFpIn = horaFinalEstablecida.isBefore(horaInicioProgramable) ||
            horaFinalEstablecida == horaInicioProgramable;
        bool valIpFn = horaInicioEstablecida.isAfter(horaFinalProgramable) ||
            horaInicioEstablecida.isAtSameMomentAs(horaFinalProgramable);

        //? COMPROBACION FINAL
        if (valIpIn) {
          valFpIn ? disp = true : disp = eslamismacita();
        } else {
          valIpFn ? disp = true : disp = eslamismacita();
        }
      }
    }

    return disp;
    // si no se trata de la misma cita compruebo disponibilidad-^^^^^^^^^^^^^^----
  }

  botonReprogramar(context, String usuarioAP, bool iniciadaSesionUsuario) {
    return ElevatedButton.icon(
        icon: const Icon(FontAwesomeIcons.check),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _disponible = await seleccionaCita(
                context,
                /*  int.parse */ (widget.idServicio),
                usuarioAP,
                iniciadaSesionUsuario);
            setState(() {});
            if (_disponible) {
              // ? null : Publicidad().publicidad();

              // cita original
              final Map<String, dynamic> oldCita = widget.cita;

              String fecha =
                  '${DateTime.parse(textoFechaHora).year.toString()}-${DateTime.parse(textoFechaHora).month.toString().padLeft(2, '0')}-${DateTime.parse(textoFechaHora).day.toString().padLeft(2, '0')}';
              //  var idCitaOld = oldCita['id'];

              if (iniciadaSesionUsuario) {
                ////XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXFUNCION
                ////XXxxxx FUNCION actualizar la cita en Firebase  xxxxxXX
                ActualizacionCita.actualizar(
                  context,
                  oldCita,
                  null,
                  fecha,
                  horaInicioProgramable,
                  _emailSesionUsuario,
                );
                await FirebaseProvider().creaRecordatorio(
                    usuarioAP,
                    fecha,
                    horaInicioProgramable.toString(),
                    'precio',
                    'comentariocita',
                    'nombrecliente',
                    'telefonocliente',
                    'emailcliente',
                    ['PJg5m6iQQw3btkv1H4EX'],
                    'idempleado',
                    cita.id);
                snackbar();
              } else {
                //reprogramacion de fecha y hora de la cita
                CitaModel newCita = CitaModel();
                newCita.id = int.parse(oldCita['id']);
                newCita.dia = fecha;
                newCita.horaInicio = textoFechaHora;
                newCita.horaFinal = textoHoraF;
                newCita.comentario = oldCita['comentario'];
                newCita.idcliente = oldCita['idCliente'];
                newCita.idservicio = oldCita['idServicio'];

                debugPrint('$fecha  $textoFechaHora $textoHoraF');

                CitaListProvider().actualizarCita(newCita);

                snackbar();
              }

              //todo: incrementar en tabla cliente => citareprogramada (añadir este campo tabla cliente)
            } else {
              alertaCitaNoDisponible();
            }
          }
        },
        style: ButtonStyle(
          iconColor: WidgetStateProperty.all<Color>(Colors.white),
          backgroundColor:
              WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        label: const Text(
          'Validar',
          style: TextStyle(color: Colors.white),
        ));
  }

  void alertaCitaNoDisponible() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              content: Text('Tienes una cita de $alertaHora'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      mensajeError(context, 'CITA NO REPROGRAMADA');
                    },
                    child: const Text('Modificar hora'))
              ],
            ));
  }

  void snackbar() {
    mensajeSuccess(context, 'CITA REPROGRAMADA');

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            index: 0,
            myBnB: 0,
          ),
        ));
  }
}
