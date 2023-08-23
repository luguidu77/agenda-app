// ignore_for_file: file_names

import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:agendacitas/providers/cita_list_provider.dart';
import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';
import 'package:agendacitas/widgets/configRecordatorios.dart';
import 'package:agendacitas/utils/notificaciones/recordatorio_local/recordatorio_local.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import 'provider/creacion_cita_provider.dart';

//import 'package:url_launcher/url_launcher_string.dart';

//import 'package:sms_advanced/sms_advanced.dart';

class ConfirmarStep extends StatefulWidget {
  const ConfirmarStep({Key? key}) : super(key: key);

  @override
  State<ConfirmarStep> createState() => _ConfirmarStepState();
}

class _ConfirmarStepState extends State<ConfirmarStep> {
  late CreacionCitaProvider contextoCreacionCita;
  final citaElegida = CitaListProvider();
  List<String> tRecordatorioGuardado = [];
  String tiempoTextoRecord = '';
  var tiempoEstablecido = RecordatoriosProvider();
  String horaRecordatorio = '';
  late DateTime tRestado = DateTime.now();
  final estiloTextoTitulo =
      const TextStyle(fontSize: 28, color: Colors.blueGrey);
  final estiloTexto = const TextStyle(
      fontSize: 19, color: Colors.blueGrey, fontWeight: FontWeight.bold);
  //VARIABLES PARA PRESENTARLA EN PANTALLA AL USUARIO
  String telefono = '';
  String email = '';
  String clientaTexto = '';
  String telefonoTexto = '';
  String servicioTexto = '';
  String precioTexto = '';
  String fechaTexto = '';
  String fechaMesEspa = '';
  String citaConfirmadaMes = '';
  String citaConfirmadaDia = '';

  String horaInicioTexto = '';
  String horaFinalTexto = '';

  bool? pagado;
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;

  tiempo() async {
    await tiempoEstablecido.cargarTiempo().then((value) async {
      if (value.isNotEmpty) {
        tRecordatorioGuardado.add(value[0].tiempo.toString());
        debugPrint('hay tiempo recordatorio establecido');
      } else {
        await addTiempo();
        tRecordatorioGuardado.add('00:30');
      }
    });

    // si no hay tiempo establecido guarda uno por defecto de 30 minutos
    //  if (tRecordatorioGuardado.isEmpty) await
    tiempoTextoRecord = tRecordatorioGuardado.first.toString();

    debugPrint('tRecordatorioGuardado : ${tRecordatorioGuardado.first}');

    await guardalacita();
  }

  guardalacita() async {
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    debugPrint('cita elegida ${contextoCreacionCita.getCitaElegida}');
    var clienta = contextoCreacionCita.getClienteElegido;
    clientaTexto = clienta['NOMBRE'];
    telefono = clienta['TELEFONO'];
    email = clienta['EMAIL'];

    List<Map<String, dynamic>> listaServicios =
        contextoCreacionCita.getServiciosElegidos;

    Map<String, dynamic> citaFechaHora = contextoCreacionCita.getCitaElegida;

    DateTime cita = DateTime.parse(
      citaFechaHora['HORAINICIO'].toString(),
    );

    String tiempoAux =
        '${cita.year.toString()}-${cita.month.toString().padLeft(2, '0')}-${cita.day.toString().padLeft(2, '0')} $tiempoTextoRecord';

    if (tiempoTextoRecord != '') {
      DateTime tiempoRecordatorio = DateTime.parse(tiempoAux);
      horaRecordatorio = cita
          .subtract(Duration(
              hours: tiempoRecordatorio.hour,
              minutes: tiempoRecordatorio.minute))
          .toString();
    }

    String fecha = 'dia / mes';
    // '${DateTime.parse(citaFechaHora['FECHA']).day.toString().padLeft(2, '0')}/${DateTime.parse(citaFechaHora['FECHA']).month.toString().padLeft(2, '0')}';

    //todo: pasar por la clase formater hora y fecha
    String textoHoraInicio = 'hora inicio';
    '${DateTime.parse(citaFechaHora['HORAINICIO'].toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(citaFechaHora['HORAINICIO'].toString()).minute.toString().padLeft(2, '0')}';
    String textoHoraFinal =
        '${DateTime.parse(citaFechaHora['HORAFINAL'].toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(citaFechaHora['HORAFINAL'].toString()).minute.toString().padLeft(2, '0')}';

    //VARIABLES PARA PRESENTARLA EN PANTALLA AL USUARIO
    //todo: SUMAR TODOS LOS SERVICIOS ELEGIDOS -------------------------------------??????
    servicioTexto = listaServicios.first['SERVICIO'];
    precioTexto = listaServicios.first['PRECIO'];
    fechaTexto = fecha;
    horaInicioTexto = textoHoraInicio;
    horaFinalTexto = textoHoraFinal;

    citaConfirmadaMes =
        (citaFechaHora['FECHA']).month.toString().padLeft(2, '0').toString();
    citaConfirmadaDia =
        (citaFechaHora['FECHA']).day.toString().padLeft(2, '0').toString();

    //? FECHA LARGA EN ESPAÑOL
    final String fechaLargaEspa = DateFormat.MMMMEEEEd('es_ES')
        .add_jm()
        .format(DateTime.parse(citaFechaHora['HORAINICIO'].toString()));
    // print(fechaLargaEspa);
    fechaTexto = fechaLargaEspa;

    fechaMesEspa = DateFormat.MMM('es_ES')
        .format(DateTime.parse(citaFechaHora['HORAINICIO'].toString()));
    // print(fechaMesEspa); // something ago, sep...
    fechaTexto = fechaLargaEspa;
    DateTime dateTime = citaFechaHora['HORAINICIO'];
    String dateOnlyString =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    //
    // ignore: use_build_context_synchronously
    await grabarCita(
        context,
        fecha,
        textoHoraInicio,
        //citaElegida,
        dateOnlyString,
        citaFechaHora['HORAINICIO'].toString(),
        citaFechaHora['HORAFINAL'].toString(),
        listaServicios.first['DETALLE'],
        clienta['ID'],
        listaServicios.first['ID'],
        clienta['NOMBRE'],
        listaServicios.first['SERVICIO'],
        listaServicios.first['PRECIO']);

    // limpia la lista de servicios
    listaServicios.clear();

    setState(() {});
  }

  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();
    tiempo();
    // compruebaPago();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //BOTON CERRAR X
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: IconButton(
                        onPressed: () {
                          /*  Navigator.pushNamedAndRemoveUntil(
                              context, '/', ModalRoute.withName('/')); */
                          Navigator.pushReplacementNamed(context, '/');
                          liberarMemoriaEditingController();
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 50,
                          color: Color.fromARGB(167, 114, 136, 150),
                        )),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              Flexible(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    // para animar el sheck
                    return servicioTexto == ''
                        ? const Center(
                            child: SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator()))
                        : Column(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Image.asset(
                                  './assets/images/cheque.png',
                                  // width: 100,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                'Reservado $servicioTexto con $clientaTexto para el día $fechaTexto h',
                                style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Divider(),
                              CompartirCitaConCliente(
                                  cliente: clientaTexto,
                                  telefono: telefono,
                                  email: email,
                                  fechaCita: fechaTexto,
                                  servicio: servicioTexto)
                            ],
                          );
                  },
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void liberarMemoriaEditingController() {
    final cliente = ClienteModel();
    final servicio = ServicioModel();
    final cita = CitaModel();

    MyLogicCliente(cliente).dispose();
    MyLogicServicio(servicio).dispose();
    MyLogicCita(cita).dispose();
  }

  grabarCita(
      context,
      fechaTexto,
      horaIniciotexto,
      //CitaListProvider citaElegida,
      String fecha,
      String horaInicio,
      String horaFinal,
      String comentario,
      var idCliente,
      var idServicio,
      String nombreCliente,
      String nombreServicio,
      String precio) async {
    String title = '🙋‍♀️ Tienes cita a las $horaIniciotexto horas ';
    String body =
        '$nombreCliente se va a hacer $nombreServicio ¡ganarás $precio ! 🤑';
    debugPrint('hora recordatorio $horaRecordatorio');
    debugPrint('hora actual ${DateTime.now().toString()}');

    int idCita = 0;
    if (_iniciadaSesionUsuario) {
      String idServicioAux = idServicio
          .toString(); //id los paso a String porque los id de Firebase son caracteres
      String idEmpleado = '55';
      //###### CREA CITA Y TRAE ID CITA CREADA EN FIREBASE PARA ID DEL RECORDATORIO
      idCita = await FirebaseProvider().nuevaCita(
          _emailSesionUsuario,
          fecha,
          horaInicio,
          horaFinal,
          precio,
          comentario,
          idCliente,
          idServicioAux,
          idEmpleado);
    } else {
      //###### CREA CITA Y TRAE ID CITA CREADA EN DISPOSITIVO PARA ID DEL RECORDATORIO
      idCita = await citaElegida.nuevaCita(
        fecha,
        horaInicio,
        horaFinal,
        comentario,
        idCliente,
        idServicio,
      );
    }

    //  RECORDATORIO CON ID PARA EN EL CASO DE QUE SE ELIMINE LA CITA, PODER BORRARLO
    DateTime diaRecord = DateTime.parse(horaRecordatorio);
    // int horaRecord = DateTime.parse(horaRecordatorio).hour;
    // int minutoRecord = DateTime.parse(horaRecordatorio).minute;

    DateTime ahora = DateTime.now().subtract(const Duration(
        minutes:
            1)); // ? incremento 5 minuto porque la fecha notificacion debe ser mayor a la de AHORA

    // GUARDA RECORDATORIO SI LA FECHA ES POSTERIOR A LA ACTUAL
    if (diaRecord.isAfter(ahora)) {
      // if (horaRecord >= ahora.hour) {
      debugPrint('---------GUARDA RECORDATORIO-------');
      try {
        await NotificationService()
            .notificacion(idCita, title, body, 'citapayload', horaRecordatorio);
      } catch (e) {
        mensajeInfo(context, 'No recordaremos esta cita');
        debugPrint(e.toString());
      }
      // }
    }
  }
}
