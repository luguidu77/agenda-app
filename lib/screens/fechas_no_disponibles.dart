// ignore_for_file: file_names

import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/cita_list_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/widgets/botones/floating_action_buton_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../mylogic_formularios/mylogic.dart';

class FechasNoDisponibles extends StatefulWidget {
  const FechasNoDisponibles({Key? key}) : super(key: key);

  @override
  State<FechasNoDisponibles> createState() => _FechasNoDisponiblesState();
}

class _FechasNoDisponiblesState extends State<FechasNoDisponibles> {
  final _formKey = GlobalKey<FormState>();
  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);
  String textoErrorValidacionFecha = '';
  String textoErrorValidacionHora = '';
  String textoErrorValidacionAsunto = '';
  String alertaHora = '';
  late MyLogicNoDisponible myLogic;
  CitaModel citaInicio = CitaModel();
  CitaModel citaFin = CitaModel();

  String fechaInicio = '';
  String fechaFin = '';
  String horaInicio = '';
  String horaFin = '';
  String asunto = '';

  bool? pagado;
  String usuarioAPP = '';
  bool iniciadaSesionUsuario = false;
  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar

    final provider = Provider.of<PagoProvider>(context, listen: false);

    //? compruebo si hay email para saber si hay sesion iniciada
    usuarioAPP = provider.pagado['email'];
    iniciadaSesionUsuario = usuarioAPP != '' ? true : false;

    //? compruebo si pago de la app
    pagado = provider.pagado['pago'];
  }

  @override
  void initState() {
    emailUsuario();

    myLogic = MyLogicNoDisponible(citaInicio, citaFin, asunto);
    myLogic.init();
    /*  servicio = _getServicio();
    print(servicio); */
    super.initState();

    // _askPermissions('/nuevacita');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButonWidget(
            icono: const Icon(Icons.check),
            texto: 'No disponible',
            funcion: () async {
              if (_formKey.currentState!.validate()) {
                //SI EL FORMULARIO ES VALIDO
                debugPrint('formulario valido');
                grabaNoDisponible(fechaInicio, horaInicio, horaFin,
                    myLogic.textControllerAsunto.text, '999', '999');

                mensaje(context);
              } else {
                debugPrint('formulario NO valido');
                /*   showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        content: Text('Tienes una cita de $alertaHora'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Modificar hora'))
                        ],
                      )); */
              }
            }),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(children: [
                _botonCerrar(context),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //SELECTOR DEL MIEMBRO DEL EQUIPO PARA NO DISPONIBILIDAD
                      //todo: _miembroEquipo(),
                      const Text(
                        'NO DISPONIBILIDAD',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      _asunto(),
                      const SizedBox(height: 50),
                      const Text('FECHA'),
                      //FECHA INICIO
                      //HORA INICIO

                      selectDia(context, 'inicio'),
                      const Text('TRAMO HORARIO'),
                      selectHora(context, 'inicio'),
                      //  const Text('Hasta'),
                      //FECHA FINAL
                      //HORA FINAL
                      // selectDia(context, 'final'),
                      selectHora(context, 'final'),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ));
  }

  Widget selectDia(context, String opcion) {
    bool inicioFin = opcion == 'inicio' ? true : false;
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
                      labelText: 'Día',
                      border:
                          UnderlineInputBorder(borderSide: BorderSide.none)),
                  validator: (value) => _validacionFecha(value),
                  enabled: false,
                  controller: inicioFin
                      ? myLogic.textControllerDiaInicio
                      : myLogic.textControllerDiaFinal
                  // decoration: const InputDecoration(labelText: 'Día de la cita'),
                  ),
            ),
            TextButton.icon(
                onPressed: () => funcionDia(
                    context, inicioFin, myLogic.textControllerDiaInicio),
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

  Widget selectHora(context, String opcion) {
    bool inicioFin = opcion == 'inicio' ? true : false;
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
                  controller: inicioFin
                      ? myLogic.textControllerHoraInicio
                      : myLogic.textControllerHoraFinal,
                  decoration: InputDecoration(
                      labelText: 'Hora $opcion',
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide.none)),
                ),
              ),
              TextButton.icon(
                  onPressed: () => funcionHora(context, inicioFin),
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

  funcionDia(context, inicioFin, f) {
    var firsDdate = DateTime.now();

    var lastDate = DateTime.now().add(const Duration(hours: 720));
    Intl.defaultLocale = 'es';
// todo picker fecha
/*     showMaterialDatePicker(
        context: context,
        title: 'Selecciona fecha',
        firstDate: firsDdate,
        lastDate: lastDate,
        selectedDate: DateTime.now(),
        onChanged: (value) {
          setState(() {
            inicioFin
                //fechaInicio y fechaFin --  VARIABLE QUE SE MANDA A GUARDAR CITA
                ? fechaInicio =
                    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                : fechaFin =
                    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
            //? FECHA LARGA EN ESPAÑOL PARA PRESENTAR USUARIO
            String fecha = DateFormat.MMMMEEEEd('es_ES')
                .format(DateTime.parse(value.toString()));
            inicioFin
                ? myLogic.textControllerDiaInicio.text = fecha
                : myLogic.textControllerDiaFinal.text =
                    fecha; //'${value.day}-${value.month}';
          });
          /*   //todo: pasar por formatar fecha
          //textoDia lo pasamos al contexto
          textoDia =
              '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'; */
        }); */
  }

  funcionHora(context, inicioFin) {
    var time = TimeOfDay.now();
    Intl.defaultLocale = 'es';
    // todo picker time
    /*   showMaterialTimePicker(
      context: context,
      title: 'Selecciona hora',
      selectedTime: time,
      onChanged: (value) {
        setState(() {
          //? fechaInicio  y fechaFin -- VARIABLES QUE SE MANDA A GUARDAR CITA

          inicioFin
              ? horaInicio =
                  ('$fechaInicio ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:00Z')
              //! en horaFin coge la fecha de inicio, fechaInicio. (esto es provisional)
              : horaFin =
                  ('$fechaInicio ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:00Z');
          //texto   que muestra al usuario en pantalla
          inicioFin
              ? myLogic.textControllerHoraInicio.text =
                  ('${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}')
              : myLogic.textControllerHoraFinal.text =
                  ('${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}');

          /*     textoFechaHora =
              ('$textoDia ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:00Z'); */
        });
      },
    ); */
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

  _botonCerrar(context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                size: 50,
                color: Color.fromARGB(167, 114, 136, 150),
              )),
        ],
      ),
    );
  }

  grabaNoDisponible(
      fecha, horaInicio, horaFinal, comentario, idCliente, idServicio) async {
    debugPrint(fecha.toString()); // formato 2022-12-19

    debugPrint(horaInicio.toString()); //formato 2022-12-19 13:00:00.000Z
    debugPrint(horaFinal.toString()); //formato 2022-12-19 13:00:00.000Z

    debugPrint(idCliente.toString());
    debugPrint(idServicio.toString());

//?   idservicio== 999 y idcliente= 999

//? solo se guarda una fecha , por lo que antes debo programar para guardar cada dia,desde fecha inicio hasta fecha fin
    if (iniciadaSesionUsuario) {
      await FirebaseProvider().nuevaCita(usuarioAPP, fecha, horaInicio,
          horaFinal, '', comentario, idCliente, idServicio, 'idEmpleado');
    } else {
      var citaElegida = Provider.of<CitaListProvider>(context, listen: false);
      await citaElegida.nuevaCita(
        fecha,
        horaInicio,
        horaFinal,
        comentario,
        idCliente,
        idServicio,
      );
    }
  }

  _asunto() {
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
                  validator: (value) => _validacionAsunto(value),
                  enabled: true,
                  controller: myLogic.textControllerAsunto,
                  decoration: const InputDecoration(
                      labelText: 'Asunto',
                      border:
                          UnderlineInputBorder(borderSide: BorderSide.none)),
                ),
              ),
              TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.note),
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

  _validacionAsunto(value) {
    debugPrint(value.isEmpty.toString());
    if (value.isEmpty) {
      textoErrorValidacionAsunto = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      if (value.length < 30) {
        return null;
      }
      return '30 caracteres maximo';
    }
  }

  void mensaje(BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: 'Creado con exito',
      ),
    );
  }
}
