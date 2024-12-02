import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/widgets/botones/agregarNuevoCliente/boton_nuevo_cliente_manual.dart';
import 'package:agendacitas/widgets/lista_de_clientes.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../mylogic_formularios/my_logic_cita.dart';
import '../providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import '../widgets/botones/agregarNuevoCliente/boton_nuevo_desde_contactos.dart';
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

  //CONTACTOS DEL TELEFONO
  final Iterable<Contact> _contacts = [];

  late MyLogicCliente myLogic;

  List<int> numCitas = [];
  TextEditingController busquedaController = TextEditingController();
  //String usuarioAPP = '';
  List<ClienteModel> listaClientes = [];
  List<ClienteModel> listaAux = [];
  List<ClienteModel> aux = [];
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  late int codPais;

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
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BotonNuevoClienteManual(),
                  BotonNuevoDesdeContacto(pantalla: 'cliente_screen')
                ],
              ),
            ),
            const Divider(),
            ListaClientes(
                fecha: DateTime.now(), // cualquier DateTime
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
