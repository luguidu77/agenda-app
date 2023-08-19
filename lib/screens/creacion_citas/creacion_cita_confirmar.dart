import 'package:agendacitas/screens/citas/confirmar_step.dart';
import 'package:agendacitas/screens/creacion_citas/serviciosCreacionCita.dart';
import 'package:agendacitas/screens/creacion_citas/style/.estilos_creacion_cita.dart';
import 'package:agendacitas/screens/servicios_screen%20copy.dart';
import 'package:agendacitas/screens/servicios_screen_draggable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  Duration sumaTiempos = Duration();
  late DateTime horafinal;
  late DateTime horainicio;
  late String totalTiempo;
  var totalPrecio = 0.0;
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
    contextoCita(); // añado duracion de los servicios y sumo los precios
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TRAE CONTEXTO PERSONALIZA ( MONEDA )
    contextoPersonaliza = context.read<PersonalizaProvider>();

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
                  Text(
                      'SERVICIOS : ${contextoCreacionCita.getServiciosElegidos}'),
                  const Padding(
                    padding: EdgeInsets.all(28.0),
                    child: Text(
                      'Confirmar cita',
                      style: titulo,
                    ),
                  ),
                  vercliente(context, cliente),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(DateFormat.MMMMEEEEd('es_ES').format(
                              DateTime.parse(contextoCreacionCita
                                  .getCitaElegida['FECHA']
                                  .toString()))),
                          Row(
                            children: [
                              Text(
                                DateFormat.Hm('es_ES').format(DateTime.parse(
                                    contextoCreacionCita.getCitaElegida['FECHA']
                                        .toString())),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Text(' - '),
                              Text(
                                DateFormat.Hm('es_ES').format(
                                    DateTime.parse(horafinal.toString())),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const ElevatedButton(
                          onPressed: null, child: Text('Modificar'))
                    ],
                  ),
                  servicios(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                        onTap: () => menuInferior(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FaIcon(FontAwesomeIcons.circlePlus),
                            Text('añade otro servicio'),
                            SizedBox(
                              width: 15,
                            )
                          ],
                        )),
                  ),
                  const Divider(),
                ],
              ),
            )));
  }

  servicios() {
    return SizedBox(
      height: contextoCreacionCita.getServiciosElegidos.length * 90,
      child: ListView.builder(
          itemCount: contextoCreacionCita.getServiciosElegidos.length,
          itemBuilder: ((context, index) {
            return card(index);
          })),
    );
  }

  card(index) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${contextoCreacionCita.getServiciosElegidos[index]['SERVICIO']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
              IconButton(
                  onPressed: () {
                    // elimino servicio del contexto
                    contextoCreacionCita.setEliminaItemListaServiciosElegidos =
                        [contextoCreacionCita.getServiciosElegidos[index]];
                    // reseteo la suma de tiempos
                    sumaTiempos = const Duration(hours: 0, minutes: 0);
                    // actualiza precio total y tiempo total
                    contextoCita();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 206, 45, 34),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  vercliente(context, ClienteModel cliente) {
    return Card(
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
    /*  List<String> tiempos = [];

    for (var element in contextoCreacionCita.getServiciosElegidos) {
      totalPrecio = double.parse(element['PRECIO']) + totalPrecio;

      tiempos.add(element['TIEMPO']);
    }

    final String totalTiempo = sumarTiempo(tiempos); */

    return Container(
      color: const Color.fromARGB(141, 255, 193, 7),
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL $totalPrecio €',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'TIEMPO $totalTiempo',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  DateTime horainicio =
                      contextoCreacionCita.getCitaElegida['HORAINICIO'];

                  contextoCreacionCita.setCitaElegida = {
                    'FECHA': contextoCreacionCita.getCitaElegida['FECHA'],
                    'HORAINICIO': horainicio,
                    'HORAFINAL': horafinal
                  };
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfirmarStep(),
                      ));
                },
                child: const Text('Confirmar cita'))
          ],
        ),
      ),
    );
  }

  sumarTiempo(tiempos) {
    for (String tiempo in tiempos) {
      List<String> partes = tiempo.split(":");
      int horas = int.parse(partes[0]);
      int minutos = int.parse(partes[1]);

      sumaTiempos += Duration(hours: horas, minutes: minutos);
    }

    int horasSumadas = sumaTiempos.inHours;
    int minutosRestantes = sumaTiempos.inMinutes.remainder(60);
    print("Total: $horasSumadas horas $minutosRestantes minutos");
    return "$horasSumadas h $minutosRestantes m";
  }

  void contextoCita() {
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    List<String> tiempos = [];
    totalPrecio = 0.0;
    totalTiempo = "0 h 0 m";

    for (var element in contextoCreacionCita.getServiciosElegidos) {
      totalPrecio = double.parse(element['PRECIO']) + totalPrecio;

      tiempos.add(element['TIEMPO']);
    }

    totalTiempo = sumarTiempo(tiempos);

    horainicio = contextoCreacionCita.getCitaElegida['HORAINICIO'];
    horafinal = horainicio.add(sumaTiempos);
    setState(() {});
  }
}
