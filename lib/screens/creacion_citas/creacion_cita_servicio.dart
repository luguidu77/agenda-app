import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/screens/creacion_citas/historial_citas.dart';
import 'package:agendacitas/screens/creacion_citas/utils/capitaliza_palabras.dart';
import 'package:agendacitas/screens/screens.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../widgets/widgets.dart';
import 'provider/creacion_cita_provider.dart';
import 'utils/appBar.dart';

class CreacionCitaServicio extends StatefulWidget {
  const CreacionCitaServicio({super.key});

  @override
  State<CreacionCitaServicio> createState() => _CreacionCitaServicioState();
}

class _CreacionCitaServicioState extends State<CreacionCitaServicio> {
  late CreacionCitaProvider contextoCreacionCita;
  @override
  Widget build(BuildContext context) {
// LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    ClienteModel cliente =
        ModalRoute.of(context)?.settings.arguments as ClienteModel;
    return SafeArea(
      child: Scaffold(
          appBar: appBarCreacionCita('Selecciona servicio', true),
          body: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // VISUALIZACION DEL CONTEXTO EN PRUEBAS
              /*  Text('FECHA : ${contextoCreacionCita.getCitaElegida['FECHA']}'),
          Text(
              'HORAINICIO : ${contextoCreacionCita.getCitaElegida['HORAINICIO']}'),
          Text(
              'HORAFINAL : ${contextoCreacionCita.getCitaElegida['HORAFINAL']}'),
          Text('idCliente : ${contextoCreacionCita.getClienteElegido['ID']}'),
          Text('NOMBRE : ${contextoCreacionCita.getClienteElegido['NOMBRE']}'),
          Text(
              'TELEFONO : ${contextoCreacionCita.getClienteElegido['TELEFONO']}'),
          Text('EMAIL : ${contextoCreacionCita.getClienteElegido['EMAIL']}'),
          Text('NOTA : ${contextoCreacionCita.getClienteElegido['NOTA']}'), */

              //
              BarraProgreso().progreso(
                context,
                0.66,
                Colors.amber,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Reservado por ${CapitalizaPalabras.capitalizeWords(cliente.nombre.toString())}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                flex: 1,
                child: HistorialCitas(
                  clienteParametro: cliente,
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Servicios disponibles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(flex: 6, child: ServiciosCreacionCita())
            ]),
          )),
    );
  }
}
