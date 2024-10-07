import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../screens/screens.dart';
import '../boton_agrega.dart';

class BotonNuevoClienteManual extends StatefulWidget {
  const BotonNuevoClienteManual({super.key});

  @override
  State<BotonNuevoClienteManual> createState() =>
      _BotonNuevoClienteManualState();
}

class _BotonNuevoClienteManualState extends State<BotonNuevoClienteManual> {
  late String estadoPago;
  String _emailSesionUsuario = '';
  late bool pagado;
  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    estadoPago = estadoPagoProvider.estadoPagoApp;
    estadoPago != 'GRATUITA' ? pagado = true : pagado = false;
  }

  @override
  void initState() {
    emailUsuario();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return botonNuevoCliente(context);
  }

  GestureDetector botonNuevoCliente(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NuevoActualizacionCliente(
              cliente: ClienteModel(),
              pagado: pagado,
              usuarioAPP: _emailSesionUsuario,
            ),
          ),
        ).then((value) {
          setState(() {});
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue, // Color de fondo
          borderRadius: BorderRadius.circular(30), // Bordes redondeados
          boxShadow: const [
            BoxShadow(
              color: Colors.black26, // Sombra sutil
              blurRadius: 6,
              offset: Offset(0, 2), // Desplazamiento de la sombra
            ),
          ],
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Relleno
        child: const Center(
          child: Text(
            'NUEVO',
            style: const TextStyle(
              color: Colors.white, // Color del texto
              fontSize: 16, // Tamaño del texto
              fontWeight: FontWeight.bold, // Peso del texto
            ),
          ),
        ),
      ),
    );
  }
}
