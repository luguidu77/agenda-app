import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/FormularioBusqueda/formulario_busqueda_provider.dart';

class CuadroBusqueda extends StatefulWidget {
  const CuadroBusqueda({super.key});

  @override
  State<CuadroBusqueda> createState() => _CuadroBusquedaState();
}

class _CuadroBusquedaState extends State<CuadroBusqueda> {
  TextEditingController busquedaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final contextoFormularioBusqueda = context.watch<FormularioBusqueda>();
    final txtBusqueda = contextoFormularioBusqueda.textoBusqueda;
    final color = Theme.of(context).primaryColor;
    bool esVacio = txtBusqueda.isEmpty;
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Stack(
        children: [
          TextFormField(
            decoration: InputDecoration(
                iconColor: color,
                suffixIconColor: color,
                fillColor: color,
                hoverColor: color,
                prefixIconColor: color,
                focusColor: color,
                prefixIcon: const Icon(Icons.search),
                hintText: esVacio ? 'Buscar cliente' : txtBusqueda,
                helperText: 'Mínimo 3 letras',
                suffixIcon: esVacio
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          contextoFormularioBusqueda.setTextoBusqueda = '';
                          busquedaController.text = '';
                        },
                        icon: const Icon(Icons.close))),
            onChanged: (String value) =>
                contextoFormularioBusqueda.setTextoBusqueda = value,
            controller: busquedaController,
          ),
        ],
      ),
    );
  }
}
