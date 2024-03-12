import 'package:agendacitas/screens/comprar_aplicacion.dart';
import 'package:agendacitas/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class FinalizacionPrueba extends StatefulWidget {
  final String? usuarioAPP;
  const FinalizacionPrueba({Key? key, this.usuarioAPP = ''}) : super(key: key);

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.usuarioAPP.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '😔 ¡El periodo de prueba ha finalizado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿Quieres continuar disfrutando de todas las funcionalidades de la app?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // GUARDA EN EL PROVIDER Y LIMPIA VARIABLES PARA QUE SE PUEDA INICIAR SESION CON OTRO EMAIL

                    await PagoProvider().guardaPagado(false, '');
                    await FirebaseAuth.instance.signOut();
                    estadoPagoProvider.estadoPagoEmailApp('');
                   
                    _irPaginaInicio();
                  },
                  child: const Text(
                    'No, continuar con la opción gratuita',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'o',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '💳 ¡Mejora tu experiencia con la opción de pago! 💳\n¡Un solo pago sin suscripción para acceder a todas las funcionalidades de la app!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // GUARDA EN EL PROVIDER Y LIMPIA VARIABLES PARA QUE SE PUEDA INICIAR SESION CON OTRO EMAIL
                    await PagoProvider().guardaPagado(false, '');
                    // await FirebaseAuth.instance.signOut();

                    _irPaginaCompra();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Cambia el color de fondo del botón
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Sí, continuar con todas las opciones, manteniendo la publicación en la web',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
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

  _irPaginaInicio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(
                index: 0,
                myBnB: 0,
              )),
    );
  }
}
