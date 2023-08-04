import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/my_logic_cita.dart';
import '../../providers/providers.dart';
import '../screens.dart';

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

  @override
  Widget build(BuildContext context) {
    final fecha = ModalRoute.of(context)?.settings.arguments;
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();

    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text(
                'Selecciona cliente',
                style: estilo,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _textoBusqueda(),
                ],
              ),
            ),
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
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 25,
                    // backgroundImage: NetworkImage(                      'https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/agendadecitas%2Fritagiove%40hotmail.com%2Fclientes%2F607545402%2Ffoto?alt=media&token=af2065c0-861d-4a3a-b0bc-a690a7ba063e'),
                    child: Icon(
                      Icons.add, // Icono de suma
                      size: 40, // Tamaño del icono
                      color: Colors.white, // Color del icono
                    ),
                  ),
                  Text('Añade un nuevo cliente')
                ],
              ),
            ),
            Divider(),
            _listaClientes(fecha),
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

                  ///busquedaController.text = value;
                  //  busquedaController.selection = TextSelection.fromPosition(
                  //     TextPosition(offset: busquedaController.text.length));
                },
                controller: null // busquedaController,
                ),
          ],
        ),
      ),
    );
  }

  _listaClientes(fecha) {
    return Expanded(
        flex: 8,
        child: RefreshIndicator(
          onRefresh: acutalizaLista,
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
                  return Text(' error:  ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final data = snapshot.data;

                  // SI TENGO DATOS LOS VISUALIZO EN PANTALLA
                  return verclientes(context, data, fecha);
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          ),
        ));
  }

  verclientes(context, listaClientes, fechaCita) {
    return ListView.builder(
        itemCount: listaClientes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              contextoCreacionCita.setCitaElegida = {
                'FECHA': fechaCita,
                'HORAINICIO': fechaCita,
                'HORAFINAL': '',
              };
              contextoCreacionCita.setClienteElegido = {
                'NOMBRE': listaClientes[index].nombre.toString(),
                'TELEFONO': listaClientes[index].telefono.toString(),
                'EMAIL': listaClientes[index].email.toString(),
                'FOTO': listaClientes[index].foto.toString(),
              };
              Navigator.pushNamed(context, 'creacionCitaServicio',
                  arguments: listaClientes[index]);
            },
            child: Card(
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
                        subtitle:
                            Text(listaClientes[index].telefono.toString()),
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
                              menuInferior(context, listaClientes[index]);
                            },
                            icon: const Icon(Icons.menu),
                            label: const Text('')),
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
                                                telefono: listaClientes[index]
                                                    .telefono,
                                                email:
                                                    listaClientes[index].email,
                                                foto: listaClientes[index].foto,
                                                nota:
                                                    listaClientes[index].nota),
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

  _cardEliminarCliente(BuildContext context, ClienteModel cliente) {
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
                  Text('Eliminar cliente'),
                  Icon(
                    Icons.edit_attributes,
                    color: Colors.red,
                  ),
                ],
              ),
              //  content: Text('Edición clienta'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          cliente.id = idCliente;

                          cliente.nombre = myLogic.textControllerNombre.text;
                          cliente.telefono =
                              myLogic.textControllerTelefono.text;
                          await _actualizar(cliente);
                          setState(() {});
                          // ACTUALIZA CLIENTE DE FIREBASE
                          await _eliminarCliente(_emailSesionUsuario, cliente);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'ELIMINAR',
                        )),
                  ],
                ),
              ],
            ));
  }

  _actualizarClienteFB(String emailSesionUsuario, cliente) {
    SincronizarFirebase().actualizarCliente(emailSesionUsuario, cliente);
  }

  _eliminarCliente(String emailSesionUsuario, ClienteModel cliente) {
    SincronizarFirebase().eliminaClienteId(emailSesionUsuario, cliente.id);
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

  Future<void> acutalizaLista() async {
    setState(() {});
  }

  void menuInferior(BuildContext context, cliente) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  cliente.nombre,
                  style: titulo,
                ),
                const Divider(),
                _opciones(context, cliente)
              ],
            ),
          ),
        );
      },
    );
  }

  Column _opciones(BuildContext context, cliente) {
    return Column(
      children: [
        const SizedBox(height: 30),
        InkWell(
          child: const Text('Edición Rapida'),
          onTap: () {
            setState(() {
              _cardConfigCliente(context, cliente);
            });
          },
        ),
        const SizedBox(height: 30),
        InkWell(
          child: const Text('Ficha completa'),
          onTap: () {
            //1ºrefresco los datos cliente por si han sido editados
            datosClientes(_emailSesionUsuario);
            //2ºn navega a Ficha Cliente con sus datos
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) =>
                      FichaClienteScreen(
                        clienteParametro: ClienteModel(
                            id: cliente.id.toString(),
                            nombre: cliente.nombre,
                            telefono: cliente.telefono,
                            email: cliente.email,
                            foto: cliente.foto,
                            nota: cliente.nota),
                      ),
                  transitionDuration: // ? TIEMPO PARA QUE SE APRECIE EL HERO DE LA FOTO
                      const Duration(milliseconds: 600)),
            );
          },
        ),
        const SizedBox(height: 30),
        _emailSesionUsuario != ''
            ? InkWell(
                onTap: () {
                  _cardEliminarCliente(context, cliente);
                },
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              )
            : Container(),
        const SizedBox(height: 20),
      ],
    );
  }

  void _alertaEliminacion() {}
}

_actualizar(ClienteModel cliente) {
  CitaListProvider().acutalizarCliente(cliente);
}

/* _eliminar(int id) {
  CitaListProvider().elimarCliente(id);
} */


