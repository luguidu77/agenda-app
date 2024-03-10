import 'package:agendacitas/screens/comprar_aplicacion.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

// ignore: must_be_immutable
class FinalizacionPrueba extends StatefulWidget {
  String usuarioAPP;
  FinalizacionPrueba({Key? key, this.usuarioAPP = ''}) : super(key: key);

  @override
  State<FinalizacionPrueba> createState() => _FinalizacionPruebaState();
}

class _FinalizacionPruebaState extends State<FinalizacionPrueba> {
  @override
  Widget build(BuildContext context) {
    // final parametros = ModalRoute.of(context)?.settings.arguments;
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.usuarioAPP.toString()),
              const Text('El periodo de prueba a finalizado'),
              ElevatedButton(
                  onPressed: () async => {
                        // GUARDA EN EL PROVIDER Y LIMPIA VARIABLES PARA QUE SE PUEDA INICIAR SESION CON OTRO EMAIL
                        await PagoProvider().guardaPagado(false, ''),
                        await FirebaseAuth.instance.signOut(),

                        _irPaginaCompra()
                      },
                  child: const Text('ok'))
            ],
          ),
        ),
      ),
    );
  }

  _irPaginaCompra() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const ComprarAplicacion(
              // usuarioAPP: email,
              )),
    );
  }
}
