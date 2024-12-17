import 'package:agendacitas/screens/creacion_citas/creacion_cita_resumen.dart';
import 'package:agendacitas/screens/creacion_citas/servicios_creacion_cita.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';
import 'provider/creacion_cita_provider.dart';
import 'utils/appBar.dart';

class CreacionCitaConfirmar extends StatefulWidget {
  const CreacionCitaConfirmar({super.key});

  @override
  State<CreacionCitaConfirmar> createState() => _CreacionCitaConfirmarState();
}

class _CreacionCitaConfirmarState extends State<CreacionCitaConfirmar> {
  Duration sumaTiempos = const Duration();
  DateTime horafinal = DateTime.now();
  late DateTime horainicio;
  String totalTiempo = "0 h 0 m";
  var totalPrecio = 0.0;
  late PersonalizaProviderFirebase personalizaProvider;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  late CreacionCitaProvider contextoCreacionCita;

  bool _iniciadaSesionUsuario =
      false; // ?  VARIABLE PARA VERIFICAR SI HAY USUARIO CON INCIO DE SESION
  Color colorBotonFlecha = Colors.blueGrey;
  String _emailSesionUsuario = '';
  String _estadoPagadaApp = '';

  @override
  void initState() {
    super.initState();
    inicializacion();
    // Llama a contextoCita al final de initState para poder utilizar dentro de contextoCita() el setState()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      contextoCita(); // añado duracion de los servicios y sumo los precios
    });
  }

  @override
  Widget build(BuildContext context) {
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.read<CreacionCitaProvider>();
    CitaModelFirebase citaElegida = contextoCreacionCita.contextoCita;
    // TRAE CONTEXTO PERSONALIZA ( MONEDA )
    personalizaProvider = context.read<PersonalizaProviderFirebase>();
    personaliza = personalizaProvider.getPersonaliza;

    Color color = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async =>
          false, // inhabilita el regreso a la pagina anterior
      child: SafeArea(
          child: Scaffold(
              appBar: appBarCreacionCita('Resumen de la cita', false,
                  action: botonCancelar()),
              bottomNavigationBar: barraInferior(color),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VISUALIZACION DEL CONTEXTO EN PRUEBAS
                    //Text( 'SERVICIOS : ${contextoCreacionCita.getServiciosElegidos}'),
                    _barraProgreso().progreso(context, 0.90, Colors.amber),
                    const SizedBox(height: 20),
                    _vercliente(context, citaElegida),
                    const SizedBox(height: 15),
                    _agregaNotas(),
                    const SizedBox(height: 15),
                    _fechaCita(),
                    _servicios(),
                    _botonAgregaServicio(context),
                    const Divider(),
                  ],
                ),
              ))),
    );
  }

  BarraProgreso _barraProgreso() => BarraProgreso();

  Padding _botonAgregaServicio(BuildContext context) {
    return Padding(
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
    );
  }

  Row _fechaCita() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(DateFormat.MMMMEEEEd('es_ES').format(DateTime.parse(
                contextoCreacionCita.contextoCita.dia.toString()))),
            Row(
              children: [
                Text(
                  DateFormat.Hm('es_ES').format(DateTime.parse(
                      contextoCreacionCita.contextoCita.horaInicio.toString())),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(' - '),
                Text(
                  DateFormat.Hm('es_ES')
                      .format(DateTime.parse(horafinal.toString())),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const ElevatedButton(onPressed: null, child: Text('Modificar'))
      ],
    );
  }

/*   servicios() {
    return SizedBox(
      height: contextoCreacionCita.getServiciosElegidos.length * 90,
      child: ListView.builder(
          itemCount: contextoCreacionCita.getServiciosElegidos.length,
          itemBuilder: ((context, index) {
            return card(index);
          })),
    );
  } */
  _servicios() {
    final servicios = contextoCreacionCita.getServiciosElegidos;
    return Column(
      children: servicios.map((servicio) {
        final index = servicios.indexOf(servicio);
        return card(index);
      }).toList(),
    );
  }

  Widget card(index) {
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
        height: 85,
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
                      '${contextoCreacionCita.getServiciosElegidos[index]['PRECIO']} ${personaliza.moneda}'),
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

  _vercliente(context, CitaModelFirebase citaElegida) {
    return Card(
      child: ClipRect(
        child: SizedBox(
          //Banner aqui -----------------------------------------------
          child: Column(
            children: [
              ListTile(
                leading:
                    _emailSesionUsuario != '' && citaElegida.fotoCliente != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(150.0),
                            child: Image.network(
                              citaElegida.fotoCliente.toString(),
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
                title: Text(citaElegida.nombreCliente.toString()),
                subtitle: Text(citaElegida.telefonoCliente.toString()),
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

  barraInferior(Color color) {
    return Container(
      color: color.withOpacity(0.5),
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
            InkWell(
              onTap: totalPrecio != 0.0
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConfirmarStep(),
                          ));

                      _iniciadaSesionUsuario
                          ? null
                          : Publicidad.publicidad(_iniciadaSesionUsuario);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Color del borde
                      width: 2.0, // Ancho del borde
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: color),
                child: const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Confirmar cita',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
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

      // SUMA TOTAL DE LOS TIEMPOS DE LOS SERVICIOS
      sumaTiempos += Duration(hours: horas, minutes: minutos);
    }

    int horasSumadas = sumaTiempos.inHours;
    int minutosRestantes = sumaTiempos.inMinutes.remainder(60);
    print("Total: $horasSumadas horas $minutosRestantes minutos");

    return "$horasSumadas h $minutosRestantes m";
  }

  void contextoCita() {
    List<String> serviciosNombres = [];
    List<String> tiempos = [];
    totalPrecio = 0.0;

    for (var element in contextoCreacionCita.getServiciosElegidos) {
      totalPrecio = double.parse(element['PRECIO']) + totalPrecio;

      tiempos.add(element['TIEMPO']);

      serviciosNombres.add(element['SERVICIO']);
    }

    // SE USA ESTA VARIABLE PARA REPRESENTARLA EN PANTALLA
    totalTiempo = sumarTiempo(tiempos);

    // SUMA A HORA DE INICIO EL TIEMPO DEL O LOS SERVICIOS
    horainicio = contextoCreacionCita.contextoCita.horaInicio!;
    horafinal = horainicio.add(sumaTiempos);

    //actualiza contexto de la cita
    CitaModelFirebase edicionCita = CitaModelFirebase(
      dia: contextoCreacionCita.contextoCita.dia,
      horaInicio: horainicio,
      horaFinal: horafinal,
      precio: totalPrecio.toString(),
      servicios: serviciosNombres,
    );
    contextoCreacionCita.setContextoCita(edicionCita);

    setState(() {});
  }

  Widget? botonCancelar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/');

        _iniciadaSesionUsuario
            ? null
            : Publicidad.publicidad(_iniciadaSesionUsuario);
      },
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(FontAwesomeIcons.xmark),
      ),
    );
  }

  TextEditingController comentarioController = TextEditingController(text: '');

  bool _visible = false;
  late String textoNotas = '';

  _agregaNotas() {
    // LLEER MICONTEXTO DE CreacionCitaProvider
    contextoCreacionCita = context.watch<CreacionCitaProvider>();
    CitaModelFirebase citaEdicion =
        CitaModelFirebase(comentario: comentarioController.text);
    contextoCreacionCita.setContextoCita(citaEdicion);

    return Card(
      child: ClipRect(
        child: SizedBox(
          //Banner aqui -----------------------------------------------
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() {
                  _visible = !_visible;
                }),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(150.0),
                    child: Image.asset(
                      "./assets/icon/notas.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: const Text('NOTAS'),
                  subtitle: Text(textoNotas.toString()),
                  trailing: _visible
                      ? const FaIcon(Icons.keyboard_arrow_up)
                      : const FaIcon(Icons.keyboard_arrow_down_sharp),
                ),
              ),
              Visibility(
                visible: _visible,
                child: Card(
                  child: TextFormField(
                    onFieldSubmitted: (String value) {
                      setState(() {
                        _visible = false;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        textoNotas = comentarioController.text;
                      });
                      /*  contextoCreacionCita.contextoCita.comentario =
                          comentarioController.text; */
                    },
                    controller: comentarioController,
                    decoration: const InputDecoration(
                      hintText: 'escribe aquí una nota...',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
