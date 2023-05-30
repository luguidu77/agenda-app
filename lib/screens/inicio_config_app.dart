import 'package:agendacitas/providers/estado_pago_app_provider.dart';
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
  inicializaProviderEstadoPagoEmail() async {}

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isEmpty) {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
    }
  }

  getDisponibilidadSemanal(emailSesionUsuario) async {
    final disponibilidadSemanalProvider = await SincronizarFirebase()
        .getDisponibilidadSemanal(emailSesionUsuario);

    return disponibilidadSemanalProvider;
  }

  @override
  void initState() {
    getPersonaliza();
    //inicializaProviderEstadoPagoEmail();

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

            //DISPONIBILIDAD SEMANAL
             DisponibilidadSemanal.disponibilidadSemanal(
                context, data.email.toString());

            // LOGEADO EN FIREBASE
            debugPrint(
                'inicio_config_app.dart ----------------> LOGEADO EN FIREBASE');

            return const HomeScreen();
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
