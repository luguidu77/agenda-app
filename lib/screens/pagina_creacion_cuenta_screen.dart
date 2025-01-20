import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:agendacitas/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rive/rive.dart';

import '../providers/providers.dart';

class PaginaIconoAnimado extends StatefulWidget {
  const PaginaIconoAnimado(
      {super.key, required this.email, required this.password});
  final String email;
  final String password;
  @override
  State<PaginaIconoAnimado> createState() => _PaginaIconoAnimadoState();
}

class _PaginaIconoAnimadoState extends State<PaginaIconoAnimado> {
  bool cuentaCreada = false;

  void creaCuentaUsuario() async {
    // EL RESULTADO DE CREACION DE CUENTA ES CORRECTA
    debugPrint('CREANDO NUEVA CUENTA');

    //await PagoProvider().guardaPagado(false, widget.email.toString());
    await configuracionInfoPagoRespaldo(widget.email);

    context.read<CuentaNuevaProvider>().setCuentaNueva(true);
    // CREA EN FIREBASE UNA CUENTA NUEVA

    final res =
        await creaCuentaUsuarioApp(context, widget.email, widget.password);
    setState(() => cuentaCreada = true);
  }

  @override
  void initState() {
    super.initState();
    creaCuentaUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Center(
              child: !cuentaCreada
                  ? const IconoAnimado()
                  : const ExitoCreacionCuenta(),
            ),
          )),
    );
  }

//METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  configuracionInfoPagoRespaldo(email) async {
    try {
      //GUARDA PAGO EN DISPOSITIVO
      //  await PagoProvider().guardaPagado(true, email);

      // RESPALDO DATOS EN FIREBASE
      await SincronizarFirebase().sincronizaSubeFB(email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class ExitoCreacionCuenta extends StatelessWidget {
  const ExitoCreacionCuenta({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(children: [
        const SizedBox(
          width: 180,
          height: 180,
          child: Image(image: AssetImage('assets/images/cheque.png')),
        ),
        const Text('Cuenta creada con exito'),
        ElevatedButton(
            onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => RegistroUsuarioScreen(
                            registroLogin: 'Login',
                            usuarioAPP: '',
                          )),
                ),
            child: const Text('Accede'))
      ]),
    );
  }
}

class IconoAnimado extends StatelessWidget {
  const IconoAnimado({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: RiveAnimation.asset(
            'assets/icon/iconoapp.riv',
            fit: BoxFit.contain,
          ),
        ),
        Text('creando cuenta...'),
      ],
    );
  }
}
 /* ? const RiveAnimation.asset(
                'assets/icon/iconoapp.riv',
              ) */