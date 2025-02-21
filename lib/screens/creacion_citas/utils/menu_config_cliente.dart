import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/models.dart';
import '../../../mylogic_formularios/mylogic.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../../screens.dart';

class MenuConfigCliente extends StatefulWidget {
  final ClienteModel cliente;
  final String procedencia;
  const MenuConfigCliente({
    required this.cliente,
    required this.procedencia,
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
    return _opciones(context, widget.cliente);
  }

  Column _opciones(BuildContext context, cliente) {
    return Column(
      children: [
        const SizedBox(height: 30),
        InkWell(
          child: const Text('Edición Rápida'),
          onTap: () {
            setState(() {
              Navigator.pop(context); //CIERRO EL MENU inferior
              _cardConfigCliente(context, cliente);
            });
          },
        ),
        const SizedBox(height: 30),
        Visibility(
          visible: widget.procedencia == 'fichaCliente',
          child: InkWell(
            child: const Text('Ficha completa'),
            onTap: () {
              Navigator.pop(context);
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
        ),
        const SizedBox(height: 30),
        Visibility(
          visible: widget.procedencia == 'fichaCliente',
          child: InkWell(
            onTap: () {
              _cardEliminarCliente(context, cliente);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ########### EDICION RAPIDA DE CLIENTE ############################
  _cardConfigCliente(BuildContext context, ClienteModel cliente) {
    final contextoCita = context.read<CreacionCitaProvider>();
    final cita = contextoCita.contextoCita;
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
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: myLogic.textControllerEmail,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () async {
                          cliente.id = idCliente;

                          cliente.nombre = myLogic.textControllerNombre.text;
                          cliente.telefono =
                              myLogic.textControllerTelefono.text;
                          cliente.email = myLogic.textControllerEmail.text;

                          final newCliente = CitaModelFirebase(
                            telefonoCliente: cliente.telefono,
                            nombreCliente: cliente.nombre,
                            emailCliente: cliente.email,
                          );
                          contextoCita.setContextoCita(newCliente);

                          // ACTUALIZA CLIENTE DE FIREBASE
                          await _actualizarClienteFB(
                              _emailSesionUsuario, cliente);

                          Navigator.pop(context);
                          contextoCita.setVisibleGuardar(true);
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
    mensajeInfo(context, 'ELIMINANDO CLIENTE...');
    await _eliminarCliente(_iniciadaSesionUsuario, idCliente);

    _alertaEliminacion();
  }

  void _alertaEliminacion() {
    mensajeSuccess(context, 'Cliente y todo su historial eliminado');
    Navigator.pop(context);
    //setState(() {});
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
