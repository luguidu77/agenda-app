import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/calendario_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_creacion_indisponibilidad.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/alertas/alertaAgregarPersonal.dart';
import 'package:agendacitas/widgets/empleado/empleado.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SeccionEmpleados extends StatefulWidget {
  const SeccionEmpleados({super.key});

  @override
  State<SeccionEmpleados> createState() => _SeccionEmpleadosState();
}

class _SeccionEmpleadosState extends State<SeccionEmpleados> {
  List<EmpleadoModel> empleadosStaff = [];
  @override
  void initState() {
    super.initState();
    // Asegúrate de que el contexto esté disponible antes de actualizarlo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final empleadosProvider = context.read<EmpleadosProvider>();
      if (empleadosProvider.getEmpleadosStaff.length == 1) {
        final contextoCreacionCita = context.read<CreacionCitaProvider>();
        contextoCreacionCita.setContextoCita(
          CitaModelFirebase(
              idEmpleado: empleadosProvider.getEmpleadosStaff[0].id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmpleadosProvider>(
      builder: (context, empleadosProvider, child) {
        if (!empleadosProvider.empleadosCargados) {
          // Mostrar indicador de carga mientras se cargan los empleados
          return const Center(
            child: SkeletonAvatar(
              style: SkeletonAvatarStyle(
                shape: BoxShape.circle,
                width: 50,
                height: 50,
              ),
            ),
          );
        }

        if (empleadosProvider.getEmpleadosStaff.isEmpty) {
          // Mostrar mensaje o botón si no hay empleados
          return Alertas.agregarEmpleadoAlerta(context);
        }

        // Mostrar contenido si hay empleados
        return seccionEmpleados();
      },
    );
  }

  Visibility seccionEmpleados() {
    //bool leerEstadoBotonIndisponibilidad, VistaProvider vistaProvider, CalendarView vistaActual, context, List<CitaModelFirebase> todasLasCitasConteoPorEmpleado, List<CitaModelFirebase> citas, int numCitas

    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;

    var vistaProvider = Provider.of<VistaProvider>(context, listen: false);
    var vistaActual = vistaProvider.vista;
    var citasProvider = Provider.of<CitasProvider>(context, listen: false);
    var todasLasCitas = citasProvider.getCitas;
    final empleadosProvider = context.watch<EmpleadosProvider>();
    empleadosStaff = empleadosProvider.getEmpleadosStaff;

    return Visibility(
        visible: !leerEstadoBotonIndisponibilidad,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // cambioVistaCalendario(vistaProvider, vistaActual),

            Visibility(
              visible: empleadosStaff.length != 1,
              child: verTodosLosEmpleados(vistaProvider, vistaActual),
            ),

            const SizedBox(width: 10),

            ..._empleados(
              context,
              vistaActual,
              todasLasCitas,
            ),
            const SizedBox(width: 56),
            gananciaDiaria(todasLasCitas),
          ],
        ));
  }

  verTodosLosEmpleados(VistaProvider vistaProvider, CalendarView vistaActual) {
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();
    bool seleccionado = false;

    if (empleadosStaff.length == 1) {
      CitaModelFirebase edicionContextoCita =
          CitaModelFirebase(idEmpleado: empleadosStaff[0].id);
      if (mounted) {
        final contextoCreacionCita = context.read<CreacionCitaProvider>();
        contextoCreacionCita.setContextoCita(edicionContextoCita);
      }
    } else {
      seleccionado =
          'TODOS_EMPLEADOS' == contextoCreacionCita.contextoCita.idEmpleado;
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.black,
                    width: seleccionado ? 6 : 2), // Contorno negro
              ),
              child: const CircleAvatar(
                radius: 21,
                backgroundColor: Colors.white, // Fondo blanco
              ),
            ),
            IconButton(
              onPressed: () {
                CitaModelFirebase edicionCita =
                    CitaModelFirebase(idEmpleado: 'TODOS_EMPLEADOS');
                contextoCreacionCita.setContextoCita(edicionCita);
                debugPrint(
                    'agregado el empleado al contexto de la Creacion de la cita el idEmpleado = "TODOS_EMPLEADOS"    para quitar filtrado de citas por empleado');
              },
              icon: vistaActual == CalendarView.day
                  ? const Icon(Icons.groups_outlined)
                  : const Icon(Icons.person_2_outlined),
            ),
          ],
        ),
        Text(
          'Todos',
          style: TextStyle(
            color: seleccionado ? Colors.black : Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<dynamic> _empleados(context, CalendarView vistaActual, citas) {
    final estadoPagoProvider =
        Provider.of<EstadoPagoAppProvider>(context, listen: false);
    String emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    List<Widget> empleadosWidget = [];

    empleadosWidget = empleadosStaff.map((empleado) {
      return EmpleadoWidget(
          emailUsuario: emailSesionUsuario, idEmpleado: empleado.id);
    }).toList();

    return vistaActual == CalendarView.day ? empleadosWidget : [];
  }

  Future<String> getNumCitas(List<CitaModelFirebase> todasLasCitas) async {
    // Obtener la fecha seleccionada y formatearla
    var calendarioProvider = context.watch<CalendarioProvider>();
    String fechaElegidaFormateada =
        DateFormat('yyyy-MM-dd').format(calendarioProvider.fechaSeleccionada);

    // Filtrar citas por fecha seleccionada y calcular la ganancia diaria
    double gananciaDiaria = todasLasCitas
        .where((value) => value.dia == fechaElegidaFormateada)
        .fold(0.0, (sum, cita) {
      double precio = double.tryParse(cita.precio ?? '0') ?? 0.0;
      return sum + precio;
    });

    // Devolver 0 si la ganancia es cero, de lo contrario formatear con dos decimales
    return gananciaDiaria == 0
        ? '0.00'
        : NumberFormat("#.00").format(gananciaDiaria);
  }

  FutureBuilder<dynamic> gananciaDiaria(List<CitaModelFirebase> citas) {
    // TRAIGO PERSONALIZA PARA LA MONEDA
    final contextoPersonaliza = context.read<PersonalizaProviderFirebase>();
    final personaliza = contextoPersonaliza.getPersonaliza;

    return FutureBuilder<dynamic>(
      future: getNumCitas(citas),
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

  /*  Padding _skeletonEmpleados(List<dynamic> empleados) {
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
         
        ],
      ),
    );
  } */
}

class CargandoDatos extends StatelessWidget {
  const CargandoDatos({super.key});
  _botonNoHayEmpleados(context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, 'empleadosScreen'),
      icon: const Icon(
        Icons.warning_amber_rounded, // Ícono de advertencia
        color: Colors.white, // Color del ícono
        size: 20,
      ),
      label: const Text(
        'Agrega un empleado', // Mensaje claro
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Tamaño cómodo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Esquinas redondeadas
        ),
        elevation: 4, // Sombra para un efecto moderno
        backgroundColor: Colors.orange, // Color llamativo como advertencia
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          Future.delayed(const Duration(seconds: 5)), // Duración de 1 segundo
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Retorna un contenedor vacío o reemplaza con el contenido deseado
          return _botonNoHayEmpleados(
              context); // Botón u otro widget puede ir aquí
        }
        // Mientras se espera, muestra el indicador de carga
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
