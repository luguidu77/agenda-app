import 'package:agendacitas/providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/widgets/boton_agrega_cliente.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/models.dart';

import '../../providers/providers.dart';
import '../../widgets/formulario_busqueda.dart';
import '../../widgets/lista_de_clientes.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';
import 'utils/appBar.dart';

class CreacionCitaCliente extends StatefulWidget {
  const CreacionCitaCliente({super.key});

  @override
  State<CreacionCitaCliente> createState() => _CreacionCitaClienteState();
}

class _CreacionCitaClienteState extends State<CreacionCitaCliente> {
  late CreacionCitaProvider contextoCreacionCita;
  final estilo = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  void initState() {
    emailUsuario();

    super.initState();
  }

  Color colorbotones = const Color.fromARGB(255, 96, 125, 139);

  List<int> numCitas = [];
  TextEditingController busquedaController = TextEditingController();
  //String usuarioAPP = '';
  List<ClienteModel> listaClientes = [];
  List<ClienteModel> listaAux = [];
  List<ClienteModel> aux = [];
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  String coincidencias = '';
  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  Widget build(BuildContext context) {
    final fecha = ModalRoute.of(context)?.settings.arguments;
    // LEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();

    // LEE FORMULARIO DE BUSQUEDA
    final contextoFormularioBusqueda = context.watch<FormularioBusqueda>();

    return SafeArea(
      child: Scaffold(
        appBar: appBarCreacionCita('Selecciona cliente', true),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraProgreso().progreso(
              context,
              0.33,
              Colors.amber,
            ),
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
                fecha: fecha!,
                iniciadaSesionUsuario: _iniciadaSesionUsuario,
                emailSesionUsuario: _emailSesionUsuario,
                busquedaController: contextoFormularioBusqueda.textoBusqueda,
                pantalla: 'creacion_cita')
            // _listaClientes(fecha),
          ],
        ),
      ),
    );
  }

  Future<int> traeCitaPorCliente(idCliente) async {
    int citas = 0;
    //? TRAIGO _citas POR idCliente
    try {
      if (_iniciadaSesionUsuario) {
        await FirebaseProvider()
            .cargarCitasPorCliente(_emailSesionUsuario, idCliente);

        debugPrint('citas firebase $citas');
      } else {
        final citas0 =
            await CitaListProvider().cargarCitasPorCliente(idCliente);
        citas = (citas0.length);
        debugPrint('citas dispositivo $citas');
      }
    } catch (e) {
      debugPrint('error: $e');
    }

    // retorno numero de citas del cliente
    return citas;
  }

  Future<void> actalizaLista() async {
    setState(() {});
  }
}
