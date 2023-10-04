import 'package:agendacitas/screens/creacion_citas/creacion_cita_cliente.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import '../../../screens/contacs_dialog.dart';
import '../../../screens/screens.dart';
import '../../../utils/utils.dart';
import '../boton_agrega.dart';

class BotonNuevoDesdeContacto extends StatefulWidget {
  const BotonNuevoDesdeContacto({super.key, required this.pantalla});
  final String pantalla;

  @override
  State<BotonNuevoDesdeContacto> createState() =>
      _BotonNuevoDesdeContactoState();
}

class _BotonNuevoDesdeContactoState extends State<BotonNuevoDesdeContacto> {
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  //CONTACTOS DEL TELEFONO
  Iterable<Contact> _contacts = [];

  late String pantalla;

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();

    pantalla = widget.pantalla;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return botonClienteTelefono(context);
  }

  GestureDetector botonClienteTelefono(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _iniciadaSesionUsuario
              ? _showContactList(context)
              : mensajeError(context, 'No disponible en versión gratuita');
        },
        child: const BotonAgrega(
          texto: 'TUS CONTACTOS',
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
        mensajeInfo(
            context, 'Contacto ${e['nombre']} agregado ${e['telefono']} ');

        String nombre = e['nombre'];
        String telefono = e['telefono'];
        String email = e['email'];

        try {
          await FirebaseProvider().nuevoCliente(_emailSesionUsuario, nombre,
              telefono, email, '', 'Agregado de la agenda del teléfono');
        } catch (e) {
          mensajeError(context, 'algo salió mal');
        }

        pantalla == 'cliente_screen'
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index: 2, myBnB: 2)))
            : _actualiza();
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

  _actualiza() {
    mensajeInfo(context, 'Arrastra hacia abajo la lista para actualizar');
  }
}
