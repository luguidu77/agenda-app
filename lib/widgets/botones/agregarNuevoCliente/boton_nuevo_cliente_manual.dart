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
        child: const BotonAgrega(
          texto: 'NUEVO',
        ));
  }
}
