import 'package:agendacitas/screens/creacion_citas/creacion_cita_resumen.dart';
import 'package:agendacitas/screens/creacion_citas/servicios_creacion_cita.dart';
import 'package:agendacitas/screens/creacion_citas/utils/formatea_fecha_hora.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/gestures.dart';
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
  String totalTiempo = "";
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

    final boxDecoration = BoxDecoration(
      border: Border.all(
        color: const Color.fromARGB(255, 216, 215, 215), // Color del borde
        width: 1.0, // Grosor del borde
      ),
      borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
      color: Colors.white, // Fondo opcional
    );

    return WillPopScope(
      onWillPop: () async =>
          false, // inhabilita el regreso a la pagina anterior
      child: SafeArea(
          child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBarCreacionCita('Resumen de la cita', false,
            action: botonCancelar()),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${contextoCreacionCita.contextoCita.dia}'),
                Text('${contextoCreacionCita.contextoCita.horaInicio}'),
                Text('${contextoCreacionCita.contextoCita.horaFinal}'),
                // VISUALIZACION DEL CONTEXTO EN PRUEBAS
                //Text( 'SERVICIOS : ${contextoCreacionCita.getServiciosElegidos}'),
                _barraProgreso().progreso(context, 0.90, Colors.amber),
                const SizedBox(height: 10),
                Container(
                    height: 80.0, // Altura agradable para la vista
                    decoration: boxDecoration, // Bordes redondeados
                    child: _vercliente(context, citaElegida)),
                Container(
                    //  height: 80.0, // Altura agradable para la vista
                    decoration: boxDecoration, // Bordes redondeados
                    child: _agregaNotas()),

                Container(
                    height: 80.0, // Altura agradable para la vista
                    decoration: boxDecoration, // Bordes redondeados
                    child: _fechaCita()),

                _servicios(),
                _botonAgregaServicio(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: barraInferior(color),
      )),
    );
  }

  BarraProgreso _barraProgreso() => BarraProgreso();

  Padding _botonAgregaServicio(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                foregroundColor: WidgetStateProperty.all(Colors.black)),
            label: const Text('Añadir servicio'),
            onPressed: () => menuInferior(context),
            icon: const Icon(Icons.add_circle_outline)));
  }

  _fechaCita() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.calendar_today),
            InkWell(
              onTap: () => seleccionaDia(),
              child: Text(DateFormat.MMMEd('es_ES').format(DateTime.parse(
                  contextoCreacionCita.contextoCita.dia.toString()))),
            ),
            const SizedBox(
              width: 80,
            ),
            const Icon(Icons.watch_later_outlined),
            InkWell(
              onTap: () => seleccionHora(),
              child: Text(
                DateFormat.Hm('es_ES').format(DateTime.parse(
                    contextoCreacionCita.contextoCita.horaInicio.toString())),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Servicios',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Column(
          children: servicios.map((servicio) {
            final index = servicios.indexOf(servicio);
            return cardServicios(index);
          }).toList(),
        ),
      ],
    );
  }

  Widget cardServicios(index) {
    final precio = Formatear.formatPrecio(
        double.parse(
            contextoCreacionCita.getServiciosElegidos[index]['PRECIO']),
        personaliza.moneda!);
    final tiempo = FormatearFechaHora.formatearHora2(
        contextoCreacionCita.getServiciosElegidos[index]['TIEMPO'].toString());
    final empleado = contextoCreacionCita.contextoCita.nombreEmpleado;
    final horaInicio = contextoCreacionCita.contextoCita.horaInicio;
    final hora =
        FormatearFechaHora.formatearFechaYHora(horaInicio!)['horaFormateada'];
    final servicio =
        contextoCreacionCita.getServiciosElegidos[index]['SERVICIO'];
    print(
        'tiempoXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    print(tiempo);
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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            // SERVICIO ...............................................
            title: Text(
              '$servicio : $tiempo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TIEMPO Y EMPLEADO ...............................................
                Text('$hora - $empleado'),

                Visibility(
                    visible: compuebaDisponible(),
                    child: const Card(
                      color: (const Color.fromARGB(255, 253, 248, 217)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          '⚠️El miembro no está disponible',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ),
                    ))
              ],
            ),
            // PRECIO ...............................................
            trailing: Text(
              precio,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18), // Destacar el precio
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Eliminar servicio'),
                    content: const Text(
                        '¿Estás seguro de que deseas eliminar este servicio?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Cerrar el diálogo
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Eliminar servicio del contexto
                          contextoCreacionCita
                              .setEliminaItemListaServiciosElegidos = [
                            contextoCreacionCita.getServiciosElegidos[index]
                          ];
                          // Resetear la suma de tiempos
                          sumaTiempos = const Duration(hours: 0, minutes: 0);
                          // Actualizar precio total y tiempo total
                          contextoCita();
                          setState(() {});
                          Navigator.of(context).pop(); // Cerrar el diálogo
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(
                              color: Color.fromARGB(255, 206, 45,
                                  34)), // Color rojo para enfatizar
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )),
    );
  }

  _vercliente(context, CitaModelFirebase citaElegida) {
    return ClipRect(
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
              title: Text(
                citaElegida.nombreCliente.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(citaElegida.telefonoCliente.toString()),
            ),
          ],
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
    final precio = Formatear.formatPrecio(totalPrecio, personaliza.moneda!);
    final tiempo = FormatearFechaHora.formatearHora2(totalTiempo);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey, // Color del borde
        width: 1.0, // Grosor del borde
      )),
      height: 115,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 100,
                ),
                Text(
                  tiempo,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
                Text(
                  precio,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
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
                width: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Confirmar',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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

    return "$horasSumadas:$minutosRestantes";
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

    return ClipRect(
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
                title: const Text('Agrega un comentario'),
                subtitle: Text(textoNotas.toString()),
                trailing: _visible
                    ? const FaIcon(Icons.keyboard_arrow_up)
                    : const FaIcon(Icons.keyboard_arrow_down_sharp),
              ),
            ),
            Visibility(
              visible: _visible,
              child: Container(
                padding: const EdgeInsets.all(8.0),
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
    );
  }

  seleccionaDia() {
    // abre un menu que sale desde abajo de la pantalla con un calendario para seleccionar fecha
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Selecciona una fecha',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  onDateChanged: (DateTime date) {
                    setState(() {
                      String dia = formatearFechaDiaCita(date);

                      // Fecha String : dia ("2025-01-26")
                      contextoCreacionCita.contextoCita.dia = dia;
                      DateTime nuevoDia = DateTime.parse(dia);
                      // hora de inicio "2025-01-26 10:30:00.000"
                      contextoCreacionCita.contextoCita.horaInicio = DateTime(
                          nuevoDia.year,
                          nuevoDia.month,
                          nuevoDia.day,
                          contextoCreacionCita.contextoCita.horaInicio!.hour,
                          contextoCreacionCita.contextoCita.horaInicio!.minute);
                      // hora de finalizacion "2025-01-26 12:30:00.000"
                      contextoCreacionCita.contextoCita.horaFinal = DateTime(
                          nuevoDia.year,
                          nuevoDia.month,
                          nuevoDia.day,
                          contextoCreacionCita.contextoCita.horaFinal!.hour,
                          contextoCreacionCita.contextoCita.horaFinal!.minute);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  seleccionHora() {
    // abre un menu que sale desde abajo de la pantalla con todas las horas del dia en formato 00:00 de 5 minutos
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final tiempo = horafinal.difference(horainicio);
        final selectedHour = contextoCreacionCita.contextoCita.horaInicio!.hour;
        final selectedMinute =
            contextoCreacionCita.contextoCita.horaInicio!.minute;
        final initialIndex = selectedHour * 12 + (selectedMinute ~/ 5);

        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Selecciona una hora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: ScrollController(
                    initialScrollOffset: initialIndex * 56.0,
                  ),
                  itemCount: 24 * 12, // 24 hours * 12 intervals per hour
                  itemBuilder: (context, index) {
                    final hour = index ~/ 12;
                    final minute = (index % 12) * 5;
                    final time = DateFormat.Hm('es_ES').format(
                      DateTime(0, 0, 0, hour, minute),
                    );
                    final isSelected =
                        selectedHour == hour && selectedMinute == minute;
                    return ListTile(
                      title: Text(
                        time,
                        style: isSelected
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : const TextStyle(color: Colors.grey),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          final dia = contextoCreacionCita.contextoCita.dia;
                          DateTime fecha = DateTime.parse(dia!);

                          contextoCreacionCita.contextoCita.horaInicio =
                              DateTime(fecha.year, fecha.month, fecha.day, hour,
                                  minute);

                          contextoCreacionCita.contextoCita.horaFinal =
                              contextoCreacionCita.contextoCita.horaInicio!
                                  .add(tiempo);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool compuebaDisponible() {
    // Definimos el rango de horas laborales basado en la fecha de horainicio

    horainicio = contextoCreacionCita.contextoCita.horaInicio!;
    horafinal = contextoCreacionCita.contextoCita.horaFinal!;

    print(
        'hora inicio ..................................................................');
    print(horainicio);
    print(
        'hora final ..................................................................');
    print(horafinal);

    final startHour = DateTime(
        horainicio.year, horainicio.month, horainicio.day, 9); // 9:00 AM

    print(
        'hora apertura ..................................................................');
    print(startHour);

    final endHour = DateTime(
        horainicio.year, horainicio.month, horainicio.day, 22); // 10:00 PM

    // Comprobamos si los horarios están dentro del rango laboral
    if (horainicio.isBefore(startHour) || horafinal.isAfter(endHour)) {
      return false; // No disponible
    }

    return true; // Disponible
  }
}
