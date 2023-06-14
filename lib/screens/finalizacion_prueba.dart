import 'package:agendacitas/screens/comprar_aplicacion.dart';

import 'package:flutter/material.dart';

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
                  onPressed: () => {
                        //FirebaseAuth.instance.signOut()
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ComprarAplicacion(
                                  // usuarioAPP: email,
                                  )),
                        )
                      },
                  child: const Text('ok'))
            ],
          ),
        ),
      ),
    );
  }
}
