import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/empleado/empleado.dart';
import 'package:agendacitas/widgets/lista_de_citas.dart';
import 'package:agendacitas/widgets/seccion_empleados.screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/providers.dart';
import '../utils/utils.dart';

class ListaCitas extends StatefulWidget {
  final String emailusuario;
  final DateTime fechaElegida;
  final bool iniciadaSesionUsuario;
  final String
      filter; // todo: parametro que se manda del menu filtro y en base al string que reciba haremos el filter correspondiente a la lista de citas

  const ListaCitas(
      {Key? key,
      required this.emailusuario,
      required this.fechaElegida,
      required this.iniciadaSesionUsuario,
      required this.filter})
      : super(key: key);
  @override
  State<ListaCitas> createState() => _ListaCitasState();
}

class _ListaCitasState extends State<ListaCitas> {
  bool filtrarEmpleado = false;
  late PersonalizaProviderFirebase personalizaProvider;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  List<EmpleadoModel> empleados = [];

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  getpersonaliza() {
    print('oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');
    print('oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');
    print('oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo');
    print(personaliza.moneda);
    // setState(() {});
  }

  @override
  void initState() {
    getpersonaliza();
    // getEmpleados();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: true);
    personaliza = personalizaProvider.getPersonaliza;
    var fecha = dateFormat.format(widget.fechaElegida);

    /* // CITAS SEGUN SELECCION FILTRO (TODAS, SOLO PENDIENTES)
    if (widget.filter == 'TODAS') {
      //no hay aplicado filtro o filtro TODAS , VISUALIZA TODAS LAS CITAS
      return todasLasCitas(fecha, empleados);
    } else if (widget.filter == 'PENDIENTES') {
      // SOLO VISIALIZA CITAS PENDIENTES

      return listaCitasFiltrada(fecha);
    } else {
      //no hay aplicado filtro
      return todasLasCitas(fecha, empleados);
    } */

    return Column(
      children: [
        // ########## SECCION EMPLEADOS Y GANANCIAS  ##############################
        // SeccionEmpleados(leerEstadoBotonIndisponibilidad, vistaProvider, vistaActual, context, todasLasCitasConteoPorEmpleado, citas, numCitas),
        const SeccionEmpleados(),

        // ########## CALENDARIO DE CITAS             ##############################
        todasLasCitas(fecha, empleados),
      ],
    );
  }

  vercitas(context, List<CitaModelFirebase> citas, empleados,
      {List<CitaModelFirebase> todasLasCitasConteoPorEmpleado = const []}) {
    var vistaProvider = Provider.of<VistaProvider>(context, listen: false);

    var vistaActual = vistaProvider.vista;

    int contadorCitas = 0;
    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;

    // ············DESCUENTA DE LAS CITAS LOS INDISPUESTOS ............................... ;
    for (var cita in citas) {
      if (cita.idcliente != '999') {
        contadorCitas++;
      }
    }
    final numCitas = contadorCitas;

    return
        // ########## TARJETAS DE LAS CITAS CONCERTADAS ##############################
        //  SYNCFUSION
        Expanded(
            child: ListaCitasNuevo(
                fechaElegida: widget.fechaElegida, citas: citas));
  }

  cambioVistaCalendario(VistaProvider vistaProvider, CalendarView vistaActual) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.black, width: 2), // Contorno negro
              ),
              child: const CircleAvatar(
                radius: 21,
                backgroundColor: Colors.white, // Fondo blanco
              ),
            ),
            IconButton(
              onPressed: () {
                vistaProvider.setVistaCalendario(
                  vistaActual == CalendarView.day
                      ? CalendarView.timelineDay
                      : CalendarView.day,
                );
                setState(() {});
              },
              icon: vistaActual == CalendarView.day
                  ? const Icon(Icons.groups_outlined)
                  : const Icon(Icons.person_2_outlined),
            ),
          ],
        ),
        const Text(
          'Vista',
          style: TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<List<CitaModelFirebase>> getCitasPorFecha(String fecha) async {
    var citasProvider = context.watch<CitasProvider>();
    List<CitaModelFirebase> todasLasCitas = citasProvider.getCitas;

    return todasLasCitas;
  }

  todasLasCitas(String fecha, empleados) {
    // OBTIENE TODOS LOS EMPLEADOS
    EmpleadosProvider empleadoProvider =
        Provider.of<EmpleadosProvider>(context, listen: false);
    List<dynamic> empleados = empleadoProvider.getEmpleados;

    // VERIFICO EMPLEADO SELECCIONADO PARA FILTRAR LAS CITAS

    final contextoCreacionCita = context.watch<CreacionCitaProvider>();

    return FutureBuilder<dynamic>(
      future: getCitasPorFecha(fecha),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return skeleton();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error todas las citas');
          } else if (snapshot.hasData) {
            List<CitaModelFirebase> citas = snapshot.data;

            // SI TENGO DATOS LOS VISUALIZO EN PANTALLA  DATA TRAE TODAS LAS CITAS

            final contextoCita = contextoCreacionCita.contextoCita;
            String idEmpleado = contextoCita.idEmpleado ?? '';

            // si es ''  => trae todas las citas sin filtrar empleado
            if (idEmpleado != 'TODOS_EMPLEADOS') {
              // Filtrar por idEmpleado
              List<CitaModelFirebase> citasFiltradas =
                  filtrarPorEmpleado(citas, idEmpleado);

              return vercitas(
                context,
                citasFiltradas,
                empleados,
                todasLasCitasConteoPorEmpleado: citas,
              );
            } else {
              // SIN Filtrar por idEmpleado
              return vercitas(context, citas, empleados,
                  todasLasCitasConteoPorEmpleado: citas);
            }
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }

  /// widget skeleton de la vista

  void eliminaRecordatorio(int id) async {
    await NotificationService().cancelaNotificacion(id);
  }

  void getEmpleados() {
    final empleadosProvider =
        Provider.of<EmpleadosProvider>(context, listen: false);
    empleados = empleadosProvider.getEmpleados;
  }

  skeleton() {
    return /////  lineas de calendario
        SkeletonParagraph(
      style: SkeletonParagraphStyle(
          lines: 14,
          spacing: 6,
          lineStyle: SkeletonLineStyle(
            // randomLength: true,
            height: 30,
            borderRadius: BorderRadius.circular(5),
            // minLength: MediaQuery.of(context).size.width,
            // maxLength: MediaQuery.of(context).size.width,
          )),
    );
  }
}

List<CitaModelFirebase> filtrarPorEmpleado(
    List<CitaModelFirebase> data, String idEmpleado) {
  return data.where((cita) => cita.idEmpleado == idEmpleado).toList();
}
