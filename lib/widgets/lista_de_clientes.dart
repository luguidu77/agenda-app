import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/creacion_citas/provider/creacion_cita_provider.dart';
import '../screens/creacion_citas/style/.estilos_creacion_cita.dart';
import '../screens/creacion_citas/utils/menu_config_cliente.dart';

class ListaClientes extends StatefulWidget {
  const ListaClientes(
      {required this.fecha,
      super.key,
      required this.iniciadaSesionUsuario,
      required this.emailSesionUsuario,
      required this.busquedaController,
      required this.pantalla});
  final Object fecha;
  final bool iniciadaSesionUsuario;
  final String emailSesionUsuario;
  final String busquedaController;
  final String pantalla;

  @override
  State<ListaClientes> createState() => _ListaClientesState();
}

class _ListaClientesState extends State<ListaClientes> {
  late CreacionCitaProvider contextoCreacionCita;
  final estilo = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  late bool _iniciadaSesionUsuario;
  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();

    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();
    super.initState();
  }

  Color colorbotones = const Color.fromARGB(255, 96, 125, 139);

  List<int> numCitas = [];

  //String usuarioAPP = '';
  List<ClienteModel> listaClientes = [];
  List<ClienteModel> listaAux = [];
  List<ClienteModel> aux = [];

  String coincidencias = '';

  @override
  Widget build(BuildContext context) {
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    return _listaClientes(widget.fecha);
  }

  _listaClientes(fecha) {
    return Expanded(
        flex: 8,
        child: RefreshIndicator(
          onRefresh: actalizaLista,
          child: FutureBuilder<dynamic>(
            future: datosClientes(widget.emailSesionUsuario),
            builder: (
              BuildContext context,
              AsyncSnapshot<dynamic> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                    child: Center(
                        child: SkeletonParagraph(
                  style: SkeletonParagraphStyle(
                      lines: 7,
                      spacing: 6,
                      lineStyle: SkeletonLineStyle(
                        // randomLength: true,
                        height: 60,
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

  Future<void> actalizaLista() async {
    setState(() {});
  }

  datosClientes(String emailSesionUsuario) async {
    _iniciadaSesionUsuario
        ? listaAux = await cargaClientesFirebase(emailSesionUsuario)
        : listaAux = await CitaListProvider().cargarClientes();

    //####### filtro por busqueda de cliente
    if (widget.busquedaController.length > 2) {
      listaAux = listaAux
          .where((element) => element.nombre!
              .toUpperCase()
              .contains(widget.busquedaController.toUpperCase()))
          .toList();
    } else {
      coincidencias = 'ninguna coincidencia';
    }
    return listaAux;
  }

  verclientes(
      BuildContext context, List<ClienteModel> listaClientes, fechaCita) {
    const double width = 80;
    const double height = 80;
    return ListView.builder(
      itemCount: listaClientes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          // Navegación al seleccionar un cliente
          onTap: widget.pantalla == 'creacion_cita'
              ? () {
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
                }
              : null,

          // ================== TARJETA DE VISUALIZACION DE CLIENTES ==============================
          child: Card(
            margin: const EdgeInsets.symmetric(
                vertical: 10, horizontal: 15), // Margen entre tarjetas
            elevation: 8, // Sombra más pronunciada
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Bordes redondeados
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  15), // Asegurarse de que la imagen también tenga bordes redondeados
              child: SizedBox(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding:
                          const EdgeInsets.all(10), // Espaciado interno
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: widget.iniciadaSesionUsuario &&
                                listaClientes[index].foto!.isNotEmpty
                            ? Image.network(
                                listaClientes[index].foto!,
                                width: width,
                                height: height,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "./assets/images/nofoto.jpg",
                                width: width,
                                height: height,
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(
                        listaClientes[index].nombre.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Color de texto más oscuro
                        ),
                      ),
                      subtitle: Text(
                        listaClientes[index].telefono.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600], // Color de texto más claro
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.circleInfo,
                          color: Colors.blue, // Color del ícono
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 300,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        20), // Bordes redondeados en la parte superior
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        listaClientes[index].nombre.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // Color de texto
                                        ),
                                      ),
                                      const Divider(),
                                      MenuConfigCliente(
                                          cliente: listaClientes[index]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  cargaClientesFirebase(String emailSesionUsuario) async {
    List<ClienteModel> listaCliente = [];

    listaCliente = await FirebaseProvider().cargarClientes(emailSesionUsuario);

    return listaCliente;
  }
}
