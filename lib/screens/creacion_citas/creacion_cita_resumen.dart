// ignore_for_file: file_names

import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/appBar.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';

import 'package:agendacitas/utils/notificaciones/recordatorio_local/recordatorio_local.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import '../../utils/formatear.dart';
import '../../widgets/widgets.dart';
import 'provider/creacion_cita_provider.dart';
import 'utils/adaptacion_perfilmodel_negociomodel.dart';
import 'utils/formatea_fecha_hora.dart';
import 'utils/id_cita_cliente_random.dart';

//import 'package:url_launcher/url_launcher_string.dart';

//import 'package:sms_advanced/sms_advanced.dart';

class ConfirmarStep extends StatefulWidget {
  const ConfirmarStep({Key? key}) : super(key: key);

  @override
  State<ConfirmarStep> createState() => _ConfirmarStepState();
}

class _ConfirmarStepState extends State<ConfirmarStep> {
  late CreacionCitaProvider contextoCreacionCita;

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
        print('no hay tiempo establecido');
        /*  await addTiempo();
        tRecordatorioGuardado.add('00:30'); */
      }
    });

    // si no hay tiempo establecido guarda uno por defecto de 30 minutos
    //  if (tRecordatorioGuardado.isEmpty) await
    tiempoTextoRecord = tRecordatorioGuardado.first.toString();

    debugPrint('tRecordatorioGuardado : ${tRecordatorioGuardado.first}');

    await guardalacita();
  }

  double sumarPrecios(listaServicios) {
    double suma = 0.0;

    for (var servicio in listaServicios) {
      // Obtener el precio en formato de cadena y convertirlo a double
      double precio = double.parse(servicio['PRECIO']!);
      suma += precio;
    }

    return suma;
  }

  guardalacita() async {
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    debugPrint('cita elegida ${contextoCreacionCita.contextoCita.toString()}');
    // GENERO UN ID PARA LA CITA(idCitaCliente); // Ejemplo: b7gjR3jNuMRomunRo6SJ
    String idCitaCliente = generarCadenaAleatoria(20);
    // GUARDA EN EL CONTEXTO DE LA CITA
    CitaModelFirebase edicionCita =
        CitaModelFirebase(idCitaCliente: idCitaCliente);
    contextoCreacionCita.setContextoCita(edicionCita);

    CitaModelFirebase citaElegida = contextoCreacionCita.contextoCita;
    clientaTexto = citaElegida.nombreCliente!;
    telefono = citaElegida.telefonoCliente!;
    email = citaElegida.emailCliente!;

    List<Map<String, dynamic>> listaServicios =
        contextoCreacionCita.getServiciosElegidos;

    DateTime cita = DateTime.parse(
      citaElegida.horaInicio.toString(),
    );

    if (tiempoTextoRecord != '') {
      String tiempoAux =
          '${cita.year.toString()}-${cita.month.toString().padLeft(2, '0')}-${cita.day.toString().padLeft(2, '0')} $tiempoTextoRecord';
      DateTime tiempoRecordatorio = DateTime.parse(tiempoAux);

      // si tiempo a restar es '24:00' , resto un día
      if (tiempoTextoRecord[0] == '2') {
        horaRecordatorio = cita
            .subtract(const Duration(
              days: 1,
            ))
            .toString();
      } else {
        String tiempoAux =
            '${cita.year.toString()}-${cita.month.toString().padLeft(2, '0')}-${cita.day.toString().padLeft(2, '0')} $tiempoTextoRecord';
        DateTime tiempoRecordatorio = DateTime.parse(tiempoAux);

        horaRecordatorio = cita
            .subtract(Duration(
                hours: tiempoRecordatorio.hour,
                minutes: tiempoRecordatorio.minute))
            .toString();
      }
    }

    String fecha =
        '${DateTime.parse(citaElegida.horaInicio.toString()).day.toString().padLeft(2, '0')}/${DateTime.parse(citaElegida.horaInicio.toString()).month.toString().padLeft(2, '0')}';

    //todo: pasar por la clase formater hora y fecha
    String textoHoraInicio =
        '${DateTime.parse(citaElegida.horaInicio.toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(citaElegida.horaInicio.toString()).minute.toString().padLeft(2, '0')}';
    String textoHoraFinal =
        '${DateTime.parse(citaElegida.horaFinal.toString()).hour.toString().padLeft(2, '0')}:${DateTime.parse(citaElegida.horaFinal.toString()).minute.toString().padLeft(2, '0')}';

    //VARIABLES PARA PRESENTARLA EN PANTALLA AL USUARIO
    //todo: SUMAR TODOS LOS SERVICIOS ELEGIDOS -------------------------------------??????
    double sumaTotal = sumarPrecios(listaServicios);
    servicioTexto = listaServicios.first['SERVICIO'];
    precioTexto = sumaTotal.toString();
    fechaTexto = fecha;
    horaInicioTexto = textoHoraInicio;
    horaFinalTexto = textoHoraFinal;

    citaConfirmadaMes =
        (citaElegida.horaInicio!).month.toString().padLeft(2, '0').toString();
    citaConfirmadaDia =
        (citaElegida.horaInicio!).day.toString().padLeft(2, '0').toString();

    //? FECHA LARGA EN ESPAÑOL
    final String fechaLargaEspa = DateFormat.MMMMEEEEd('es_ES')
        .add_jm()
        .format(DateTime.parse(citaElegida.horaInicio.toString()));
    // print(fechaLargaEspa);
    fechaTexto = fechaLargaEspa;

    fechaMesEspa = DateFormat.MMM('es_ES')
        .format(DateTime.parse(citaElegida.horaInicio.toString()));
    // print(fechaMesEspa); // something ago, sep...
    fechaTexto = fechaLargaEspa;
    DateTime dateTime = citaElegida.horaInicio!;
    String dateOnlyString =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    //GRABA LA CITA EN EL NEGOCIO
    await grabarCita(
        context,
        fecha,
        textoHoraInicio,
        citaElegida,
        dateOnlyString,
        /*  citaElegida.horaInicio.toString(),
        citaElegida.horaFinal.toString(),
        citaElegida.comentario.toString(),
        citaElegida.idcliente!, */
        listaServicios.map((e) => e['ID'].toString()).toList(),
        /*  citaElegida.nombreCliente!,
        citaElegida.telefonoCliente!, */
        listaServicios.first['SERVICIO'],
        precioTexto);

    //* CLIENTE : comprobar si el cliente tiene cuenta en la web para agregarle la cita

    //? PERFIL DEL NEGOCIO (USUARIOAPP)
    final perfilNegocio =
        await FirebaseProvider().cargarPerfilFB(_emailSesionUsuario);
    //? PASO DE PERFILMODEL A NEGOCIOMODEL
    NegocioModel negocio = adaptacionPerfilNegocio(perfilNegocio);

    // Formatear la fecha al formato deseado
    Map<String, dynamic> resultado =
        formatearFechaYHora(citaElegida.horaInicio!);

    String fechaFormateada = resultado['fechaFormateada'];
    String horaFormateada = resultado['horaFormateada'];

    //* TODOS LOS SERVICIOS
    List<ServicioModel> servicios = [];
    ServicioModel servicio = ServicioModel();
    listaServicios.map((e) => e['SERVICIO']).toList();

    for (var element in listaServicios) {
      servicio.servicio = element['SERVICIO'];
      servicio.tiempo = element['TIEMPO'];
      servicios.add(servicio);
    }
    String tiempoTotal = '00:00';
    //*SUMA DE LOS TIEMPOS DE LOS SERVICIOS
    for (var element in servicios) {
      tiempoTotal = suma(tiempoTotal, element.tiempo.toString());
    }

    // duracion total de los servicios
    String duracion = formatearHora(tiempoTotal);

    try {
      //******************************************('AGREGA LA CITA AL CLIENTE')****************
      await FirebaseProvider().creaNuevacitaAdministracionCliente(
        negocio,
        citaElegida.horaInicio,
        fechaFormateada,
        horaFormateada,
        duracion,
        servicios,
        citaElegida.emailCliente!,
        idCitaCliente,
        precioTexto,
      );
    } catch (e) {
      // print('ERROR');
    }

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
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    final citaElegida = contextoCreacionCita.contextoCita;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: appBarCreacionCita(
          '✔️ Cita confirmada',
          false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            BarraProgreso().progreso(
              context,
              1.0,
              const Color.fromARGB(255, 51, 156, 24),
            ),
            const SizedBox(
              height: 20,
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
                            /* Text(
                              'Reservado $servicioTexto con $clientaTexto para el día $fechaTexto h',
                              style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ), */
                            const Divider(),
                            CompartirCitaConCliente(
                                cliente: clientaTexto,
                                telefono: telefono,
                                email: email,
                                fechaCita: citaElegida.horaInicio.toString(),
                                servicio: servicioTexto,
                                precio: precioTexto),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/');
                                  liberarMemoriaEditingController();
                                },
                                icon: const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Color.fromARGB(167, 224, 231, 235),
                                ),
                                label: const Text('ACEPTAR')),
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
    CitaModelFirebase citaElegida,
    String fecha,
    /* String horaInicio,
      String horaFinal,
      String comentario,
      var idCliente, */
    List<String> idServicios,
    /* String nombreCliente,
      String telefonoCliente, */
    String nombreServicio,
    String precio,
  ) async {
    String title = 'Tienes cita $fechaTexto-$horaIniciotexto h';
    String body =
        '${citaElegida.nombreCliente} se va a hacer $nombreServicio ¡ganarás $precio ! 🤑';
    debugPrint('hora recordatorio $horaRecordatorio');
    debugPrint('hora actual ${DateTime.now().toString()}');

    int idCita = 0;
    if (_iniciadaSesionUsuario) {
      List<Map<String, dynamic>> servicios =
          contextoCreacionCita.getServiciosElegidos;

      List<String> idServicios = servicios.map((ser) {
        return ser['ID'].toString();
      }).toList();

      //###### CREA CITA Y TRAE ID CITA CREADA EN FIREBASE PARA ID DEL RECORDATORIO
      idCita = await FirebaseProvider()
          .nuevaCita(_emailSesionUsuario, citaElegida, idServicios);

      //###### CREA RECORDATORIO EN FIREBASE //######//######//######//######
      await FirebaseProvider().creaRecordatorio(
          _emailSesionUsuario,
          fecha,
          citaElegida.horaInicio.toString(),
          precio,
          citaElegida.comentario!,
          citaElegida.nombreCliente!,
          citaElegida.telefonoCliente!,
          email,
          idServicios,
          citaElegida.idEmpleado!);
    } else {
      /*   print('id servicio sin sesion ***********************************');
      print(idServicio); */
      //###### CREA CITA Y TRAE ID CITA CREADA EN DISPOSITIVO PARA ID DEL RECORDATORIO
      /*  idCita = await citaElegida.nuevaCita(
        fecha,
        horaInicio,
        horaFinal,
        comentario,
        idCliente,
        idServicio
            .first, //todo: solo visible el primer servicio de los que se reserve
      ); */
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
        debugPrint(e.toString());

        // Mostrar el diálogo al hacer clic en el botón
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const BackgroundPermissionDialog();
          },
        );
        mensajeInfo(context, 'No recordaremos esta cita');
      }
      // }
    }
  }

  void _mensajeActivarSegundoPlano() {}
}

class BackgroundPermissionDialog extends StatelessWidget {
  const BackgroundPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Habilitar ejecución en segundo plano'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Para proporcionar la mejor experiencia de usuario, la aplicación necesita ejecutarse en segundo plano para realizar ciertas tareas, como enviar notificaciones importantes o actualizar datos automáticamente.',
          ),
          SizedBox(height: 10),
          Text(
            'AJUSTE-BATERIA-USO DE BATERIA POR APLICACION-AGENDA DE CITAS-PERMITIR ACTIVIDAD EN SEGUNDO PLANO.',
          ),
          SizedBox(height: 10),
          Text(
            'Siempre puedes cambiar esta configuración más tarde en la sección de ajustes de la aplicación.',
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
