import 'package:agendacitas/screens/creacion_citas/serviciosCreacionCita.dart';
import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:agendacitas/screens/servicios_screen%20copy.dart';
import 'package:agendacitas/screens/servicios_screen_draggable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

import 'provider/creacion_cita_provider.dart';

class CreacionCitaConfirmar extends StatefulWidget {
  const CreacionCitaConfirmar({super.key});

  @override
  State<CreacionCitaConfirmar> createState() => _CreacionCitaConfirmarState();
}

class _CreacionCitaConfirmarState extends State<CreacionCitaConfirmar> {
  late PersonalizaProvider contextoPersonaliza;
  late CreacionCitaProvider contextoCreacionCita;
  ClienteModel cliente = ClienteModel();
  bool _iniciadaSesionUsuario =
      false; // ?  VARIABLE PARA VERIFICAR SI HAY USUARIO CON INCIO DE SESION
  Color colorBotonFlecha = Colors.blueGrey;
  String _emailSesionUsuario = '';
  String _estadoPagadaApp = '';

  @override
  void initState() {
    inicializacion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TRAE CONTEXTO PERSONALIZA ( MONEDA )
    contextoPersonaliza = context.read<PersonalizaProvider>();

    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();

    cliente.nombre = contextoCreacionCita.getClienteElegido['NOMBRE'];
    cliente.telefono = contextoCreacionCita.getClienteElegido['TELEFONO'];
    cliente.foto = contextoCreacionCita.getClienteElegido['FOTO'];
    return SafeArea(
        child: Scaffold(
            bottomNavigationBar: barraInferior(),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VISUALIZACION DEL CONTEXTO EN PRUEBAS
                  //Text('SERVICIOS : ${contextoCreacionCita.getServiciosElegidos}'),
                  Padding(
                    padding: EdgeInsets.all(28.0),
                    child: Text(
                      'Confirmar cita',
                      style: titulo,
                    ),
                  ),
                  vercliente(context, cliente),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(DateFormat.MMMMEEEEd('es_ES').format(DateTime.parse(
                          contextoCreacionCita.getCitaElegida['FECHA']
                              .toString()))),
                      const ElevatedButton(
                          onPressed: null, child: Text('Modificar'))
                    ],
                  ),
                  servicios(),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('añade otro servicio'),
                          ElevatedButton.icon(
                            onPressed: () => menuInferior(context),
                            icon: Icon(Icons.plus_one_sharp),
                            label: Text(''),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            )));
  }

  servicios() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 300,
            child: Expanded(
              child: ListView(
                children: List.generate(
                    contextoCreacionCita.getServiciosElegidos.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.blue, // Color del borde izquierdo
                            width: 5, // Ancho del borde izquierdo
                          ),
                        ),
                      ),
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${contextoCreacionCita.getServiciosElegidos[index]['SERVICIO']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                //Text('19:00 - 20-00'),
                                Text(
                                    '${contextoCreacionCita.getServiciosElegidos[index]['TIEMPO']} h')
                              ],
                            ),
                            Text(
                                '${contextoCreacionCita.getServiciosElegidos[index]['PRECIO']} ${contextoPersonaliza.getPersonaliza['MONEDA']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );

    /*  return Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.blue, // Color del borde izquierdo
                    width: 5, // Ancho del borde izquierdo
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${contextoCreacionCita.getServiciosElegidos.first['SERVICIO']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          //Text('19:00 - 20-00'),
                          Text(
                              '${contextoCreacionCita.getServiciosElegidos.first['TIEMPO']} h')
                        ],
                      ),
                      Text(
                          '${contextoCreacionCita.getServiciosElegidos.first['PRECIO']} ${contextoPersonaliza.getPersonaliza['MONEDA']}')
                    ],
                  ),
                ),
              ),
            ); */
  }

  vercliente(context, ClienteModel cliente) {
    return Container(
      child: Card(
        child: ClipRect(
          child: SizedBox(
            //Banner aqui -----------------------------------------------
            child: Column(
              children: [
                ListTile(
                  leading: _emailSesionUsuario != '' && cliente.foto != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(150.0),
                          child: Image.network(
                            cliente.foto!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(150.0),
                          child: Image.asset(
                            "./assets/images/nofoto.jpg",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                  title: Text(cliente.nombre!.toString()),
                  subtitle: Text(cliente.telefono!.toString()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    _estadoPagadaApp = estadoPagoProvider.estadoPagoApp;
  }

  void menuInferior(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: const Column(
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.more_horiz_outlined,
                color: Colors.black45,
                size: 50,
              ),
              Divider(),
              Expanded(child: ServiciosCreacionCita()),
            ],
          ),
        );
      },
    );
  }

  barraInferior() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Precio total 33€ (1h)'),
            ElevatedButton(onPressed: null, child: Text('Confirmar cita'))
          ],
        ),
      ),
    );
  }
}
