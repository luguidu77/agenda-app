import 'package:agendacitas/config/config_perfil_usuario.dart';
import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/inicio_sesion_forzada.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  bool haySesionIniciada = true;
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
    /*   bool inicioSesionForzada =
        context.read<InicioSesionForzada>().esInicioSesionForzada;
    //  print('estoy forzando el inicio de sesion $inicioSesionForzada');
    // Actualiza la pantalla si hay un cambio en la sesión: haySesionIniciada fuerzo el inicio de la aplicación
    if (inicioSesionForzada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // forceUpdate();
      });
    } */
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

            if (!contextoCitas.citasCargadas) {
              // Ejecuta _config después del frame actual para evitar llamar a setState durante build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // ############### SETEA LOS PROVIDER
                // EMAIL DEL USUARIO QUE INICIA SESION
                // TRAE LOS EMPLEADOS Y LOS SETEA EN EL PROVIDER
                _config(context, data.email!);
              });

              return Center(
                child: Image.asset(
                  'assets/images/cargandoAgenda.gif', // Ruta del GIF
                  width: 100,
                  height: 100,
                ),
              );
            }

            haySesionIniciada = false;
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
    /*  final contextoCitas = context.read<CitasProvider>();
    final empleadosProvider = context.read<EmpleadosProvider>(); */

    // ############### SETEA LOS PROVIDER
    // ############### set roles de usuario
    if (mounted) {
      final contextoRol = context.read<RolUsuarioProvider>();

      contextoRol.setRol(rolEmpleado);
    }

    // ESTADO DE PAGO EMAIL USUARIO DE LA APLICACION
    final emailUsuarioAppProvider = context.read<EmailUsuarioAppProvider>();
    emailUsuarioAppProvider.setEmailUsuarioApp(emailSesionUsuario);

    // ESTADO DE PAGO EMAIL ADMINISTRADOR
    final estadoProvider = context.read<EstadoPagoAppProvider>();
    estadoProvider.estadoPagoEmailApp(emailAdministrador);
    // setea el email del administrador de la empresa
    final contextoPago = context.read<EmailAdministradorAppProvider>();
    contextoPago.setEmailAdministradorApp(emailAdministrador);

    // ###############  PERSONALIZA

    FirebaseProvider().cargarPersonaliza(context, emailAdministrador);

    // ###############  DISPONIBILIDAD SEMANAL APERTURAS DEL NEGOCIO
    final dDispoSemanal = context.read<DispoSemanalProvider>();

    DisponibilidadSemanal.disponibilidadSemanal(
        dDispoSemanal, emailAdministrador);

    await getTodasLasCitas(emailAdministrador);

    await empleados(emailAdministrador);
  }

  Future<void> getTodasLasCitas(String emailSesionUsuario) async {
    // Comprueba que el widget sigue montado antes de hacer la primera lectura.
    if (!mounted) return;

    // Se obtienen las referencias de los providers inmediatamente
    final contextoCitas = context.read<CitasProvider>();
    final contextoServiciosOfrecidos =
        context.read<ServiciosOfrecidosProvider>();
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    final estadoProvider = context.read<EmailAdministradorAppProvider>();
    String emailAdministrador = estadoProvider.emailAdministradorApp;

    // Verifica si las citas ya están cargadas
    if (!contextoCitas.citasCargadas /* && contextoCitas.getCitas.isEmpty */) {
      try {
        List<CitaModelFirebase> citas = [];
        citas = await FirebaseProvider().getTodasLasCitas(emailAdministrador);
        //TODO  por aqui estoy trabajando la carga de las citas ·····································
        /*  // Carga las citas
        if (contextoCitas.getCitas.isEmpty) {
          citas = await FirebaseProvider().getTodasLasCitas(emailAdministrador);
        } else {
          citas = contextoCitas.getCitas;
        } */

        // Antes de usar el context, vuelve a verificar que el widget esté montado
        if (!mounted) return;
        contextoCitas.setTodosLasLasCitas(citas);

        // Carga los servicios ofrecidos
        List<ServicioModelFB> todosLosServicios =
            await FirebaseProvider().cargarServicios(emailAdministrador);

        if (!mounted) return;
        contextoServiciosOfrecidos.setTodosLosServicios(todosLosServicios);

        // Restablece el contexto para la creación de citas
        CitaModelFirebase edicionContextoCita =
            CitaModelFirebase(idEmpleado: 'TODOS_EMPLEADOS');
        contextoCreacionCita.setContextoCita(edicionContextoCita);

        // Actualiza la reasignación de citas si es necesario
        if (citas.any((cita) => cita.idEmpleado == '55')) {
          if (!mounted) return;
          context.read<ComprobacionReasignacionCitas>().setReasignado(false);
        }

        print(
            'Citas cargadas y añadidas al contexto ${contextoCitas.citasCargadas}');
      } catch (e) {
        // Manejo de errores, si es necesario
        print('Error al cargar citas: $e');
      }
    } else {
      /*     contextoCitas.reasignacionCita();
      setState(() {}); */
      print('Las citas ya están cargadas, no se vuelve a cargar.');
    }
  }

  Future<(RolEmpleado rol, String? emailAdministrador)> _compruebaRolUsuario(
    String emailSesionUsuario,
  ) async {
    final datosUsuario = await FirebaseProvider()
        .compruebaRolEmpleadoIniciandoSesion(emailSesionUsuario);
    print(datosUsuario);

    // si datosUsuario es null
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
        mensajeDialogo('Debes veficar tu cuenta para continuar.');
        FirebaseAuth.instance.signOut();

        return (RolEmpleado.personal, emailAdministrador);
      } else {
        print("Usuario verificado.");
        return (RolEmpleado.personal, emailAdministrador);
      }
    }
  }

  void mensajeDialogo(texto) {
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
              texto,
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
                  /*  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConfigPerfilUsuario(), // Pantalla de configuración
                    ),
                  ); */
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

  void _config(BuildContext context, String email) async {
    RolEmpleado rolusuario;
    final contextoRol = context.read<RolUsuarioProvider>();
    final contextEmailAdmin = context.read<EmailAdministradorAppProvider>();
    rolusuario = contextoRol.rol;
    String emailUsuario = '';
    String emailAdmin = '';

    emailUsuario = email;
    emailAdmin = contextEmailAdmin.emailAdministradorApp;

    if (contextoRol.rol == RolEmpleado.desconocido) {
      final (rol, emailAdministrador) = await _compruebaRolUsuario(email);
      rolusuario = rol; // PUEDE ELIMINARSE
      emailAdmin = emailAdministrador ?? '';

      print(
          ' SE COMPRUEBA EL ROL DE USUAIO  --------- y SETEO EL CONTEXTO----------------------------------------------------------- ');
    }

    /*  final rol = RolEmpleado.administrador;
    final emailAdministrador = 'ritagiove@hotmail.com';
 */
    print(
        ' $rolusuario -------------------------------------------------------------------- ');
    _configuraApp(
      context,
      emailUsuario,
      rolusuario,
      emailAdmin,
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

      final EmpleadoModel usuarioapp = empleadosProvider.getEmpleados
          .firstWhere((element) => element.email == element.emailUsuarioApp);
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('nombreUsuarioApp', usuarioapp.nombre);
      });
      debugPrint('empleados cargados y añadidas al contexto');
    } else {
      debugPrint('los empleados ya están cargadas, no se vuelve a cargar.');
    }
  }

  Future<void> forceUpdate() async {
    haySesionIniciada = true;
    setState(() {});
    print(
        '###########################forceUpdate  ######################################### forceUpdate #############################################################');
    // context.read<InicioSesionForzada>().setFuerzaInicio(false);
    FirebaseAuth.instance.currentUser!.reload();
  }
}
