import 'package:flutter/material.dart';

import '../../models/cita_model.dart';
import '../../providers/Firebase/firebase_provider.dart';
import '../../providers/my_logic_cita.dart';
import '../../providers/pago_provider.dart';

class ConfigCategoriaServiciosScreen extends StatefulWidget {
  const ConfigCategoriaServiciosScreen({Key? key}) : super(key: key);

  @override
  State<ConfigCategoriaServiciosScreen> createState() =>
      _ConfigCategoriaServiciosScreenState();
}

class _ConfigCategoriaServiciosScreenState
    extends State<ConfigCategoriaServiciosScreen> {
  String? usuarioAPP;
  bool iniciadaSesionUsuario = false;
  String textoErrorValidacionAsunto = '';
  final _formKey = GlobalKey<FormState>();
  CategoriaServicioModel categoria =
      CategoriaServicioModel(nombreCategoria: '', detalle: '');

  late MyLogicCategoriaServicio myLogic;

  List<CategoriaServicioModel> listaAux = [];
  List<CategoriaServicioModel> listaCategoriaServicios = [];
  List<String> listNombreCategoriaServicios = [];
  List<String> listIdCategoriaServicios = [];
  String dropdownValue = '';
  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar
    final pago = await PagoProvider().cargarPago();
    final emailUsuario = pago['email'];
    usuarioAPP = emailUsuario;
    iniciadaSesionUsuario = usuarioAPP != '' ? true : false;
    setState(() {});

    await cargarDatosCategorias();

    //DATA TRAIDA POR NAVIGATOR PUSHNAMED (ARGUMENTS)

    dataFB =
        ModalRoute.of(context)!.settings.arguments as CategoriaServicioModel;
    agregaModificaFB = (dataFB.nombreCategoria == null) ? true : false;
    if (!agregaModificaFB) {
      myLogic = MyLogicCategoriaServicio(dataFB);
      myLogic.init();
    }
  }

  @override
  void initState() {
    super.initState();
    emailUsuario();
    myLogic = MyLogicCategoriaServicio(categoria);
    myLogic.init();
  }

  bool agregaModificaFB = false;

  var dataFB;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // todo Categorias no servicios
                (agregaModificaFB)
                    ? agregaCategoria(usuarioAPP!)
                    : modificarCategoria(
                        usuarioAPP!, dataFB); // METODO MODIFICAR SERVICIO
              }
            },
            child: const Icon(Icons.save),
          ),
          body: _formularioFB(
              context, agregaModificaFB)), // todo Categorias no servicios
    );
  }

  _formularioFB(context, agregaModificaFB) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _botonCerrar(),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      (agregaModificaFB)
                          ? "Agregar categoría "
                          : 'Editar categoría',
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) => _validacion(value),
                      controller: myLogic.textControllerNombreCategoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    TextFormField(
                      validator: (value) => _validacion(value),
                      controller: myLogic.textControllerDetalle,
                      decoration: const InputDecoration(labelText: 'Detalle'),
                    ),
                  ],
                )),
            const SizedBox(height: 150)
          ],
        ),
      ),
    );
  }

  agregaCategoria(String usuarioAPP) {
    final categoria = myLogic.textControllerNombreCategoria.text;
    final detalle = myLogic.textControllerDetalle.text;

    FirebaseProvider().nuevaCategoriaServicio(usuarioAPP, categoria, detalle);

    Navigator.pushReplacementNamed(context, 'Servicios');
  }

  modificarCategoria(String usuarioAPP, CategoriaServicioModel categoria) {
    CategoriaServicioModel auxCategoria = CategoriaServicioModel();
    auxCategoria.id = categoria.id;
    auxCategoria.nombreCategoria = myLogic.textControllerNombreCategoria.text;
    auxCategoria.detalle = myLogic.textControllerDetalle.text;

    FirebaseProvider().actualizarCategoriaServicioFB(usuarioAPP, auxCategoria);

    Navigator.pushReplacementNamed(context, 'Servicios');
  }

  _botonCerrar() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close,
                size: 50,
                color: Color.fromARGB(167, 114, 136, 150),
              )),
        ],
      ),
    );
  }

  _validacion(value) {
    debugPrint(value.isEmpty.toString());
    if (value.isEmpty) {
      textoErrorValidacionAsunto = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      return null;
    }
  }

  cargarDatosCategorias() async {
    if (iniciadaSesionUsuario) {
      debugPrint('TRAE CATEGORIAS DE FIREBASE');
      listaAux = await FirebaseProvider().cargarCategoriaServicios(usuarioAPP);
    }

    listaCategoriaServicios = listaAux;

    if (listaCategoriaServicios.isNotEmpty) {
      for (var item in listaCategoriaServicios) {
        listNombreCategoriaServicios.add(item.nombreCategoria.toString());
      }
      print(listNombreCategoriaServicios);

      dropdownValue = listNombreCategoriaServicios[0];
      setState(() {});
    }
  }

/*   Widget categoriaServicios(BuildContext context) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(
          labelText: 'Categoría',
          border: UnderlineInputBorder(borderSide: BorderSide.none)),
      //opcion color para cambio tema: iconEnabledColor: Colors.amber,
      hint: const Text('ELIGE UNA CATEGORÍA'),

      validator: (value) => value == null ? 'Seleciona una categoría' : null,
      items: listNombreCategoriaServicios
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          myLogic.textControllerCategoria.text = newValue;
          int index = listNombreCategoriaServicios.indexOf(dropdownValue);
          /*   iniciadaSesionUsuario
                      ? seleccionaServicioFB(context, usuarioAPP,
                          listNombreCategoriaServicios, listaCategoriaServicios, index)
                      : seleccionaServicio(context, index);
                  indexServicio = index; */
        });
      },
    );
  } */
}
