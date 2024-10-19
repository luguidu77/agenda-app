import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
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

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isEmpty) {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
    }
  }

  getPersonalizaFirebase(emailSesionUsuario) async {
    Map<String, dynamic> data = await PersonalizaProviderFirebase()
        .cargarPersonaliza(emailSesionUsuario);

    if (data.isEmpty) {
      await PersonalizaProviderFirebase()
          .nuevoPersonaliza('prueba@a.es', 'texto inicial');
    }
  }

  getDisponibilidadSemanal(emailSesionUsuario) async {
    final disponibilidadSemanalProvider = await SincronizarFirebase()
        .getDisponibilidadSemanal(emailSesionUsuario);

    return disponibilidadSemanalProvider;
  }

  @override
  void initState() {
    // inicializaProviderEstadoPagoEmail();
    // getPersonaliza();
    //? no lo inicializo aqui porque primeramente me trael el usuario de la app vacio
    //? tengo un poco de cacao aqui en las inicializaciones de la app
    //getPersonalizaFirebase(widget.usuarioAPP);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final User data = snapshot.data;

            debugPrint(
                'seteando provider email:(inicio_config_app) ${data.email.toString()}');

            // ############### SETEA LOS PROVIDER
            // EMAIL
            final estadoProvider =
                Provider.of<EstadoPagoAppProvider>(context, listen: false);

            estadoProvider.estadoPagoEmailApp(data.email.toString());

            // ###############  DISPONIBILIDAD SEMANAL
            //invocado DispoSemanalProvider
            final dDispoSemanal = context.read<DispoSemanalProvider>();
            DisponibilidadSemanal.disponibilidadSemanal(
                dDispoSemanal, data.email.toString());

            // LOGEADO EN FIREBASE
            debugPrint(
                'inicio_config_app.dart ----------------> LOGEADO EN FIREBASE');

            return HomeScreen(
              index: 0,
              myBnB: 0,
            );
          } else {
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
