import 'package:agendacitas/screens/creacion_citas/creacion_cita_confirmar.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_listado_servicios.dart';

import 'package:agendacitas/screens/servicios_screen_draggable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import '../servicios_screen copy.dart';

// ########### esta pagina pagina no esta en uso,
//############ pagina actual : servicios_screen_draggable

class ServiciosCreacionCita extends StatefulWidget {
  const ServiciosCreacionCita({Key? key}) : super(key: key);

  @override
  State<ServiciosCreacionCita> createState() => _ServiciosCreacionCitaState();
}

class _ServiciosCreacionCitaState extends State<ServiciosCreacionCita> {
  String? _emailSesionUsuario;
  bool _iniciadaSesionUsuario = false;
  List<ServicioModel> listaAux = [];
  List<ServicioModelFB> listaAuxFB = [];
  List<ServicioModel> listaservicios = [];
  List<ServicioModelFB> listaserviciosFB = [];
  List<String> listNombreServicios = [];
  List<int> listIdServicios = [];

  List<String> listTiempoServicios = [];
  List<String> listDetalleServicios = [];

  //CATEGORIAS SERVICIOS
  List<CategoriaServicioModel> listaCategoriaServicios = [];
  List<CategoriaServicioModel> listaCategoriaAuxFB = [];
  List<String> listNombreCategoriaServicios = [];
  List<String> listIdCategoriaServicios = [];
  bool hayServicios = false;

  PersonalizaModel personaliza = PersonalizaModel();

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;

    /*  if (iniciadaSesionUsuario) {
      await cargaServiciosConCategoriasFB(emailUsuario);
    } */
  }

  cargarDatosServiciosDispositivo() async {
    debugPrint('TRAYENDO SERVICIOS DE DISPOSITIVO');
    return listaAux = await CitaListProvider().cargarServicios();
  }

  @override
  void initState() {
    getPersonaliza();
    emailUsuario();

    super.initState();
  }

  retornoDeEdicionServicio() {
    // Realizar acciones o actualizar datos aquí

    emailUsuario();
    debugPrint(
        '##############- esta retornando de la pagina de config__servicios_screen.dart');
  }

  bool d = false;
  bool floatExtended = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          _body(context),
        ],
      )),
    );
  }

  _body(context) {
    return Expanded(
      child: FutureBuilder(
        future: _iniciadaSesionUsuario
            ? cargaServiciosFB(_emailSesionUsuario!)
            : cargarDatosServiciosDispositivo(),
        builder: (
          BuildContext context,
          AsyncSnapshot<dynamic> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                child: Center(
                    child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 6,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    height: 80,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            )));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              print(data);
              // SI TENGO DATOS LOS VISUALIZO EN PANTALLA
              return _iniciadaSesionUsuario
                  ? verserviciosFB(context, data)
                  : verServiciosDispositivo(context, data);
            } else {
              return //NO HAY SERVICIOS
                  Column(
                children: [
                  const Text('No tienes servicios que ofrecer'),
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'assets/images/caja-vacia.png',
                    width: MediaQuery.of(context).size.width - 250,
                  ),
                ],
              );
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      ),
    );
  }

  // SERVICIOS CON CATEGORIAS DESDE FIREBASE
  verserviciosFB(context, List<Map<String, dynamic>> listdataServicios) {
    debugPrint('########### servicios:   ${listdataServicios.toString()}');
    //estructura recibida: [{sinCategoria: Instance of 'ServicioModelFB'}, {cat 2: Instance of 'ServicioModelFB'}, {cat 1: Instance of 'ServicioModelFB'}, {cat 1: Instance of 'ServicioModelFB'}]

    /*      'id': e.id,
            'servicio': e.servicio,
            'detalle': e.detalle,
            'tiempo': e.tiempo,
            'precio': e.precio,
            'activo': e.activo,
            'idcategoria': e.idCategoria,
            'nombreCategoria': element.nombreCategoria,
            'detalleCategoria': element.detalle */
    List<Map<String, Map<String, dynamic>>> aux = listdataServicios
        .map((e) => {
              e['nombreCategoria'].toString(): {
                'id': e['id'],
                'servicio': e['servicio'],
                'detalle': e['detalle'],
                'tiempo': e['tiempo'],
                'precio': e['precio'],
                'activo': e['activo'],
                'idCategoria': e['idcategoria'],
                'nombreCategoria': e['nombreCategoria'],
                'detalleCategoria': e['detalleCategoria'],
                'index': e['index']
              }
            })
        .toList();

    // LISTA DE LAS ID CATEGORIAS DISPONBLES. filtrada que quita las repetidas--
    List<Map<String, dynamic>> categorias = listdataServicios.map((e) {
      return {
        'idCat': e['idcategoria'].toString(),
        'nombreCat': e['nombreCategoria'].toString(),
        'detalle': e['detalleCategoria']
      };
    }).toList();
    final Map<String, dynamic> mapFilter = {};

    for (Map<String, dynamic> myMap in categorias) {
      mapFilter[myMap['nombreCat']] = myMap;
    }

// listFilter lista con las categorias filtrada que quita las repetidas -------------------------
    final List<Map<String, dynamic>> listFilter = mapFilter.keys
        .map((key) => mapFilter[key] as Map<String, dynamic>)
        .toList();

    return ServiciosScreenDraggable(
      servicios: listdataServicios,
      usuarioAPP: _emailSesionUsuario!,
    );
  }

// SERVICIOS DE FIREBASE
  Widget targetasServiciosFb(Map<String, dynamic> servicio) {
    // PRIMERO ADAPTO EL MAP a ServicioModelFB
    ServicioModelFB servicioFB = ServicioModelFB(
        id: servicio['id'],
        activo: servicio['activo'],
        detalle: servicio['detalle'],
        precio: servicio['precio'],
        servicio: servicio['servicio'],
        tiempo: servicio['tiempo'],
        idCategoria: servicio['idCategoria'],
        index: servicio['index']);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreacionCitaConfirmar(),
              ));
        },
        child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromARGB(141, 158, 158, 158)),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Text(servicio['servicio']),
                        Text(servicioFB.servicio.toString(),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(servicioFB.detalle.toString()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${servicioFB.tiempo.toString()} '),
                            Text(
                              '${servicioFB.precio.toString()} ${personaliza.moneda}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ChangeActivateServicioButtonWidget(
                          servicio: servicioFB,
                          iniciadaSesionUsuario: _iniciadaSesionUsuario,
                          usuarioAPP: _emailSesionUsuario!)
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

//  SERVICIOS DE DISPOSITIVO
  verServiciosDispositivo(context, dataServicios) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: dataServicios.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreacionCitaConfirmar(),
                      ));
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(141, 158, 158, 158)),
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(dataServicios[index].servicio,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(dataServicios[index].detalle),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${dataServicios[index].tiempo} '),
                                  Text(
                                    '${dataServicios[index].precio.toString()} ${personaliza.moneda}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ChangeActivateServicioButtonWidget(
                                servicio: dataServicios[index],
                                iniciadaSesionUsuario: _iniciadaSesionUsuario,
                                usuarioAPP: _emailSesionUsuario!)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget botonDestactivarServicio(index) {
    return ChangeActivateServicioButtonWidget(
      servicio: listaservicios[index],
      iniciadaSesionUsuario: _iniciadaSesionUsuario,
      usuarioAPP: _emailSesionUsuario!,
    );
  }

  // TRAE LOS SERVICIOS Y LAS CATEGORIAS DE FIREBASE
  cargaServiciosFB(String usuarioAPP) async {
    List<ServicioModelFB> listaServiciosAux =
        await FirebaseProvider().cargarServicios(usuarioAPP);
    List<Map<String, dynamic>> data = [];
    /* List<Map<String, dynamic>> listaServiciosyCategorias = */

    for (var e in listaServiciosAux) {
      Map<String, dynamic> categoria = await FirebaseProvider()
          .cargarCategoriaServiciosID(usuarioAPP, e.idCategoria!);

      //  print(categoria);
      //  print(          'todas los servicios $listaServiciosAux <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
      Map<String, dynamic> newSerCat = {
        'id': e.id,
        'servicio': e.servicio,
        'detalle': e.detalle,
        'tiempo': e.tiempo,
        'precio': e.precio,
        'activo': e.activo,
        'index': e.index, // para reordenar la lista
        'idcategoria': categoria['id'],
        'nombreCategoria': categoria['nombreCategoria'],
        'detalleCategoria': categoria['detalle'],
      };

      data.add(newSerCat);
    }

    // print(data);
    return data;
  }
}
