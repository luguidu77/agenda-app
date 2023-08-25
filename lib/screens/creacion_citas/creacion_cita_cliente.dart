import 'package:agendacitas/providers/db_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/my_logic_cita.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';
import 'utils/appBar.dart';
import 'utils/menu_config_cliente.dart';

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
          .where((element) => element.nombre!
              .toUpperCase()
              .contains(busquedaController.text.toUpperCase()))
          .toList();
    } else {
      coincidencias = 'ninguna coincidencia';
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
        appBar: appBarCreacionCita('Selecciona cliente', true),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraProgreso().progreso(
              context,
              0.33,
              Colors.amber,
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
                  Text(
                    'Añade un nuevo cliente',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  SizedBox(
                    width: 10,
                  )
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

  _listaClientes(fecha) {
    return Expanded(
        flex: 8,
        child: RefreshIndicator(
          onRefresh: actalizaLista,
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

                  // SI HAY DATA PERO ESTA VACIA SE VISUALIZA ICONO CAJA VACIA eJ: CUANDO SE HACE BUSQUEDA Y NO HAY COINCIDENCIAS
                  if (data.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          //Text('Sin resultados'),
                          SizedBox(
                              width: 150,
                              child:
                                  Image.asset('./assets/images/caja-vacia.png'))
                        ],
                      ),
                    );
                  }
                  // ORDENA ALFABETICAMENTE POR NOMBRE CLIENTE
                  data.sort((a, b) => a.nombre!
                      .toString()
                      .toUpperCase()
                      .compareTo(b.nombre!.toString().toUpperCase()));
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
                'ID': listaClientes[index].id.toString(),
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
                          trailing: InkWell(
                              onTap: () async {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 300,
                                      color: Colors.white,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              listaClientes[index]
                                                  .nombre
                                                  .toString(),
                                              style: titulo,
                                            ),
                                            const Divider(),
                                            MenuConfigCliente(
                                                cliente: listaClientes[index]),

                                            //_opciones(context, cliente)
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                setState(() {});

                               
                              },
                              child: const Icon(FontAwesomeIcons.circleInfo))),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
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

  Future<void> actalizaLista() async {
    setState(() {});
  }
}



/* _eliminar(int id) {
  CitaListProvider().elimarCliente(id);
} */


 