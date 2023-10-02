import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/nuevo_actualizacion_cliente.dart';

import 'package:agendacitas/widgets/lista_de_clientes.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../mylogic_formularios/my_logic_cita.dart';
import '../providers/Firebase/firebase_provider.dart';
import '../providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import '../utils/utils.dart';
import '../widgets/boton_agrega_cliente.dart';
import '../widgets/formulario_busqueda.dart';
import 'contacs_dialog.dart';

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
  Iterable<Contact> _contacts = [];
  
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
    //LEE CODIGO PAIS PARA PODER QUITARLO DEL TELEFONO DE LA AGENDA
    final contextoPersonaliza = context.read<PersonalizaProvider>();
    codPais = contextoPersonaliza.getPersonaliza['CODPAIS'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
