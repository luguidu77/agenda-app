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

  @override
  void initState() {
    super.initState();
  }

  Color colorbotones = const Color.fromARGB(255, 96, 125, 139);

  List<int> numCitas = [];

  //String usuarioAPP = '';
  List<ClienteModel> listaClientes = [];
  List<ClienteModel> listaAux = [];
  List<ClienteModel> aux = [];
  bool? pagado;

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
    widget.iniciadaSesionUsuario
        ? listaAux = await cargaClientesFirebase(emailSesionUsuario)
        : listaAux = await CitaListProvider().cargarClientes();

    if (widget.busquedaController.length > 2) {
      listaClientes = listaClientes
          .where((element) => element.nombre!
              .toUpperCase()
              .contains(widget.busquedaController.toUpperCase()))
          .toList();
    } else {
      coincidencias = 'ninguna coincidencia';
      // aux = listaClientes;
    }
    return listaClientes;
  }

  verclientes(context, List<ClienteModel> listaClientes, fechaCita) {
    const double width = 80;
    const double height = 80;
    return ListView.builder(
        itemCount: listaClientes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            // SI SE ENCUENTRA EN LA PANTALLA DE CREACION DE CITAS => AÑADE CONTEXTO Y NAVEGA A SERVICIOS
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

            // ==================TARJETA DE VISUALIZACION DE CLIENTES ==============================
            child: Card(
              child: ClipRect(
                child: SizedBox(
                  child: Column(
                    children: [
                      ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: widget.iniciadaSesionUsuario &&
                                    listaClientes[index].foto! != ''
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
                            style: subTituloEstilo,
                          ),
                          subtitle: Text(
                            listaClientes[index].telefono.toString(),
                            style: textoTelefonoEstilo,
                          ),
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
}
