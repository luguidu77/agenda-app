import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/utils/total_de_citas_diaria.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmpleadoWidget extends StatefulWidget {
  final String emailUsuario;
  final String idEmpleado;
  final String? procede;

  const EmpleadoWidget(
      {Key? key,
      required this.emailUsuario,
      required this.idEmpleado,
      this.procede})
      : super(key: key);

  @override
  State<EmpleadoWidget> createState() => _EmpleadoWidgetState();
}

class _EmpleadoWidgetState extends State<EmpleadoWidget> {
  EmpleadoModel empleado = EmpleadoModel(
    id: '',
    emailUsuarioApp: '',
    nombre: '',
    disponibilidad: [],
    email: '',
    telefono: '',
    categoriaServicios: [],
    foto: '',
    color: 0xFFFFFFFF,
    codVerif: '',
    roles: [],
  );

  getEmpleado(String emailUsuario, String idEmpleado) async {
    final contextoEmpleado = context.read<EmpleadosProvider>();

    List<EmpleadoModel> empleados = contextoEmpleado.getEmpleados;

    try {
      empleado = empleados.where((empleado) => empleado.id == idEmpleado).first;
    } catch (e) {
      print('error al buscar empleado');
      empleado.nombre = '(empleado)';
    }
  }

  @override
  void initState() {
    getEmpleado(widget.emailUsuario, widget.idEmpleado);
    //getNumCitas(widget.idEmpleado);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextoCreacionCita = context.watch<CreacionCitaProvider>();
    bool empleadoSeleccionado =
        empleado.id == contextoCreacionCita.contextoCita.idEmpleado;

    //vista de empleado dependiendo de la pantalla

    switch (widget.procede) {
      case 'detalles_cita':
        return Text(
          empleado.nombre,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.bold),
        );

      case 'agrega_horario_indispuesto':
        return Text(
          ' ${empleado.nombre}',
          style: estiloHorarios,
        );
      default:
        return _widgetFotoCitas(contextoCreacionCita, empleadoSeleccionado);
    }
  }

  Stack _widgetFotoCitas(
      CreacionCitaProvider contextoCreacionCita, bool empleadoSeleccionado) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        FutureBuilder(
          future: getNumCitas(context, widget.idEmpleado),
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
                  // agrego al contexto tanto el id como el nombre del empleado y su color
                  CitaModelFirebase edicionCita = CitaModelFirebase(
                      idEmpleado: empleado.id,
                      nombreEmpleado: empleado.nombre,
                      colorEmpleado: empleado.color);
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
