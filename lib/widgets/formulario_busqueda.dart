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
            controller: busquedaController,
            onChanged: (String value) =>
                contextoFormularioBusqueda.setTextoBusqueda = value,
            decoration: InputDecoration(
              filled: true, // Rellenar el fondo
              fillColor: Colors.grey[200], // Color de fondo claro
              hintText: esVacio ? 'Buscar cliente' : txtBusqueda,
              hintStyle:
                  TextStyle(color: Colors.grey[600]), // Estilo de texto de hint
              helperText: 'Mínimo 3 letras',
              helperStyle:
                  TextStyle(color: Colors.grey[500]), // Estilo de texto helper
              prefixIcon: const Icon(Icons.search,
                  color: Colors.grey), // Icono de búsqueda
              suffixIcon: esVacio
                  ? null // No mostrar el icono si es vacío
                  : IconButton(
                      onPressed: () {
                        contextoFormularioBusqueda.setTextoBusqueda = '';
                        busquedaController.clear(); // Limpiar el TextField
                      },
                      icon: const Icon(Icons.close,
                          color: Colors.grey), // Icono de cerrar
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
                borderSide:
                    BorderSide(color: Colors.grey[300]!, width: 1), // Borde
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
                borderSide: const BorderSide(
                    color: Colors.blue, width: 2), // Borde al enfocar
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
                borderSide: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1), // Borde cuando está habilitado
              ),
            ),
          ),
        ],
      ),
    );
  }
}
