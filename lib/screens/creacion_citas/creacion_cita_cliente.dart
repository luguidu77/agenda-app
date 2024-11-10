import 'package:agendacitas/providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';

import 'package:fast_contacts/fast_contacts.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/models.dart';

import '../../providers/providers.dart';

import '../../widgets/botones/agregarNuevoCliente/boton_nuevo_cliente_manual.dart';
import '../../widgets/botones/agregarNuevoCliente/boton_nuevo_desde_contactos.dart';
import '../../widgets/formulario_busqueda.dart';
import '../../widgets/lista_de_clientes.dart';
import '../../widgets/widgets.dart';

import 'utils/appBar.dart';

class CreacionCitaCliente extends StatefulWidget {
  const CreacionCitaCliente({super.key});

  @override
  State<CreacionCitaCliente> createState() => _CreacionCitaClienteState();
}

class _CreacionCitaClienteState extends State<CreacionCitaCliente> {
  late CreacionCitaProvider contextoCreacionCita;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  final estilo = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  void initState() {
    emailUsuario();

    super.initState();
  }

  Color colorbotones = const Color.fromARGB(255, 96, 125, 139);

  //CONTACTOS DEL TELEFONO
  final Iterable<Contact> _contacts = [];

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

  late int codPais;

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
    //fecha y hora de inicio elegida
    final fecha = ModalRoute.of(context)?.settings.arguments;
    // LEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    //LEE CODIGO PAIS PARA PODER QUITARLO DEL TELEFONO DE LA AGENDA
    final contextoPersonaliza = context.read<PersonalizaProviderFirebase>();
    personaliza = contextoPersonaliza.getPersonaliza;

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
            // CUADRO DE BUSQUEDA #################################
            const CuadroBusqueda(),

            // BOTONES PARA CREAR CLIENTES #########################
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BotonNuevoClienteManual(),
                BotonNuevoDesdeContacto(pantalla: 'creacion_cita')
              ],
            ),
            const Divider(),

            // LISTA DE CLIENTES ####################################
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
}
