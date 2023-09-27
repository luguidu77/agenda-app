import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../mylogic_formularios/mylogic.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../../screens.dart';
import '../style/.estilos_creacion_cita.dart';

class MenuConfigCliente extends StatefulWidget {
  var cliente;
  MenuConfigCliente({
    required this.cliente,
    super.key,
  });

  @override
  State<MenuConfigCliente> createState() => _MenuConfigClienteState();
}

class _MenuConfigClienteState extends State<MenuConfigCliente> {
  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';
  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('meeeeeeeeeeeeeeeeeeeeeeeeee');
    return _opciones(context, widget.cliente);
  }

  /*  menuInferior(BuildContext context, cliente) {
    print('menu');
    return showModalBottomSheet(
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
  } */

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
            //  datosClientes(_emailSesionUsuario);
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
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              )

            //EN CUENTA GRATUITA ESTA DESHABILITADA ESTA OPCION
            : const Text('Eliminar', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
      ],
    );
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
    //print(idCliente);
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ELIMINAR CLIENTE'),
                ],
              ),
              //  content: Text('Edición clienta'),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: //null,
                            () {
                          // ELIMINA CLIENTE DE FIREBASE Y SUS CITAS

                          Navigator.pop(context);

                          _eliminacion(idCliente);
                        },
                        child: const Text(
                          'ELIMINAR PERMANENTEMENTE ESTE CLIENTE Y SUS CITAS CONCERTADAS',
                        )),
                  ],
                ),
              ],
            ));
  }

  Future<void> _eliminacion(idCliente) async {
    Navigator.pop(context);
    dialogoEspera();

    await _eliminarCliente(_iniciadaSesionUsuario, idCliente);

    _alertaEliminacion();
  }

  dialogoEspera() {
    return showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Eliminando...'),
          ],
        ),
        //  content: Text('Edición clienta'),
      ),
    );
  }

  void _alertaEliminacion() {
    mensajeSuccess(context, 'Cliente y todo su historial eliminado');
    setState(() {});
  }

  _eliminarCliente(bool iniciadaSesion, idCliente) async {
    if (iniciadaSesion) {
      // SI HAY INICIO DE SESION , ELIMINAR DE FIREBASE ###############

      // BORRADO DE TODOAS LAS CITAS DEL CLIENTE
      List<Map<String, dynamic>> citas = await FirebaseProvider()
          .cargarCitasPorCliente(_emailSesionUsuario, idCliente);

      for (var cita in citas) {
        await FirebaseProvider().elimarCita(_emailSesionUsuario, cita['id']);
      }

      SincronizarFirebase().eliminaClienteId(_emailSesionUsuario, idCliente);
    }
    //SI NO HAY INICIO DE SESION, NO HACE NADA, DESHABILITADA ESTA OPCION  ############
  }

  _actualizarClienteFB(String emailSesionUsuario, cliente) {
    SincronizarFirebase().actualizarCliente(emailSesionUsuario, cliente);
  }

  _actualizar(ClienteModel cliente) {
    CitaListProvider().acutalizarCliente(cliente);
  }
}
