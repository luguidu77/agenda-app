import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/Firebase/sincronizar_firebase.dart';
import 'package:agendacitas/providers/cita_list_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/screens/citas/clienta_step.dart';
import 'package:agendacitas/screens/ficha_cliente_screen.dart';
import 'package:agendacitas/screens/nuevo_actualizacion_cliente.dart';
import 'package:agendacitas/widgets/botones/floating_action_buton_widget.dart';
import 'package:agendacitas/widgets/change_theme_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../mylogic_formularios/mylogic.dart';

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
  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  datosClientes(String emailSesionUsuario) async {
    _iniciadaSesionUsuario
        ? listaAux = await cargaClientesFirebase(emailSesionUsuario)
        : listaAux = await CitaListProvider().cargarClientes();

    if (listaAux.isEmpty) {
      //todo: quitar el + y espacios del nuemero de telefono porque no lo encuentra
      // await CitaListProvider().nuevoCliente(
      //    'María', '666333222', 'email@email.com', '', 'cliente ejemplo');

      //mensajeCreacionCliente();
      //initState();
    } else {
      listaClientes = listaAux;

      for (var element in listaClientes) {
        traeCitaPorCliente(element.id).then((value) {
          numCitas.add(value);
          // print('lista de las citas $numCitas');
        });
      }
      // print('----------------lista clientes : $listaClientes');
    }
    // setState(() {}); actualizando no termina de cargar!!!

    if (busquedaController.text.length > 2) {
      listaClientes = listaClientes
          .where((element) =>
              element.nombre!.contains(busquedaController.text.toUpperCase()))
          .toList();
    } else {
      // aux = listaClientes;
    }
    return listaClientes;
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
    Color colorTema = Theme.of(context).primaryColor;
    datosClientes(_emailSesionUsuario);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButonWidget(
        icono: const Icon(Icons.add),
        texto: 'Cliente',
        funcion: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoActualizacionCliente(
                cliente: ClienteModel(),
                pagado: pagado,
                usuarioAPP: _emailSesionUsuario,
              ),
            ),
          );
        },
      ),

      //drawer: const MenuDrawer(), //menuDrawer(context),
      /*  appBar: AppBar(
          backgroundColor: colorTema,
          automaticallyImplyLeading: false,
          title: const Text('Clientes'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          actions: const [ChangeThemeButtonWidget()]), */
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _textoBusqueda(),
                ],
              ),
            ),
            _listaClientes(),
          ],
        ),
      ),
    );
  }

  _textoBusqueda() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  // labelText: 'Busqueda de cliente',
                  helperText: 'Mínimo 3 letras'),
              onChanged: (String value) {
                setState(() {});
                busquedaController.text = value;
                busquedaController.selection = TextSelection.fromPosition(
                    TextPosition(offset: busquedaController.text.length));
              },
              controller: busquedaController,
            ),
          ],
        ),
      ),
    );
  }

  _listaClientes() {
    return Expanded(
        flex: 8,
        child: FutureBuilder<dynamic>(
          future: datosClientes(_emailSesionUsuario),
          builder: (
            BuildContext context,
            AsyncSnapshot<dynamic> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                  child: Center(
                      child: SkeletonParagraph(
                style: SkeletonParagraphStyle(
                    lines: 4,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      // randomLength: true,
                      height: 120,
                      borderRadius: BorderRadius.circular(5),
                      // minLength: MediaQuery.of(context).size.width,
                      // maxLength: MediaQuery.of(context).size.width,
                    )),
              )));
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                final data = snapshot.data;

                // SI TENGO DATOS LOS VISUALIZO EN PANTALLA
                return verclientes(context, data);
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        ));
  }

  verclientes(context, listaClientes) {
    return ListView.builder(
        itemCount: listaClientes.length,
        itemBuilder: (context, index) {
          return Card(
            child: ClipRect(
              child: SizedBox(
                //Banner aqui -----------------------------------------------
                child: Column(
                  children: [
                    ListTile(
                      leading: _iniciadaSesionUsuario &&
                              listaClientes[index].foto! != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(150.0),
                              child: Image.network(
                                listaClientes[index].foto!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(150.0),
                              child: Image.asset(
                                "./assets/images/nofoto.jpg",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(listaClientes[index].nombre.toString()),
                      subtitle: Text(listaClientes[index].telefono.toString()),
                      trailing: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorbotones,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(2),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClientaStep(
                                      clienteParametro: ClienteModel(
                                          nombre: listaClientes[index].nombre,
                                          telefono:
                                              listaClientes[index].telefono,
                                          email: listaClientes[index].email,
                                          nota: listaClientes[index].nota))),
                            );
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: const Text('CITAR')),
                    ),
                    Row(
                      children: [
                        //? BOTON TELEFONO DE EDICION RAPIDA DE NOMBRE Y TELEFONO
                        TextButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorbotones,
                            ),
                            onPressed: () => setState(() {
                                  _cardConfigCliente(
                                      context, listaClientes[index]);
                                }),
                            icon: const Icon(Icons.phonelink_setup_sharp),
                            label: const Text('')),
                        //? BOTON ACCESO A DATOS DEL CLIENTE Y SU HISTORIAL
                        TextButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorbotones,
                            ),
                            onPressed: () {
                              //1ºrefresco los datos cliente por si han sido editados
                              datosClientes(_emailSesionUsuario);
                              //2ºn navega a Ficha Cliente con sus datos
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double>
                                                secondaryAnimation) =>
                                        FichaClienteScreen(
                                          clienteParametro: ClienteModel(
                                              id: listaClientes[index]
                                                  .id
                                                  .toString(),
                                              nombre:
                                                  listaClientes[index].nombre,
                                              telefono:
                                                  listaClientes[index].telefono,
                                              email: listaClientes[index].email,
                                              foto: listaClientes[index].foto,
                                              nota: listaClientes[index].nota),
                                        ),
                                    transitionDuration: // ? TIEMPO PARA QUE SE APRECIE EL HERO DE LA FOTO
                                        const Duration(milliseconds: 600)),
                              );
                            },
                            icon: const Icon(Icons.card_travel_outlined),
                            label: const Text(''))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  _cardConfigCliente(BuildContext context, ClienteModel cliente) {
    MyLogicCliente myLogic = MyLogicCliente(cliente);
    myLogic.init();

    String idCliente = cliente.id!.toString();
    print(idCliente);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Edición Rápida'),
                  Icon(
                    Icons.edit_attributes,
                    color: Colors.red,
                  ),
                ],
              ),
              //  content: Text('Edición clienta'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: myLogic.textControllerNombre,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: myLogic.textControllerTelefono,
                        decoration:
                            const InputDecoration(labelText: 'Telefono'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    //HE DESHABILITADO LA ELIMINACION DE CLIENTES PARA NO TENER QUE ELIMINAR TODOAS SUS CITAS Y POR CONSIGUIENTE CAMBIE LA FACTURACION
                    /*  TextButton(
                        onPressed: () async {
                          await _eliminar(idCliente);
                          // ELIMINA CLIENTE DE FIREBASE
                          await _eliminarClienteFB(usuarioAPP, cliente.id);
                          datosClientes();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'ELIMINAR',
                        )), */
                    TextButton(
                        onPressed: () async {
                          cliente.id = idCliente;

                          cliente.nombre = myLogic.textControllerNombre.text;
                          cliente.telefono =
                              myLogic.textControllerTelefono.text;
                          await _actualizar(cliente);
                          setState(() {});
                          // ACTUALIZA CLIENTE DE FIREBASE
                          await _actualizarClienteFB(
                              _emailSesionUsuario, cliente);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'ACTUALIZAR',
                        )),
                  ],
                ),
              ],
            ));
  }

  _actualizarClienteFB(usuarioAPP, cliente) {
    SincronizarFirebase().actualizarCliente(usuarioAPP, cliente);
  }

  cargaClientesFirebase(String emailSesionUsuario) async {
    List<ClienteModel> listaCliente = [];

    listaClientes = await FirebaseProvider().cargarClientes(emailSesionUsuario);

    return listaCliente;
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
/* 
  _eliminarClienteFB(usuarioAPP, id) {
    SincronizarFirebase().eliminaClienteId(usuarioAPP, id.toString());
  } */
}

_actualizar(ClienteModel cliente) {
  CitaListProvider().acutalizarCliente(cliente);
}

/* _eliminar(int id) {
  CitaListProvider().elimarCliente(id);
} */
