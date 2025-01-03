import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/lista_de_citas.dart';
import 'package:agendacitas/widgets/seccion_calendario.dart';
import 'package:agendacitas/widgets/seccion_empleados.screen.dart';
import 'package:agendacitas/widgets/seccion_ganancias_diarias.dart';
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
    final calendarioProvider = context.watch<CalendarioProvider>();

    personalizaProvider = context.watch<PersonalizaProviderFirebase>();

    personaliza = personalizaProvider.getPersonaliza;

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

    return const Column(
      children: [
        // ########## SECCION EMPLEADOS Y GANANCIAS  ##############################

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SeccionEmpleados(),
            SeccionGananciasDiarias(),
          ],
        ),

        // ########## CALENDARIO DE CITAS             ##############################

        SeccionCalendario(),
      ],
    );
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
