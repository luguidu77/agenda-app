import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/empleado/empleado.dart';
import 'package:agendacitas/widgets/lista_de_citas.dart';
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
  late PersonalizaProviderFirebase personalizaProvider;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: true);
    personaliza = personalizaProvider.getPersonaliza;
    var fecha = dateFormat.format(widget.fechaElegida);
    // CITAS SEGUN SELECCION FILTRO (TODAS, SOLO PENDIENTES)
    if (widget.filter == 'TODAS') {
      //no hay aplicado filtro o filtro TODAS , VISUALIZA TODAS LAS CITAS
      return todasLasCitas(fecha);
    } else if (widget.filter == 'PENDIENTES') {
      // SOLO VISIALIZA CITAS PENDIENTES

      return listaCitasFiltrada(fecha);
    } else {
      //no hay aplicado filtro
      return todasLasCitas(fecha);
    }
  }

  vercitas(context, List<CitaModelFirebase> citas) {
    var vistaProvider = Provider.of<VistaProvider>(context, listen: false);

    var vistaActual = vistaProvider.vista;
    /*  print(
        'oooooooooooooooooooooo veo todas las citas oooooooooooooooooooooooooo');
    print(citas); */
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

    return Column(
      children: [
        // ########## TEXTO SUMA DE GANANCIAS DIARIAS  ##############################
        Visibility(
            visible: !leerEstadoBotonIndisponibilidad,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                cambioVistaCalendario(vistaProvider, vistaActual),
                const SizedBox(width: 16),
                ...empleados(
                  context,
                  vistaActual,
                  citas,
                ),
                const SizedBox(width: 56),
                gananciaDiaria(citas, numCitas),
              ],
            )),

        // ########## TARJETAS DE LAS CITAS CONCERTADAS ##############################
        //  SYNCFUSION
        Expanded(
            child: ListaCitasNuevo(
                fechaElegida: widget.fechaElegida, citas: citas)),
      ],
    );
  }

  List<dynamic> empleados(context, CalendarView vistaActual, citas) {
    final estadoPagoProvider =
        Provider.of<EstadoPagoAppProvider>(context, listen: false);
    String emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;

    final empleadosProvider =
        Provider.of<EmpleadosProvider>(context, listen: false);
    List<EmpleadoModel> empleados = empleadosProvider.getEmpleados;

    List<dynamic> todos = empleados.map((empleado) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          FutureBuilder(
            future:
                FirebaseProvider().calculaCitasPorEmpleado(citas, empleado.id),
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              int numCitas = snapshot.data;
              return Badge.count(
                isLabelVisible: numCitas != 0,
                count: numCitas,
                backgroundColor: Colors.blue,
              );
            },
          ),
          EmpleadoWidget(
              emailUsuario: emailSesionUsuario, idEmpleado: empleado.id),
        ],
      );
    }).toList();

    return vistaActual == CalendarView.day ? todos : [];
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

  FutureBuilder<dynamic> gananciaDiaria(
      List<CitaModelFirebase> citas, int numCitas) {
    return FutureBuilder<dynamic>(
      future: widget.iniciadaSesionUsuario
          ? FirebaseProvider().calculaGananciaDiariasFB(citas)
          : CitaListProvider().calculaGananciasDiarias(citas),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 70,
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 1,
                lineStyle: SkeletonLineStyle(
                  height: 35,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('');
          } else if (snapshot.hasData) {
            final data = snapshot.data;

            // Fondo rectangular con el borde izquierdo redondeado
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Color de fondo
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                ' $data ${personaliza.moneda}',
                style: textoEstilo,
              ),
            );
          } else {
            return const Text('Empty data');
          }
        } else {
          return const Text('fdfd');
        }
      },
    );
  }

  todasLasCitas(fecha) {
    EmpleadosProvider empleadoProvider =
        Provider.of<EmpleadosProvider>(context, listen: false);

    List<dynamic> empleados = empleadoProvider.getEmpleados;

    return FutureBuilder<dynamic>(
      future: widget.iniciadaSesionUsuario
          //? TRAE LAS CITAS DEL DISPOSITIVO O DE FIREBASE CON LA CONDICION INICIO DE SESION
          ? FirebaseProvider().leerBasedatosFirebase(widget.emailusuario, fecha)
          : CitaListProvider().leerBasedatosDispositivo(fecha),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeletonEmpleados(empleados);
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error todas las citas');
          } else if (snapshot.hasData) {
            final data = snapshot.data;

            // SI TENGO DATOS LOS VISUALIZO EN PANTALLA  DATA TRAE TODAS LAS CITAS

            return vercitas(context, data);
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

  Padding _skeletonEmpleados(List<dynamic> empleados) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Row(children: [
            const SizedBox(
              // separacion izquierda de los circulos Todos los empleados y empleados
              width: 40,
            ),
            const SkeletonAvatar(
              style: SkeletonAvatarStyle(
                shape: BoxShape.circle,
                width: 50,
                height: 50,
              ),
            ),

            //// circulos segun numero de empleados
            ...empleados.map((e) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    shape: BoxShape.circle,
                    width: 50,
                    height: 50,
                  ),
                ),
              );
            })
          ]),

          const SizedBox(
            // separacion entre los circulos empleados y las lineas del calendario
            height: 40,
          ),
          /////  lineas de calendario
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
          ),
        ],
      ),
    );
  }

  listaCitasFiltrada(fecha) {
    DateTime ahoraUtcLocal = DateTime.now().toUtc().toLocal();
    List<CitaModelFirebase> listaFiltrada = [];
    List<CitaModelFirebase> listaFiltradaAux = [];
    return FutureBuilder<dynamic>(
      future: widget.iniciadaSesionUsuario
          //? TRAE LAS CITAS DEL DISPOSITIVO O DE FIREBASE CON LA CONDICION INICIO DE SESION
          ? FirebaseProvider().leerBasedatosFirebase(widget.emailusuario, fecha)
          : CitaListProvider().leerBasedatosDispositivo(fecha),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: SizedBox(
                child: Center(
                    child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 4,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 80,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            ))),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error conexion firebase');
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            print('oooooooooooooooooooooofiltradas oooooooooooooooooooooooooo');
            print(data);
            // SI TENGO DATOS LOS VISUALIZO EN PANTALLA  DATA TRAE TODAS LAS CITAS

            // FILTRO DE LAS CITAS SEGUN SELECCION FILTRO (TODAS, SOLO PENDIENTES)

            //  print('datos filtrados $data');

            listaFiltradaAux.addAll(data);
            for (var element in listaFiltradaAux) {
              if ((element.horaInicio!).toUtc().isAfter(ahoraUtcLocal)) {
                listaFiltrada.add(element);
              }
            }

            return vercitas(context, listaFiltrada);
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }

  void eliminaRecordatorio(int id) async {
    await NotificationService().cancelaNotificacion(id);
  }
}
