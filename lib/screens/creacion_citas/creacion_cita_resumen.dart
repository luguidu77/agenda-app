// ignore_for_file: file_names

import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/inicio_sesion_forzada.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/utils/actualizacion_cita.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:agendacitas/utils/notificaciones/recordatorio_local/recordatorio_local.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import '../../utils/formatear.dart';
import '../../widgets/widgets.dart';
import 'provider/creacion_cita_provider.dart';
import 'utils/adaptacion_perfilmodel_negociomodel.dart';
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
  late EmpleadosProvider contextoEmpleado;

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

  String tiempo() {
    final personalizaProvier = context.read<PersonalizaProviderFirebase>();
    final personaliza = personalizaProvier.getPersonaliza;
    return personaliza.tiempoRecordatorio!;
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
    // tiempo recordatorio
    String tiempoTextoRecord = tiempo();

    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    debugPrint('cita elegida ${contextoCreacionCita.contextoCita.toString()}');

    /*  // LEER EL idEmpleado , EMPLEADO SELECCIONADO
    String idEmpleado = contextoCreacionCita.contextoCita.idEmpleado!;
    EmpleadoModel empleado = await FirebaseProvider()
        .getEmpleadoporId(_emailSesionUsuario, idEmpleado); */

    // GENERO UN ID PARA LA CITA(idCitaCliente); // Ejemplo: b7gjR3jNuMRomunRo6SJ
    String idCitaCliente = await generarCadenaAleatoria(20);
    // GUARDA EN EL CONTEXTO DE LA CITA

    CitaModelFirebase citaElegida = contextoCreacionCita.contextoCita;
    clientaTexto = citaElegida.nombreCliente!;
    telefono = citaElegida.telefonoCliente!;
    email = citaElegida.emailCliente!;

    CitaModelFirebase edicionCita =
        CitaModelFirebase(idCitaCliente: idCitaCliente);

    contextoCreacionCita.setContextoCita(edicionCita);

    List<Map<String, dynamic>> listaServicios =
        contextoCreacionCita.getServiciosElegidos;

    DateTime cita = DateTime.parse(
      citaElegida.horaInicio.toString(),
    );

    if (tiempoTextoRecord != '') {
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
        precioTexto,
        idCitaCliente);

    //* CLIENTE : comprobar si el cliente tiene cuenta en la web para agregarle la cita

    //? PERFIL DEL NEGOCIO (USUARIOAPP)
    final perfilNegocio =
        await FirebaseProvider().cargarPerfilFB(_emailSesionUsuario);
    //? PASO DE PERFILMODEL A NEGOCIOMODEL
    NegocioModel negocio = adaptacionPerfilNegocio(perfilNegocio);

    // Formatear la fecha al formato deseado
    Map<String, dynamic> resultado =
        FormatearFechaHora.formatearFechaYHora(citaElegida.horaInicio!);

    String fechaFormateada = resultado['fechaFormateada'];
    String horaFormateada = resultado['horaFormateada'];

    //* todos  LOS SERVICIOS
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
    String duracion = FormatearFechaHora.formatearHora2(tiempoTotal);

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

    //******************************************('AGREGA LA CITA AL PROVIDER')****************

    await ActualizacionCita.agregar(context, citaElegida);

    // limpia la lista de servicios
    // listaServicios.clear();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Código que se ejecuta después de que la vista se haya cargado.
      print("addPostFrameCallback: Vista cargada completamente.");
      guardalacita();
    });
    // compruebaPago();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();
    final citaElegida = contextoCreacionCita.contextoCita;

    return PopScope(
      canPop: false, // no permite salir de la pagina al ir atras
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //_buildProgressIndicator(context),

              _buildConfirmationSection(
                citaElegida: citaElegida,
                context: context,
              ),
              const SizedBox(height: 20),
              _buildFooterButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Barra de progreso
  Widget _buildProgressIndicator(BuildContext context) {
    return BarraProgreso().progreso(
      context,
      1.0,
      const Color.fromARGB(255, 51, 156, 24),
    );
  }

  /// Sección de confirmación de cita
  Widget _buildConfirmationSection({
    required dynamic citaElegida,
    required BuildContext context,
  }) {
    return Expanded(
      child: servicioTexto == ''
          ? const Center(
              child: SizedBox(
                  width: 100, height: 100, child: CircularProgressIndicator()))
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildConfirmationImage(),
                    const SizedBox(height: 15),
                    _buildSharingDetails(citaElegida),
                  ],
                ),
              ),
            ),
    );
  }

  /// Imagen de confirmación
  Column _buildConfirmationImage() {
    return Column(
      children: [
        SizedBox(
          width: 100,
          child: Image.asset('./assets/images/cheque.png'),
        ),
        const SizedBox(height: 15),
        const Text(
          'Reserva confirmada',
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Detalles para compartir la cita con el cliente
  Column _buildSharingDetails(dynamic citaElegida) {
    String formattedDate =
        DateFormat('hh:mm dd-MM-yyyy').format(citaElegida.horaInicio);

    return Column(
      spacing: 10,
      children: [
        Divider(),
        Text(
          'Comparte la cita con ${clientaTexto}\n${formattedDate}',
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        CompartirCitaConCliente(
          cliente: clientaTexto,
          telefono: telefono,
          email: email,
          fechaCita: citaElegida.horaInicio.toString(),
          servicio: servicioTexto,
          precio: precioTexto,
        ),
      ],
    );
  }

  /// Botón de cierre en el pie de página
  Widget _buildFooterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: const Color.fromARGB(255, 51, 156, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          mensajeInfo(context, 'Actualizando agenda...');

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return HomeScreen(
              index: 0,
              myBnB: 0,
            );
          }));

          liberarMemoriaEditingController();
        },
        icon: const Icon(
          Icons.check,
          size: 20,
          color: Colors.white,
        ),
        label: const Text(
          'Cerrar',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
        index: 0,
        myBnB: 0,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Comienza desde la derecha
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
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
    BuildContext context,
    fechaTexto,
    horaIniciotexto,
    CitaModelFirebase citaElegida,
    String fecha,
    List<String> idServicios,
    String nombreServicio,
    String precio,
    String idCitaCliente,
  ) async {
    //###### CREA CITA Y TRAE ID CITA CREADA EN FIREBASE PARA ID DEL RECORDATORIO
    _creaCitaEnFirebase(citaElegida, idCitaCliente);

    //###### CREA RECORDATORIO EN FIREBASE //######//######//######//######
    _creaRecordatorioEnFirebase(
      _emailSesionUsuario,
      fecha,
      citaElegida,
      precio,
      idServicios,
      horaIniciotexto,
      nombreServicio,
    );
  }

  void _mensajeActivarSegundoPlano() {}

  void _creaRecordatorioEnFirebase(
    emailSesionUsuario,
    fecha,
    citaElegida,
    precio,
    idServicios,
    horaIniciotexto,
    nombreServicio,
  ) async {
    String title = 'Tienes cita $fechaTexto-$horaIniciotexto h';
    String body =
        '${citaElegida.nombreCliente} se va a hacer $nombreServicio ¡ganarás $precio ! 🤑';
    debugPrint('hora recordatorio $horaRecordatorio');
    debugPrint('hora actual ${DateTime.now().toString()}');

    int idCita = 0;
    await FirebaseProvider().creaRecordatorio(emailSesionUsuario, fecha,
        citaElegida, precio, idServicios, citaElegida.idEmpleado!);

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

  void _creaCitaEnFirebase(citaElegida, idCitaCliente) async {
    final contextCitas = context.read<CitasProvider>();
    final contextNuevaCita = context.read<CreacionCitaProvider>();
    List<Map<String, dynamic>> servicios =
        contextoCreacionCita.getServiciosElegidos;

    List<String> idServicios = servicios.map((ser) {
      return ser['ID'].toString();
    }).toList();

    String idCitaFB = await FirebaseProvider().nuevaCita(
        _emailSesionUsuario, citaElegida, idServicios, idCitaCliente);

    contextNuevaCita.contextoCita.id = idCitaFB;
    contextNuevaCita.contextoCita.idservicio = idServicios;
    contextNuevaCita.contextoCita.confirmada = true;

    contextCitas.agregaCitaAlContexto(contextNuevaCita.contextoCita);
    print(
        'contexto de las citas ....................................................................');
    print(contextCitas);
  }
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
            '🔋 ¡Permite que la aplicación use batería en segundo plano!\nPara recibir notificaciones y recordatorios a tiempo.\n¡Así la app funcionará sin problemas! 🚀',
          ),
          SizedBox(height: 10),
          Text(
            'ℹ️ INFORMACIÓN DE LA APLICACIÓN\n\n'
            '🔋 Paso 1: Toca "Uso de la batería"\n\n'
            '✅ Paso 2: Selecciona "Permitir actividad en segundo plano"',
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el diálogo antes de abrir ajustes
            //abrirConfiguracionBateria();
          },
          child: const Text("Abrir configuración"),
        ),
      ],
    );
  }

  /* void abrirConfiguracionBateria() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.ACTION_POWER_USAGE_SUMMARY', // Acción correcta
    );

    try {
      await intent.launch();
    } catch (e) {
      print("Error al abrir uso de batería: $e");
      // Fallback: Abrir ajustes generales de la app
      AppSettings.openAppSettings();
    }
  } */
}
