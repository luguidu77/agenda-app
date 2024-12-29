import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
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
  /* inicializaProviderEstadoPagoEmail() {

    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
     final emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    if (estadoPagoProvider.estadoPagoApp == 'INITIAL' && mounted) {
      Navigator.pushReplacementNamed(context, 'finalizacionPruebaScreen',
          arguments: emailSesionUsuario);
    }
  } */

/*   getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isEmpty) {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
    }
  } */

  getDisponibilidadSemanal(emailSesionUsuario) async {
    final disponibilidadSemanalProvider = await SincronizarFirebase()
        .getDisponibilidadSemanal(emailSesionUsuario);

    return disponibilidadSemanalProvider;
  }

  void getTodasLasCitas(emailSesionUsuario) async {
    final contextoCitas = context.watch<CitasProvider>();
    final contextoCreacionCita = context.read<CreacionCitaProvider>();

    // Verifica si las citas ya están cargadas
    if (!contextoCitas.citasCargadas) {
      // Realizar la operación de carga
      try {
        List<CitaModelFirebase> citas =
            await FirebaseProvider().getTodasLasCitas(emailSesionUsuario);

        // Establecer las citas en el contexto
        contextoCitas.setTodosLasLasCitas(citas);

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

  @override
  void initState() {
    // inicializaProviderEstadoPagoEmail();

    //? no lo inicializo aqui porque primeramente me trael el usuario de la app vacio
    //? tengo un poco de cacao aqui en las inicializaciones de la app

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // LOGEADO EN FIREBASE
            debugPrint(
                'inicio_config_app.dart ----------------> LOGEADO EN FIREBASE');

            final User data = snapshot.data;

            // ############### SETEA LOS PROVIDER
            // EMAIL
            final estadoProvider =
                Provider.of<EstadoPagoAppProvider>(context, listen: false);
            estadoProvider.estadoPagoEmailApp(data.email.toString());

            // ###############  PERSONALIZA
            FirebaseProvider()
                .cargarPersonaliza(context, data.email.toString());

            // ###############  DISPONIBILIDAD SEMANAL
            //invocado DispoSemanalProvider
            //TODO PASAR ESTO AL FIREBASE PROVIDER Y
            final dDispoSemanal = context.read<DispoSemanalProvider>();

            DisponibilidadSemanal.disponibilidadSemanal(
                dDispoSemanal, data.email.toString());

            getTodasLasCitas(data.email.toString());

            return HomeScreen(
              index: 0,
              myBnB: 0,
            );
          } else {
            //quiero limpiar el provider de citas
            final contextoCitas = context.read<CitasProvider>();
            contextoCitas.limpiarCitaContexto();

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
}
