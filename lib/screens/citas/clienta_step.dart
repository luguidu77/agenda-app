import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class ClientaStep extends StatefulWidget {
  final ClienteModel clienteParametro;
  const ClientaStep({
    Key? key,
    required this.clienteParametro,
  }) : super(key: key);

  @override
  State<ClientaStep> createState() => _ClientaStepState();
}

class _ClientaStepState extends State<ClientaStep> {
  final _formKey = GlobalKey<FormState>();
  Iterable<Contact> _contacts = [];
  var _actualContact;
  bool? pagado;
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  ClienteModel cliente = ClienteModel(nombre: '', telefono: '', email: '');
  Map<String, dynamic> clienteFB = {};

  late MyLogicCliente myLogic;

  late Color color;

  bool visibleSelectTelefono = true;
  String txtSwitch = 'Conozco su teléfono';

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  traeColorPrimarioTema() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    // trae color primario del tema para dar color a los clipper (formas de fondo)
    int t = provider.mitemalight.colorScheme.primary.value;
    color = Color(t);
    setState(() {});
  }

  @override
  void initState() {
    emailUsuario();
    traeColorPrimarioTema();
    myLogic = MyLogicCliente(widget.clienteParametro);
    myLogic.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var clientaElegida = Provider.of<CitaListProvider>(context);
    clientaElegida.getClientaElegida;

    return Scaffold(
      floatingActionButton: FloatingActionButonWidget(
        icono: const Icon(Icons.arrow_right_outlined),
        texto: 'Servicio',
        funcion: () {
          if (_formKey.currentState!.validate()) {
            setState(() {
              seleccionaCliente(context, clientaElegida);
            });
            Navigator.pushNamed(context, 'servicioStep');
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 100.0, horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
            height: MediaQuery.of(context).size.height - 150,
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(right: 38.0),
                child: ClipPath(
                    clipper: const Clipper1(),
                    child: Container(
                      color: color.withOpacity(0.1),
                      // height: 500,
                    )),
              ),
              Container(
                alignment: Alignment.bottomRight,
                child: ClipPath(
                    clipper: const Clipper2(),
                    child: Container(
                      width: 295,
                      height: 117,
                      color: color.withOpacity(0.18),
                    )),
              ),
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BarraProgreso().progreso(
                        context,
                        0.33,
                        Colors.amber.shade900,
                      ),
                      const SizedBox(height: 50),
                      selectClienta(context),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(txtSwitch),
                          switchTelefono(),
                        ],
                      ),
                      visibleSelectTelefono
                          ? Column(
                              children: [
                                selectTelefono(),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0, left: 18),
                                  child: Text(
                                    'Si el teléfono introducido no existe en la agenda, se creará un nuevo cliente',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                )
                              ],
                            )
                          : const SizedBox(
                              height: 80,
                            ),
                      const SizedBox(height: 30),
                      selectEmail()
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget selectClienta(BuildContext context) {
    return Container(
      width: 300,
      height: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.blue)),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextFormField(
            validator: (value) => _validacion(value),
            controller: myLogic.textControllerNombre,
            decoration: const InputDecoration(
                labelText: 'Nombre Cliente',
                border: UnderlineInputBorder(borderSide: BorderSide.none)),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => HomeScreen(
                            index: 2, myBnB: 2,
                          ))),
              child: const Icon(Icons.favorite_border_outlined),
            ),
            TextButton(
              onPressed: () => _mensajeInformacion(context),
              child: const Icon(Icons.contact_phone_outlined),
            ),
          ],
        )
      ]),
    );
  }

  Widget selectTelefono() {
    return Container(
      width: 300,
      height: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.blue)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          validator: (value) => _validacion(value),
          keyboardType: TextInputType.number,
          controller: myLogic.textControllerTelefono,
          decoration: const InputDecoration(
              labelText: 'Teléfono cliente',
              border: UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  Widget selectEmail() {
    return Container(
      width: 300,
      height: 80,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.blue)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextFormField(
          // validator: (value) => _validacion(value),
          keyboardType: TextInputType.emailAddress,
          controller: myLogic.textControllerEmail,
          decoration: const InputDecoration(
              labelText: 'Email cliente',
              border: UnderlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
    );
  }

  _validacion(value) {
    if (value.isEmpty) {
      return 'Este campo no puede quedar vacío';
    }
  }

  _mensajeInformacion(context) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Formato teléfono'),
              content: const Text(
                  'Comprueba que el número que traiga desde su agenda '
                  'no posea el código de su país, si es así, borrelo ya que '
                  'la aplicación lo añade por defecto.'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('ENTENDIDO'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showContactList();
                  },
                )
              ]);
        });
  }

  _showContactList() async {
    List<Contact> favoriteElements = [];
    InputDecoration searchDecoration = const InputDecoration();

    await refreshContacts();

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
      ).then((e) {
        if (e != null) {
          setState(() {
            _actualContact = e;
          });
          // debugPrint('CONTACTO ELEGIDO ${_actualContact.phones}');
          myLogic.textControllerNombre.text = _actualContact.displayName;
          myLogic.textControllerTelefono.text = _actualContact.phones.first;
        }
      });
    }
  }

// Getting list of contacts from AGENDA
  refreshContacts() async {
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

  List<ClienteModel> clientes = [];

  var idCliente;

//!CONTEXTO CLIENTA SELECCIONADA CLIENTASTEP
  seleccionaCliente(context, clienta) async {
    ClienteModel nuevoCliente = ClienteModel();
    // quitar  espacios del nuemero de telefono porque no lo encuentra
    myLogic.textControllerTelefono.text = myLogic.textControllerTelefono.text
        .replaceAll(" ", "")
        .replaceAll("+", "");

    String vTelefono = myLogic.textControllerTelefono.text;

    visibleSelectTelefono ? null : myLogic.textControllerTelefono.text = '0';
    if (_iniciadaSesionUsuario) {
      clienteFB = await FirebaseProvider()
          .cargarClientePorTelefono(_emailSesionUsuario, vTelefono);
    } else {
      clientes = await CitaListProvider().cargarClientePorTelefono(vTelefono);
    }

    if (_iniciadaSesionUsuario) {
      if (clienteFB.isEmpty || vTelefono == '0') {
        await FirebaseProvider().nuevoCliente(
            _emailSesionUsuario,
            myLogic.textControllerNombre.text,
            vTelefono,
            myLogic.textControllerEmail.text,
            '',
            '');

        Map<String, dynamic> nuevoCliente = await FirebaseProvider()
            .cargarClientePorTelefono(_emailSesionUsuario, vTelefono);
        idCliente = nuevoCliente['id'];
      } else {
        String nombreEncontrado = clienteFB['nombre'];
        String nombreEscritoManualmente = myLogic.textControllerNombre.text;
        if (nombreEncontrado != nombreEscritoManualmente) {
          String txt =
              'Hemos encontrado a $nombreEncontrado con el teléfono $vTelefono';

          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.info(
              message: txt,
            ),
          );
        }

        idCliente = clienteFB['id'];
      }
    } else {
      if (clientes.isEmpty || vTelefono == '0') {
        nuevoCliente = await CitaListProvider().nuevoCliente(
            myLogic.textControllerNombre.text,
            vTelefono,
            myLogic.textControllerEmail.text,
            '',
            '');
        idCliente = nuevoCliente.id!;
      } else {
        idCliente = clientes[0].id!;
      }
    }

    print('ID cliente ----------$idCliente');
    clienta.setClientaElegida = {
      'ID': idCliente.toString(),
      'NOMBRE': _iniciadaSesionUsuario
          ? clienteFB['nombre']
          : myLogic.textControllerNombre.text, // nuevoCliente.telefono,
      'TELEFONO': vTelefono,
      'EMAIL': myLogic.textControllerEmail.text,
      'FOTO': myLogic.textControllerFoto.text,
    };
  }

  switchTelefono() {
    //OCULTA O NO  EL INPUT TELEFONO
    return Switch.adaptive(
      activeColor: color,
      value: visibleSelectTelefono,
      onChanged: (value) {
        visibleSelectTelefono = value;

        value
            ? txtSwitch = 'Conozco su teléfono'
            : txtSwitch = 'No conozco su teléfono';
        setState(() {});
      },
    );
  }
}

//Check contacts permission
Future<void> _askPermissions(context, String routeName) async {
  PermissionStatus permissionStatus = await _getContactPermission();
  if (permissionStatus == PermissionStatus.granted) {
    Navigator.of(context).pushNamed(routeName);
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
