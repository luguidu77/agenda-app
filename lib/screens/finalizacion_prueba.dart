import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FinalizacionPrueba extends StatefulWidget {
  const FinalizacionPrueba({Key? key}) : super(key: key);

  @override
  State<FinalizacionPrueba> createState() => _FinalizacionPruebaState();
}

class _FinalizacionPruebaState extends State<FinalizacionPrueba> {
  String email = 'fdfd';
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> parametros =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(parametros['usuarioAPP'].toString()),
              const Text('El periodo de prueba a finalizado'),
              ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text('ok'))
            ],
          ),
        ),
      ),
    );
  }
}
