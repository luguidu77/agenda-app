import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/my_logic_cita.dart';
import 'package:flutter/material.dart';

class ConfigClienteScreen extends StatefulWidget {
  final cliente;
  const ConfigClienteScreen({Key? key, this.cliente}) : super(key: key);

  @override
  State<ConfigClienteScreen> createState() => _ConfigClienteScreenState();
}

class _ConfigClienteScreenState extends State<ConfigClienteScreen> {
  ClienteModel cliente = ClienteModel(nombre: '', telefono: '');
  late MyLogicCliente myLogic;

  @override
  void initState() {
    // ClienteModel cliente = widget.cliente;
    myLogic = MyLogicCliente(widget.cliente);
    myLogic.init();

    super.initState();

    // _askPermissions('/nuevacita');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _formulario(context),
    );
  }

  _formulario(BuildContext context) {
    return Padding(
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
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> _cardConfigCliente(
    BuildContext context, String texto, Icon icono) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Icon(
              Icons.phone_android_rounded,
              color: Colors.red,
            ),
            content: Text(texto),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: const Text(
                    'Ok',
                  )),
            ],
          ));
}
