import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../mylogic_formularios/mylogic.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class ServicioStep extends StatefulWidget {
  const ServicioStep({Key? key}) : super(key: key);

  @override
  State<ServicioStep> createState() => _ServicioStepState();
}

class _ServicioStepState extends State<ServicioStep> {
  final _formKey = GlobalKey<FormState>();
  ServicioModel servicio =
      ServicioModel(id: 0, servicio: '', tiempo: '', precio: 0, detalle: '');
  int indexServicio = 0;

  List<ServicioModel> listaAux = [];
  List<ServicioModel> listaservicios = [];
  List<ServicioModelFB> listaserviciosFB = [];
  List<ServicioModelFB> listaAuxFB = [];
  List<String> listNombreServicios = [];
  List<String> listIdServicios = [];

  String dropdownValue = '';
  bool visualizaBotonCrearServicio =
      false; //si no hay servicios, visible boton para ir a sercicios
  late MyLogicServicio myLogic;

  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();

  getPersonaliza() async {
    final personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);
    personaliza = personalizaProvider.getPersonaliza;

    // TODO  COMPROBAR SI ES NECESARIO SETESTATE O CAMBIAR LA POSICION DEL PROVIDER

    setState(() {});
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;

    await cargarDatosServicios();
  }

  pagoProvider() async {
    return Provider.of<PagoProvider>(context, listen: false);
  }

  cargarDatosServicios() async {
    if (_iniciadaSesionUsuario) {
      debugPrint('TRAE SERVICIOS DE FIREBASE');
      //-----------------------------------------------------------------------------------------------------
      listaAuxFB =
          await FirebaseProvider().cargarServiciosActivos(_emailSesionUsuario);
      listaserviciosFB = listaAuxFB;

      if (listaserviciosFB.isNotEmpty) {
        for (var item in listaserviciosFB) {
          var nombreCategoria = await FirebaseProvider()
              .cargarCategoriaServiciosID(
                  _emailSesionUsuario, item.idCategoria!);
          if (item.activo == 'true') {
            listNombreServicios.add(
                '${item.servicio}-${nombreCategoria['nombreCategoria'].toString()}');
          }
        }
        print(listNombreServicios);

        dropdownValue = listNombreServicios[0];
        setState(() {});
      } else {
        visualizaBotonCrearServicio = true;

        setState(() {});
      }
    } else {
      debugPrint('TRAE SERVICIOS DE DISPOSITIVO');
      //-----------------------------------------------------------------------------------------------------
      listaAux = await CitaListProvider().cargarServicios();
      listaservicios = listaAux;

      if (listaservicios.isNotEmpty) {
        for (var item in listaservicios) {
          if (item.activo == 'true') {
            listNombreServicios.add(item.servicio.toString());
          }
        }
        print(listNombreServicios);

        dropdownValue = listNombreServicios[0];
        setState(() {});
      } else {
        visualizaBotonCrearServicio = true;

        setState(() {});
      }
    }
  }

  Color? color;
  traeColorPrimarioTema() async {
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    // trae color primario del tema para dar color a los clipper (formas de fondo)
    int t = provider.mitemalight.colorScheme.primary.value;
    color = Color(t);
    setState(() {});
  }

  @override
  void initState() {
    getPersonaliza();
    emailUsuario();
    traeColorPrimarioTema();
    myLogic = MyLogicServicio(servicio);
    myLogic.init();

    super.initState();

    // _askPermissions('/nuevacita');
  }

  @override
  Widget build(BuildContext context) {
    var servicioElegido = Provider.of<CitaListProvider>(context);
    var servicio = servicioElegido.getServicioElegido;

    return visualizaBotonCrearServicio
        ? Scaffold(
            //---------------------- SI NO HAY SERVICIOS GUARDADOS ---------------------------------
            body: Padding(
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
            ),
          )
        : Scaffold(
            //---------------------- SI HAY SERVICIOS GUARDADOS ---------------------------------
            floatingActionButton: FloatingActionButonWidget(
              icono: const Icon(Icons.arrow_right_outlined),
              texto: 'Cita',
              funcion: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(context, 'citaStep');
                }
              },
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 100.0, horizontal: 10.0),
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  height: MediaQuery.of(context).size.height - 150,
                  // color: Colors.white,
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 38.0),
                      child: ClipPath(
                          clipper: const Clipper1(),
                          child: Container(
                            color: color!.withOpacity(0.1),
                            // height: 200,
                          )),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: ClipPath(
                          clipper: const Clipper2(),
                          child: Container(
                            width: 195,
                            height: 217,
                            color: color!.withOpacity(0.18),
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
                              0.66,
                              Colors.amber,
                            ),
                            const SizedBox(height: 50),
                            listaServicios(context),
                            const SizedBox(height: 50),
                            precioServicio(servicio),
                            const SizedBox(height: 50),
                            comentario(servicio),
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

  Widget listaServicios(BuildContext context) {
    return Column(children: [
      Container(
        width: 300,
        height: 110,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Colors.blue)),
        child: Stack(alignment: Alignment.centerRight, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              isDense: false,
              itemHeight: 85,
              // menuMaxHeight: 100, maximo altura del menu

              decoration: const InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide.none)),
              //opcion color para cambio tema: iconEnabledColor: Colors.amber,
              hint: Text(
                listNombreServicios.isEmpty
                    ? 'cargando servicios...'
                    : 'Elige un servicio',
                style: const TextStyle(fontSize: 18),
              ),

              validator: (value) =>
                  value == null ? 'Seleciona un servicio' : null,
              items: listNombreServicios
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value.toString().split('-')[0]),
                      const SizedBox(width: 5),
                      _iniciadaSesionUsuario
                          ? Text(
                              value.toString().split('-')[1],
                              style: const TextStyle(color: Colors.blueGrey),
                            )
                          : const Text(''),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  int index = listNombreServicios.indexOf(dropdownValue);
                  _iniciadaSesionUsuario
                      ? seleccionaServicioFB(context, _emailSesionUsuario,
                          listNombreServicios, listaserviciosFB, index)
                      : seleccionaServicio(context, index);
                  indexServicio = index;
                });
              },
            ),
          ),
        ]),
      ),
    ]);
  }

  Container precioServicio(servicio) {
    bool habilitado = _iniciadaSesionUsuario ? true : false;
    return Container(
      width: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.blue)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextField(
            enabled: habilitado,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
            onChanged: (e) {
              servicio['PRECIO'] = e;
              setState(() {});
            },
            controller: myLogic.textControllerPrecio,
            decoration: InputDecoration(
                labelText: 'Precio', suffixText: '${personaliza.moneda}  ')),
      ),
    );
  }

  Container comentario(servicio) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.blue)),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: TextField(
            keyboardType: TextInputType.text,
            style: const TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            onChanged: (e) {
              servicio['DETALLE'] = e;
              setState(() {});
            },
            controller: myLogic.textControllerDetalle,
            decoration: const InputDecoration(labelText: 'Comentario')),
      ),
    );
  }

  seleccionaServicio(context, index) {
    var servicioElegido = Provider.of<CitaListProvider>(context, listen: false);

    servicioElegido.setServicioElegido = {
      'ID': index + 1,
      'SERVICIO': listaservicios[index].servicio.toString(),
      'TIEMPO': listaservicios[index].tiempo.toString(),
      'PRECIO': listaservicios[index].precio.toString(),
      'DETALLE': listaservicios[index].detalle.toString(),
    };

    // carga en el cuadro de texto PRECIO el precio del servicio (este no se puede modificar en dicho cuadro de texto)
    myLogic.textControllerPrecio.text = listaservicios[index].precio.toString();
    // carga en el cuadro de texto COMENTARIO  el detalle del servicio, pero cuando se guarde la cita se guardara en comentario de la tabla Cita
    myLogic.textControllerDetalle.text =
        listaservicios[index].detalle.toString();
    setState(() {});
  }

  seleccionaServicioFB(BuildContext context, usuarioApp,
      List listNombreServcios, List<ServicioModelFB> listServicios, index) {
    print(
        'usuarioapp: $_emailSesionUsuario,lista nombres servicios: $listServicios lista servicios: $listServicios');
    print(listServicios.map((e) => e.servicio));

    var servicioElegido = Provider.of<CitaListProvider>(context, listen: false);

    servicioElegido.setServicioElegido = {
      'ID': listaserviciosFB[index].id.toString(),
      'SERVICIO': listaserviciosFB[index].servicio.toString(),
      'TIEMPO': listaserviciosFB[index].tiempo.toString(),
      'PRECIO': listaserviciosFB[index].precio.toString(),
      'DETALLE': listaserviciosFB[index].detalle.toString(),
    };
/* 
    CitaModelFirebase edicionCita = CitaModelFirebase(servicios: ['servcio']);
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    contextoCreacionCita.setContextoCita(edicionCita);
 */
    // carga en el cuadro de texto PRECIO el precio del servicio (este no se puede modificar en dicho cuadro de texto)
    myLogic.textControllerPrecio.text =
        listaserviciosFB[index].precio.toString();
    // carga en el cuadro de texto COMENTARIO  el detalle del servicio, pero cuando se guarde la cita se guardara en comentario de la tabla Cita
    myLogic.textControllerDetalle.text =
        listaserviciosFB[index].detalle.toString();

    setState(() {});
  }
}
