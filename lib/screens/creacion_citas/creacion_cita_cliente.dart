import 'package:agendacitas/providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/widgets/boton_agrega_cliente.dart';
import 'package:fast_contacts/fast_contacts.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import '../../models/models.dart';

import '../../providers/providers.dart';
import '../../utils/utils.dart';
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

  //CONTACTOS DEL TELEFONO
  Iterable<Contact> _contacts = [];

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
    final fecha = ModalRoute.of(context)?.settings.arguments;
    // LEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    //LEE CODIGO PAIS PARA PODER QUITARLO DEL TELEFONO DE LA AGENDA
    final contextoPersonaliza = context.read<PersonalizaProvider>();
    codPais = contextoPersonaliza.getPersonaliza['CODPAIS'];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                botonNuevoCliente(context),
                botonClienteTelefono(context)
              ],
            ),
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
        child: const BotonAgregaCliente(
          texto: 'NUEVO',
        ));
  }

  GestureDetector botonClienteTelefono(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _showContactList(context);
        },
        child: const BotonAgregaCliente(
          texto: 'CONTACTOS',
        ));
  }

  _showContactList(context) async {
    List<Contact> favoriteElements = [];
    InputDecoration searchDecoration = const InputDecoration();

    await refreshContacts(context);

    if (_contacts.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => SelectionDialogContacts(
          _contacts.toList(),
          favoriteElements,
          showCountryOnly: false,
          emptySearchBuilder: null,
          searchDecoration: searchDecoration,
        ),
      ).then((e) async {
        Contact contacto = e;
        print(contacto.phones);

        String nombre = contacto.displayName.toString();

        // quito el codigo pais
        String primerTelefono = contacto.phones.first.number
            .replaceAll(' ', '')
            .replaceFirst('+$codPais', '');
        try {
          await FirebaseProvider().nuevoCliente(
              _emailSesionUsuario,
              e.displayName.toString(),
              primerTelefono,
              '',
              '',
              'Agregado de la agenda del teléfono');

          mensajeInfo(
              context, 'Contacto $nombre agregado a la agenda $primerTelefono');

          setState(() {});
        } catch (e) {
          mensajeError(context, 'algo salió mal');
        }
      });
    }
  }

  // Getting list of contacts from AGENDA
  refreshContacts(context) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Iterable<Contact> contacts = await FastContacts.getAllContacts();
      debugPrint('PERMISO CONCEDIDO');
      setState(() {
        // print(contacts);
        _contacts = contacts;
      });
    } else {
      _handleInvalidPermissions(context, permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(context, PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
