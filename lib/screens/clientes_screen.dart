import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/screens/nuevo_actualizacion_cliente.dart';
import 'package:agendacitas/widgets/botones/floating_action_buton_widget.dart';
import 'package:agendacitas/widgets/lista_de_clientes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import '../widgets/boton_agrega_cliente.dart';
import '../widgets/formulario_busqueda.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    emailUsuario();

    super.initState();
  }

  List<int> numCitas = [];
  TextEditingController busquedaController = TextEditingController();
  //String usuarioAPP = '';
  List<ClienteModel> listaClientes = [];
  List<ClienteModel> listaAux = [];
  List<ClienteModel> aux = [];
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  void mensajeCreacionCliente() {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: 'Se ha creado una clienta de ejemplo con exito',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LEE FORMULARIO DE BUSQUEDA
    final contextoFormularioBusqueda = context.watch<FormularioBusqueda>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CuadroBusqueda(),
            GestureDetector(
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
                child: const BotonAgregaCliente()),
            const Divider(),
            ListaClientes(
                fecha: '',
                iniciadaSesionUsuario: _iniciadaSesionUsuario,
                emailSesionUsuario: _emailSesionUsuario,
                busquedaController: contextoFormularioBusqueda.textoBusqueda,
                pantalla: 'cliente_screen')
          ],
        ),
      ),
    );
  }
}
