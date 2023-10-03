import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';

class DialogoContactoElegido extends StatefulWidget {
  const DialogoContactoElegido(
      {super.key,
      required this.listaTelefonos,
      required this.listaEmails,
      required this.nombre});
  final String nombre;
  final List<String> listaTelefonos;
  final List<String> listaEmails;

  @override
  State<DialogoContactoElegido> createState() => _DialogoContactoElegidoState();
}

class _DialogoContactoElegidoState extends State<DialogoContactoElegido> {
  late String nombre;
  String? telefonoSeleccionado = '';
  String? emailSeleccionado = '';
  late bool noTieneEmail;

  @override
  void initState() {
    super.initState();
    telefonoSeleccionado = widget.listaTelefonos.first;
    noTieneEmail = widget.listaEmails.first == 'vacio';
    emailSeleccionado = noTieneEmail ? '' : widget.listaEmails.first;

    nombre = widget.nombre;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nombre,
            style: subTituloEstilo,
          ),
          Text(
            'Contactos encontrados',
            style: textoEstilo,
          ),
          ListTile(
            title: Text("Teléfono", style: textoEstilo),
            trailing: DropdownButton<String>(
              value: telefonoSeleccionado,
              onChanged: (newValue) {
                setState(() {
                  telefonoSeleccionado = newValue;
                });
              },
              items: widget.listaTelefonos.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: Text("Email", style: textoEstilo),
            trailing: noTieneEmail
                ? Text(
                    'No tiene email vinculado',
                    style: textoEstilo,
                  )
                : DropdownButton<String>(
                    value: emailSeleccionado,
                    onChanged: (newValue) {
                      setState(() {
                        emailSeleccionado = newValue;
                      });
                    },
                    items: widget.listaEmails.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  ),
          ),
          ElevatedButton(
            onPressed: () {
              // Realizar acciones con los elementos seleccionados, por ejemplo, guardarlos en variables.
              // print("telefono seleccionado: $telefonoSeleccionado");
              // print("email seleccionado: $emailSeleccionado");
              Navigator.pop(context, {
                'nombre': nombre,
                'telefono': telefonoSeleccionado,
                'email': emailSeleccionado
              });
            },
            child: const Text('GUARDAR COMO CLIENTE'),
          ),
        ],
      ),
    );
  }
}
