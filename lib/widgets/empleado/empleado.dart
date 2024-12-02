import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/calendario_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_creacion_indisponibilidad.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class EmpleadoWidget extends StatefulWidget {
  final String emailUsuario;
  final String idEmpleado;

  const EmpleadoWidget({
    Key? key,
    required this.emailUsuario,
    required this.idEmpleado,
  }) : super(key: key);

  @override
  State<EmpleadoWidget> createState() => _EmpleadoWidgetState();
}

class _EmpleadoWidgetState extends State<EmpleadoWidget> {
  EmpleadoModel empleado = EmpleadoModel(
    id: '',
    nombre: '',
    disponibilidad: [],
    email: '',
    telefono: '',
    categoriaServicios: [],
    foto: '',
    color: 0xFFFFFFFF, // Color predeterminado
  );

  getEmpleado(String emailUsuario, String idEmpleado) async {
    final contextoEmpleado = context.read<EmpleadosProvider>();

    List<EmpleadoModel> empleados = contextoEmpleado.getEmpleados;

    empleado = empleados.where((empleado) => empleado.id == idEmpleado).first;
  }

  Future<int> getNumCitas(String idEmpleado) async {
    int numCitas = 0;

    // TRAIGO TODAS LAS CITAS
    final contextoCitas = context.watch<CitasProvider>();
    List<CitaModelFirebase> todasLasCitas = contextoCitas.getCitas;

    // TRAIGO LA FECHA SELECCIONADA DEL CALENDARIO y FORMATEO LA FECHA SELECCIONADA
    var calendarioProvider = context.watch<CalendarioProvider>();
    DateTime fechaElegida = calendarioProvider.fechaSeleccionada;
    String fechaElegidaFormateada =
        DateFormat('yyyy-MM-dd').format(fechaElegida);

    // Filtra las citas que coinciden con la fecha elegida y el idEmpleado
    numCitas = todasLasCitas
        .where((value) =>
            value.dia == fechaElegidaFormateada &&
            value.idEmpleado == idEmpleado)
        .length;

    return numCitas;
  }

  @override
  void initState() {
    getEmpleado(widget.emailUsuario, widget.idEmpleado);
    //getNumCitas(widget.idEmpleado);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextoCreacionCita = context.read<CreacionCitaProvider>();
    bool empleadoSeleccionado =
        empleado.id == contextoCreacionCita.contextoCita.idEmpleado;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        FutureBuilder(
          future: getNumCitas(widget.idEmpleado),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mostrar la foto del empleado si existe
              InkWell(
                onTap: () {
                  CitaModelFirebase edicionCita =
                      CitaModelFirebase(idEmpleado: empleado.id);
                  contextoCreacionCita.setContextoCita(edicionCita);
                  debugPrint(
                      'agregado el empleado al contexto de la Creacion de la cita: ${empleado.nombre}');
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Color(empleado.color),
                        width: empleadoSeleccionado ? 6 : 2), // Contorno negro
                  ),
                  child: empleado.foto.isNotEmpty
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(empleado.foto),
                        )
                      : const CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              AssetImage('assets/images/nofoto.jpg'),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                empleado.nombre,
                style: TextStyle(
                  color: empleadoSeleccionado ? Colors.black : Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
