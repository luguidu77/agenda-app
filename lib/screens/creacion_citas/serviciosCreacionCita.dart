import 'package:agendacitas/screens/creacion_citas/creacion_cita_confirmar.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_listado_servicios.dart';

import 'package:agendacitas/screens/servicios_screen_draggable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'provider/creacion_cita_provider.dart';

class ServiciosCreacionCita extends StatefulWidget {
  const ServiciosCreacionCita({Key? key}) : super(key: key);

  @override
  State<ServiciosCreacionCita> createState() => _ServiciosCreacionCitaState();
}

class _ServiciosCreacionCitaState extends State<ServiciosCreacionCita> {
  late PersonalizaProvider contextoPersonaliza;
  late CreacionCitaProvider contextoCreacionCita;
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
    emailUsuario();
    // TRAE CONTEXTO PERSONALIZA ( MONEDA ). ES NECESARIO INIZIALIZARLA ANTES DE LLAMAR A  buildList DONDE SE UTILIZA EL CONTEXTO PARA LA MONEDA
    contextoPersonaliza = context.read<PersonalizaProvider>();
    contextoCreacionCita = context.read<CreacionCitaProvider>();
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
            } else if (snapshot.hasData && snapshot.data.isNotEmpty) {
              final data = snapshot.data;

              // SI TENGO DATOS LOS VISUALIZO EN PANTALLA
              return _iniciadaSesionUsuario
                  ? verserviciosFB(context, data)
                  : verServiciosDispositivo(context, data);
            } else {
              return //NO HAY SERVICIOS
                  Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                          'AÚN NO TIENES SERVICIOS QUE OFRECER PARA CONCERTAR UNA CITA'),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, 'Servicios'),
                          child: const Text('AÑADE TU PRIMER SERVICIO')),
                    ],
                  ),
                ),
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

//########## TARJETAS DE LOS SERVICIOS  FIREBASE ---------------------------
    return ServiciosScreenDraggable(
      servicios: listdataServicios,
      usuarioAPP: _emailSesionUsuario!,
      procede: 'CREACION_DE_CITA',
    );
  }

//######### TARJETA DE LOS SERVICIOS DE DISPOSITIVO
  verServiciosDispositivo(context, dataServicios) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: dataServicios.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                    onTap: () {
                      // PRIMERO ADAPTO EL item AL MODELO ServicioModel , PARA ENVIAR COMO ARGUMENTO A configServicios (editar servicio)
                      ServicioModel servicio = ServicioModel(
                        id: dataServicios[index].id,
                        activo: dataServicios[index].activo,
                        detalle: dataServicios[index].detalle,
                        precio: dataServicios[index].precio,
                        servicio: dataServicios[index].servicio,
                        tiempo: dataServicios[index].tiempo,
                        //  idCategoria: dataServicios[index].idCategoria,
                        //idCategoria: item.categoria,
                        /*    index: item.index */
                      );
                      contextoCreacionCita.setAgregaAListaServiciosElegidos = [
                        {
                          'ID': dataServicios[index].id.toString(),
                          'SERVICIO': dataServicios[index].servicio.toString(),
                          'TIEMPO': dataServicios[index].tiempo.toString(),
                          'PRECIO': dataServicios[index].precio.toString(),
                          'DETALLE': dataServicios[index].detalle.toString(),
                        }
                      ];

                      Navigator.pushNamed(context, 'creacionCitaComfirmar',
                          arguments: servicio);
                    },
                    child: ListTile(
                      title: Text(
                        dataServicios[index].servicio,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blueGrey),
                      ),
                      //leading: Text(item.leading),
                      subtitle: Text(
                        '${dataServicios[index].precio} ${contextoPersonaliza.getPersonaliza['MONEDA']} ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Colors.blueGrey),
                      ),
                      trailing: Text(
                        dataServicios[index].tiempo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blueGrey),
                      ), //const Icon(Icons.move_down_rounded),
                    ),

                    /*  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(141, 158, 158, 158)),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(dataServicios[index].servicio,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(dataServicios[index].detalle),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ), */
                  ),
                );
              }),
        ],
      ),
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
