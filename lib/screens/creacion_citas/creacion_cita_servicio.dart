import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'style/.estilos_creacion_cita.dart';

class CreacionCitaServicio extends StatefulWidget {
  const CreacionCitaServicio({super.key});

  @override
  State<CreacionCitaServicio> createState() => _CreacionCitaServicioState();
}

class _CreacionCitaServicioState extends State<CreacionCitaServicio> {
  @override
  Widget build(BuildContext context) {
    ClienteModel cliente =
        ModalRoute.of(context)?.settings.arguments as ClienteModel;
    return SafeArea(
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(28.0),
              child: Text(
                'Selecciona servicio',
                style: titulo,
              ),
            ),
          ),
          /*  Expanded(
            flex: 1,
            child: Row(
              children: [
                Text('form busqueda') //  _textoBusqueda(),
              ],
            ),
          ), */

          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text('Reservado recientemente por ${cliente.nombre}'),
                Expanded(
                  child: ListView.builder(
                      itemCount: 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('servicio. tiempo'),
                                Text('precio €')
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          const Expanded(flex: 6, child: ServiciosCreacionCita())
        ]),
      )),
    );
  }
}
