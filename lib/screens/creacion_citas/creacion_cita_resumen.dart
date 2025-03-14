// ignore_for_file: file_names

import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/genera_id_cita_recordatorio.dart';
import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:agendacitas/utils/comunicacion/comunicaciones.dart';
import 'package:agendacitas/utils/notificaciones/recordatorio_local/recordatorio_local.dart';
import 'package:agendacitas/widgets/compartirCliente/compartir_cita_a_cliente.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import 'provider/creacion_cita_provider.dart';
import 'utils/id_cita_cliente_random.dart';

//import 'package:url_launcher/url_launcher_string.dart';

//import 'package:sms_advanced/sms_advanced.dart';

class ConfirmarStep extends StatefulWidget {
  const ConfirmarStep({Key? key}) : super(key: key);

  @override
  State<ConfirmarStep> createState() => _ConfirmarStepState();
}

class _ConfirmarStepState extends State<ConfirmarStep> {
  // Proveedores
  late CreacionCitaProvider _citaProvider;

  // Variables de usuario y sesión
  String _emailSesionUsuario = '';

  // Datos de la cita
  String _clienteNombre = '';
  String _telefono = '';
  String _email = '';
  String _servicioTexto = '';
  String _precioTexto = '';
  String _fechaTexto = '';
  String _fechaMesEspa = '';
  String _horaInicioTexto = '';
  String _horaFinalTexto = '';
  String _horaRecordatorio = '';

  // Identificadores
  String _citaConfirmadaMes = '';
  String _citaConfirmadaDia = '';

  // Estilos de texto
  final _estiloTextoTitulo =
      const TextStyle(fontSize: 28, color: Colors.blueGrey);
  final _estiloTexto = const TextStyle(
      fontSize: 19, color: Colors.blueGrey, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  // Método para inicializar datos
  void _cargarDatosIniciales() async {
    await _obtenerEmailUsuario();

    // Ejecutar después de que se renderice la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Vista cargada completamente");
      _procesarCita();
    });
  }

  // Obtener email del usuario
  Future<void> _obtenerEmailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  // Obtener tiempo de recordatorio configurado
  String _obtenerTiempoRecordatorio() {
    final personalizaProvider = context.read<PersonalizaProviderFirebase>();
    final personaliza = personalizaProvider.getPersonaliza;
    return personaliza.tiempoRecordatorio!;
  }

  // Calcular suma de precios de servicios
  double _sumarPrecios(List<Map<String, dynamic>> listaServicios) {
    double suma = 0.0;
    for (var servicio in listaServicios) {
      suma += double.parse(servicio['PRECIO']!);
    }
    return suma;
  }

  // PROCESAMIENTO PRINCIPAL DE LA CITA
  Future<void> _procesarCita() async {
    _citaProvider = context.read<CreacionCitaProvider>();
    debugPrint('Cita elegida: ${_citaProvider.contextoCita.toString()}');

    // 1. Generar ID único para la cita y ID único para el recordatorio
    String idCitaCliente = await generarCadenaAleatoria(20);
    int idRecordatorioLocal = await UtilsRecordatorios.idRecordatorio(
        _citaProvider.contextoCita.horaInicio!);
    CitaModelFirebase citaElegida = _citaProvider.contextoCita;

    // 2. Guardar información del cliente y email del usuario de la app
    _clienteNombre = citaElegida.nombreCliente!;
    _telefono = citaElegida.telefonoCliente!;
    _email = citaElegida.emailCliente!;
    citaElegida.email = _emailSesionUsuario;
    // actualiza cita con idCitaCliente y idRecordatorioLocal
    citaElegida.idCitaCliente = idCitaCliente;
    citaElegida.idRecordatorioLocal = idRecordatorioLocal;

    // 3. Actualizar el ID cita e ID recordatorio local en el contexto
    CitaModelFirebase edicionCita = CitaModelFirebase(
        idCitaCliente: idCitaCliente, idRecordatorioLocal: idRecordatorioLocal);
    _citaProvider.setContextoCita(edicionCita);

    // 4. Obtener servicios y calcular precio total
    List<Map<String, dynamic>> listaServicios =
        _citaProvider.getServiciosElegidos;
    double precioTotal = _sumarPrecios(listaServicios);

    // 5. Calcular hora de recordatorio
    await _calcularHoraRecordatorio(citaElegida);

    // 6. Formatear fechas y horas para mostrar
    await _formatearDatosFechaHora(citaElegida);

    // 7. Guardar datos para mostrar en UI
    _servicioTexto = listaServicios.first['SERVICIO'];
    _precioTexto = precioTotal.toString();

    // 8. Generar fecha formateada para guardar
    DateTime dateTime = citaElegida.horaInicio!;
    String fechaYMD =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

    // 9. Grabar cita en la base de datos
    await _grabarCitaCompleta(
      citaElegida: citaElegida,
      fecha: _fechaTexto,
      horaInicio: _horaInicioTexto,
      fechaYMD: fechaYMD,
      idServicios: listaServicios.map((e) => e['ID'].toString()).toList(),
      nombreServicio: _servicioTexto,
      precio: _precioTexto,
      idCitaCliente: idCitaCliente,
    );

    // 10. Actualizar la interfaz
    setState(() {});
  }

  // Calcular la hora de recordatorio basada en la configuración
  Future<void> _calcularHoraRecordatorio(CitaModelFirebase citaElegida) async {
    String tiempoTextoRecord = _obtenerTiempoRecordatorio();
    DateTime cita = citaElegida.horaInicio!;

    if (tiempoTextoRecord.isEmpty) return;

    // Si tiempo a restar es '24:00', resto un día
    if (tiempoTextoRecord[0] == '2') {
      _horaRecordatorio = cita.subtract(const Duration(days: 1)).toString();
    } else {
      String tiempoAux =
          '${cita.year}-${cita.month.toString().padLeft(2, '0')}-${cita.day.toString().padLeft(2, '0')} $tiempoTextoRecord';
      DateTime tiempoRecordatorio = DateTime.parse(tiempoAux);

      _horaRecordatorio = cita
          .subtract(Duration(
              hours: tiempoRecordatorio.hour,
              minutes: tiempoRecordatorio.minute))
          .toString();
    }
  }

  // Formatear fecha y hora para mostrar
  Future<void> _formatearDatosFechaHora(CitaModelFirebase citaElegida) async {
    DateTime horaInicio = citaElegida.horaInicio!;
    DateTime horaFinal = citaElegida.horaFinal!;

    // Formato corto (DD/MM)
    String fechaCorta =
        '${horaInicio.day.toString().padLeft(2, '0')}/${horaInicio.month.toString().padLeft(2, '0')}';

    // Formato hora (HH:MM)
    _horaInicioTexto =
        '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
    _horaFinalTexto =
        '${horaFinal.hour.toString().padLeft(2, '0')}:${horaFinal.minute.toString().padLeft(2, '0')}';

    // Formato largo en español
    final String fechaLargaEspa =
        DateFormat.MMMMEEEEd('es_ES').add_jm().format(horaInicio);
    _fechaTexto = fechaLargaEspa;

    // Mes en español abreviado
    _fechaMesEspa = DateFormat.MMM('es_ES').format(horaInicio);

    // Datos para mostrar día y mes
    _citaConfirmadaMes = horaInicio.month.toString().padLeft(2, '0');
    _citaConfirmadaDia = horaInicio.day.toString().padLeft(2, '0');
  }

  // GUARDAR CITA EN FIREBASE Y CREAR RECORDATORIO
  Future<void> _grabarCitaCompleta({
    required CitaModelFirebase citaElegida,
    required String fecha,
    required String horaInicio,
    required String fechaYMD,
    required List<String> idServicios,
    required String nombreServicio,
    required String precio,
    required String idCitaCliente,
  }) async {
    //  Obtener texto para notificaciones
    final dataNotificacion =
        await Comunicaciones().textoNotificacionesLocales(context, citaElegida);

    // 1. Crear cita en Firebase
    await _crearCitaEnFirebase(
      citaElegida,
    );

    // 2. Crear recordatorio en Firebase

    await CrearRecordatorio.crearRecordatorioLocalyEnFirebase(
      citaElegida: citaElegida,
      fecha: fechaYMD,
      precio: precio,
      idServicios: idServicios,
      nombreServicio: nombreServicio,
      dataNotificacion: dataNotificacion,
      horaRecordatorio: _horaRecordatorio,
    );
  }

  // Crear cita en Firebase
  Future<void> _crearCitaEnFirebase(CitaModelFirebase citaElegida) async {
    final contextCitas = context.read<CitasProvider>();
    final contextNuevaCita = context.read<CreacionCitaProvider>();

    // Obtener servicios del contexto
    List<Map<String, dynamic>> servicios = _citaProvider.getServiciosElegidos;
    List<String> idServicios =
        servicios.map((ser) => ser['ID'].toString()).toList();

    // Guardar cita en Firebase
    String idCitaFB = await FirebaseProvider()
        .nuevaCita(_emailSesionUsuario, citaElegida, idServicios);

    // Actualizar contexto con ID de Firebase
    contextNuevaCita.contextoCita.id = idCitaFB;
    contextNuevaCita.contextoCita.idservicio = idServicios;
    contextNuevaCita.contextoCita.confirmada = true;

    // Agregar cita al contexto general
    contextCitas.agregaCitaAlContexto(contextNuevaCita.contextoCita);
    debugPrint('Cita agregada al contexto');
  }

  // Crear recordatorio en Firebase y notificación local
  /*  Future<void> _crearRecordatorioLocalyEnFirebase({
    required CitaModelFirebase citaElegida,
    required String fecha,
    required String precio,
    required List<String> idServicios,
    required String horaInicio,
    required String nombreServicio,
  }) async {
    // 1. Obtener texto para notificaciones
    final dataNotificacion =
        await Comunicaciones().textoNotificacionesLocales(context, citaElegida);

    // 2. Guardar recordatorio en Firebase
    await FirebaseProvider().creaRecordatorio(
        _emailSesionUsuario, fecha, citaElegida, precio, idServicios);

    // 3. Verificar si la fecha es posterior a la actual
    DateTime diaRecord = DateTime.parse(_horaRecordatorio);
    DateTime ahora = DateTime.now().subtract(const Duration(minutes: 1));

    if (diaRecord.isAfter(ahora)) {
      debugPrint('---------GUARDA RECORDATORIO-------');
      try {
        // 4. Crear notificación local
        await NotificationService().notificacion(
            dataNotificacion.idRecordatorioCita,
            dataNotificacion.title,
            dataNotificacion.body,
            'citapayload',
            _horaRecordatorio);
      } catch (e) {
        debugPrint('Error de notificación local: $e');
        // 5. Mostrar diálogo para permisos de segundo plano
        _mostrarDialogoPermisosSegundoPlano();
      }
    }
  } */

  // Liberar recursos de controladores
  void _liberarMemoriaEditingController() {
    final cliente = ClienteModel();
    final servicio = ServicioModel();
    final cita = CitaModel();

    MyLogicCliente(cliente).dispose();
    MyLogicServicio(servicio).dispose();
    MyLogicCita(cita).dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citaElegida = context.read<CreacionCitaProvider>().contextoCita;

    return PopScope(
      canPop: false, // No permite salir de la página al ir atrás
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildConfirmationSection(citaElegida: citaElegida),
              const SizedBox(height: 20),
              _buildFooterButton(),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS DE LA INTERFAZ

  // Sección de confirmación de cita
  Widget _buildConfirmationSection({required CitaModelFirebase citaElegida}) {
    return Expanded(
      child: _servicioTexto.isEmpty
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

  // Imagen de confirmación
  Widget _buildConfirmationImage() {
    return Column(
      children: [
        SizedBox(
          width: 100,
          child: Image.asset('./assets/images/cheque.png'),
        ),
        const SizedBox(height: 15),
        const Text(
          'Reserva confirmada',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Detalles para compartir la cita
  Widget _buildSharingDetails(CitaModelFirebase citaElegida) {
    String formattedDate =
        DateFormat('dd-MM-yyyy HH:mm').format(citaElegida.horaInicio!);

    return Column(
      spacing: 25,
      children: [
        const Divider(),
        Text(
          'Comparte la cita con $_clienteNombre\n\nCita: $formattedDate', //El formato 'HH' representa las horas en un ciclo de 24 horas
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        CompartirCitaConCliente(
          cliente: _clienteNombre,
          telefono: _telefono,
          email: _email,
          fechaCita: citaElegida.horaInicio.toString(),
          servicio: _servicioTexto,
          precio: _precioTexto,
        ),
      ],
    );
  }

  // Botón de cierre en el pie de página
  Widget _buildFooterButton() {
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
          Navigator.push(context, _createRoute());
          _liberarMemoriaEditingController();
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

  // Transición de página personalizada
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
}

// Diálogo para permisos de segundo plano
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
            abrirConfiguracionBateria();
          },
          child: const Text("Abrir configuración"),
        ),
      ],
    );
  }

  void abrirConfiguracionBateria() async {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.settings.ACTION_POWER_USAGE_SUMMARY',
    );

    try {
      await intent.launch();
    } catch (e) {
      print("Error al abrir uso de batería: $e");
      // Fallback: Abrir ajustes generales de la app
      AppSettings.openAppSettings();
    }
  }
}
