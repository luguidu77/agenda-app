import 'package:agendacitas/config/config_perfil_usuario.dart';
import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';

class InicioConfigApp extends StatefulWidget {
  final String usuarioAPP;
  const InicioConfigApp({Key? key, required this.usuarioAPP}) : super(key: key);

  @override
  State<InicioConfigApp> createState() => _InicioConfigAppState();
}

class _InicioConfigAppState extends State<InicioConfigApp> {
  bool? creandoCuenta;
  getDisponibilidadSemanal(emailSesionUsuario) async {
    final disponibilidadSemanalProvider = await SincronizarFirebase()
        .getDisponibilidadSemanal(emailSesionUsuario);

    return disponibilidadSemanalProvider;
  }

  @override
  void initState() {
    super.initState();
    creandoCuenta = context.read<CuentaNuevaProvider>().esCuentaNueva;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && !creandoCuenta!) {
            final contextoCitas = context.watch<CitasProvider>();

            // LOGEADO EN FIREBASE
            debugPrint(
                'inicio_config_app.dart ----------------> LOGEADO EN FIREBASE');

            final User data = snapshot.data;

            // ############### SETEA LOS PROVIDER
            // EMAIL DEL USUARIO QUE INICIA SESION
            // TRAE LOS EMPLEADOS Y LOS SETEA EN EL PROVIDER

            _config(data.email!);

            if (!contextoCitas.citasCargadas) {
              return Center(
                child: Image.asset(
                  'assets/images/cargandoAgenda.gif', // Ruta del GIF
                  width: 100,
                  height: 100,
                ),
              );
            }
            return HomeScreen(
              emailUsuario: data.email,
              index: 0,
              myBnB: 0,
            );
          } else {
            //quiero limpiar el provider de citas

            final contextoCitas = context.read<CitasProvider>();

            if (contextoCitas.getCitas.isNotEmpty) {
              contextoCitas.limpiarCitaContexto();
            }

            // NO LOGUEADO EN FIREBASE
            debugPrint(
                'inicio_config_app.dart ----------------> NO LOGUEADO EN FIREBASE');
            return widget.usuarioAPP != ''
                ? RegistroUsuarioScreen(
                    registroLogin: 'Login',
                    usuarioAPP: widget.usuarioAPP,
                  )
                : const Bienvenida();
          }
        },
      ),
    );
  }

  void _configuraApp(
    BuildContext context,
    String emailSesionUsuario,
    RolEmpleado rolEmpleado,
    String emailAdministrador,
  ) async {
    final contextoCitas = context.read<CitasProvider>();
    final empleadosProvider = context.read<EmpleadosProvider>();

    // ############### SETEA LOS PROVIDER

    // ESTADO DE PAGO EMAIL USUARIO DE LA APLICACION
    final emailUsuarioAppProvider = context.read<EmailUsuarioAppProvider>();
    emailUsuarioAppProvider.setEmailUsuarioApp(emailSesionUsuario);

    // ESTADO DE PAGO EMAIL ADMINISTRADOR
    final estadoProvider = context.read<EstadoPagoAppProvider>();
    estadoProvider.estadoPagoEmailApp(emailAdministrador);
    // setea el email del administrador de la empresa
    final contextoPago = context.read<EmailAdministradorAppProvider>();
    contextoPago.setEmailAdministradorApp(emailAdministrador);

    // ############### set roles de usuario
    context.read<RolUsuarioProvider>().setRol(rolEmpleado);

    // ###############  PERSONALIZA
    FirebaseProvider().cargarPersonaliza(context, emailAdministrador);

    // ###############  DISPONIBILIDAD SEMANAL APERTURAS DEL NEGOCIO
    final dDispoSemanal = context.read<DispoSemanalProvider>();

    DisponibilidadSemanal.disponibilidadSemanal(
        dDispoSemanal, emailAdministrador);

    //  final stopwatch = Stopwatch()..start();
    await getTodasLasCitas(emailAdministrador);
    //  stopwatch.stop();
    // final tiempo = stopwatch.elapsed.inSeconds;
    //  print('tiempo de carga de todas las citas...$tiempo');

    //  final stopwatch2 = Stopwatch()..start();
    await empleados(emailAdministrador);
    //  stopwatch2.stop();
    //  final tiempo2 = stopwatch2.elapsed.inSeconds;
    // print('tiempo de carga de todas los empleados...$tiempo2');

    // Marcar las citas como cargadas

    //  mensajeInfo(context, 'tiempo $tiempo + $tiempo2 : ${tiempo + tiempo2}');

    // getTodasLasCitas(emailAdministrador);

    // empleados(emailAdministrador);
  }

  getTodasLasCitas(emailSesionUsuario) async {
    final contextoCitas = context.read<CitasProvider>();
    final contextoServiciosOfrecidos =
        context.read<ServiciosOfrecidosProvider>();
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    final estadoProvider = context.read<EmailAdministradorAppProvider>();
    String emailAdministrador = estadoProvider.emailAdministradorApp;

    // Verifica si las citas ya están cargadas
    if (!contextoCitas.citasCargadas) {
      // Realizar la operación de carga
      try {
        // CARGA EN EL CONTEXTO LAS CITAS ·········································
        List<CitaModelFirebase> citas =
            await FirebaseProvider().getTodasLasCitas(emailAdministrador);
        contextoCitas.setTodosLasLasCitas(citas);
        // CARGA EN EL CONTEXTO LOS SERVICIOS OFRECIDOS ··························

        List<ServicioModelFB> todosLosServicios =
            await FirebaseProvider().cargarServicios(emailAdministrador);
        contextoServiciosOfrecidos.setTodosLosServicios(todosLosServicios);

        // Restablecer el contexto para la creación de citas
        CitaModelFirebase edicionContextoCita =
            CitaModelFirebase(idEmpleado: 'TODOS_EMPLEADOS');

        contextoCreacionCita.setContextoCita(edicionContextoCita);

        // Informar al usuario que las citas deben ser reasignadas (antiguos usuarios app antes de la actualización v10)
        // comprobarcionReasignaciondeCitas contexto
        if (citas.any((cita) => cita.idEmpleado == '55')) {
          context.read<ComprobacionReasignacionCitas>().setReasignado(false);
        }

        print('Citas cargadas y añadidas al contexto');
      } catch (e) {}
    } else {
      print('Las citas ya están cargadas, no se vuelve a cargar.');
    }
  }

  Future<(RolEmpleado rol, String? emailAdministrador)> _compruebaRolUsuario(
    String emailSesionUsuario,
  ) async {
    final datosUsuario = await FirebaseProvider()
        .compruebaRolEmpleadoIniciandoSesion(emailSesionUsuario);
    print(datosUsuario);
    String emailAdministrador = datosUsuario['emailAdministrador'].toString();

    // si el usuario es administrador
    if (datosUsuario['emailUsuario'] == emailAdministrador) {
      print("El usurio es administrador.");
      return (RolEmpleado.administrador, emailAdministrador);

      // si no es administrador
    } else {
      print("usuario encontrado: ${datosUsuario['emailUsuario']}");

      // pregunta si el usuario  está verificado
      if (datosUsuario['cod_verif'] != 'verificado') {
        //mensaje de verificacion, debes de registrar tu cuenta
        mensajeDialogo();

        return (RolEmpleado.personal, emailAdministrador);
      } else {
        print("Usuario verificado.");
        return (RolEmpleado.personal, emailAdministrador);
      }
    }
  }

  void mensajeDialogo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Cuenta no verificada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Debes veficar tu cuenta para continuar.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConfigPerfilUsuario(), // Pantalla de configuración
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue, // color llamativo
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'Aceptar',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _config(String email) async {
    // final stopwatch = Stopwatch()..start();

    final (rol, emailAdministrador) = await _compruebaRolUsuario(email);
    // stopwatch.stop();
    // final tiempo = stopwatch.elapsed.inSeconds;

    // print('tiempo de carga comprobacion del rol...$tiempo');
    // mensajeInfo(context, 'tiempo carga rol $tiempo');
    _configuraApp(
      context,
      email,
      rol,
      emailAdministrador!,
    );
  }

  Future empleados(emailAdministrador) async {
    // TRAE LOS EMPLEADOS Y LOS SETEA EN EL PROVIDER
    final empleadosProvider = context.read<EmpleadosProvider>();

// Verifica si los empleados ya están cargadas
    if (!empleadosProvider.empleadosCargados) {
      print('Cargando empleados por primera vez...');

      await FirebaseProvider()
          .getTodosEmpleados(emailAdministrador)
          .then((empleados) {
        // Establece las citas en el contexto
        empleadosProvider.setTodosLosEmpleados(empleados);
      });

      debugPrint('empleados cargados y añadidas al contexto');
    } else {
      debugPrint('los empleados ya están cargadas, no se vuelve a cargar.');
    }
  }
}
