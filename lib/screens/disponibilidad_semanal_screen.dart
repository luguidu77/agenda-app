import 'package:flutter/material.dart';

import 'config/config_disponibilidad.dart';

class DisponibilidadSemanalScreen extends StatefulWidget {
  const DisponibilidadSemanalScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DisponibilidadSemanalScreen> createState() =>
      _DisponibilidadSemanalScreenState();
}

class _DisponibilidadSemanalScreenState
    extends State<DisponibilidadSemanalScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _botonCerrar(),
          const ConfigDisponibilidad(),
        ],
      ),
    )));
  }

  _botonCerrar() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', ModalRoute.withName('/'));
              },
              icon: const Icon(
                Icons.close,
                size: 50,
                color: Color.fromARGB(167, 114, 136, 150),
              )),
        ],
      ),
    );
  }
}
