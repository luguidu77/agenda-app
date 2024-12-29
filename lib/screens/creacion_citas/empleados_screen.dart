import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/comprobacion_reasignacion_citas.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/screens/creacion_citas/nuevo_editar_empleado.dart';
import 'package:agendacitas/widgets/alertas/alertaAgregarPersonal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  bool foatingVisible = true;
  late List<EmpleadoModel> empleados;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getEmpleados();
  }

  @override
  Widget build(BuildContext context) {
    final EmpleadosProvider empleadosProvider =
        context.watch<EmpleadosProvider>();
    empleados = empleadosProvider.getEmpleados;

    final comprobarReasigancionProvider =
        context.watch<ComprobacionReasignacionCitas>();

    List<EmpleadoModel> empleadosStaff = empleadosProvider.getEmpleadosStaff;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de personal'),
      ),
      floatingActionButton: empleados.isNotEmpty
          ? FloatingActionButton(
              child: const Icon(Icons.plus_one),
              onPressed: () {
                Navigator.pushNamed(context, 'empleadosEdicionScreen');
              },
            )
          : null,
      body: (empleados.isEmpty)
          ? _noHayEmpleados()
          : Column(
              children: [
                // alerta para reasignar citas en caso de que se haya citas creadas antes de que el usuario se convirtiera en empleado
                // antiguos usuarios app antes de la actualización 10.0
                Visibility(
                  visible: !comprobarReasigancionProvider.estadoReasignado,
                  child: Alertas.reasignacionCitas(context),
                ),
                // alerta para agregar empleado cuando no hay empleados
                Visibility(
                  visible: empleadosStaff.isEmpty,
                  child: Alertas.agregarEmpleadoAlerta(context,
                      enableOnTap: false),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: empleados.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmpleadoEdicion(
                                  empleado: empleados[index],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 19,
                              backgroundImage: (empleados[index].foto)
                                      .isNotEmpty
                                  ? NetworkImage(empleados[index]
                                      .foto) // Cargar la imagen desde URL
                                  : const AssetImage("assets/images/nofoto.jpg")
                                      as ImageProvider, // Imagen local por defecto
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  empleados[index].nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Color(empleados[index].color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.supervised_user_circle,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          empleados[index]
                                              .roles
                                              .map((rol) =>
                                                  rolEmpleadoToString(rol))
                                              .join(', '),
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          empleados[index].email,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        empleados[index].telefono,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.schedule,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Disponibilidad: ${empleados[index].disponibilidad.join(', ')}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.category,
                                          color: Colors.grey, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Categoría: ${empleados[index].categoriaServicios.join(', ')}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (empleados[index].codVerif !=
                                      'verificado') ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.error,
                                            color: Colors.red, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pendiente Verificación: ${empleados[index].codVerif}',
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            isThreeLine: false,
                          ));
                    },
                  ),
                ),
              ],
            ),
    );
  }

  _noHayEmpleados() {
    return Padding(
      padding: const EdgeInsets.all(20.0), // Ampliar el espaciado interno
      child: Column(
        spacing: 50,
        crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda
        children: [
          _agregarPrimerEmpeado(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Alertas.agregarEmpleadoAlerta(context),
          ),
        ],
      ),
    );
  }

  InkWell _agregarPrimerEmpeado() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, 'empleadosEdicionScreen'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Colors.blueAccent, // Diferenciar el color del ícono
                  size: 30,
                ),
                const SizedBox(width: 12), // Espaciado entre ícono y texto
                Expanded(
                  child: Text(
                    'Agregate como empleado con el mismo email de tu perfil.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800], // Color uniforme al primer texto
                      fontWeight: FontWeight.w600,
                      height: 1.5, // Mejorar legibilidad del texto
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getEmpleados() {
    final EmpleadosProvider empleadosProvider =
        context.read<EmpleadosProvider>();
    empleados = empleadosProvider.getEmpleados;

    if (empleados.isEmpty) {
      // si no tiene empleados, creamos al usuario de la app como empleado y
      // le reasignamos todas las citas existentes
      crearEmpleadoyReasignarleCitas();
    }
  }

  void crearEmpleadoyReasignarleCitas() {
    final CitasProvider citasProvider = context.read<CitasProvider>();
    final List<CitaModelFirebase> citas = citasProvider.getCitas;

    if (citas.isNotEmpty) {
      // si  hay citas quiere decir que es ya es usuario antiguo y necesita crear un
      // empleado y reasignarle todas las citas ya guardadas

      //  EmpleadoModel empleado = EmpleadoModel(id: 'id', nombre: nombre, disponibilidad: disponibilidad, email: email, telefono: telefono, categoriaServicios: categoriaServicios, foto: foto, color: color, codVerif: codVerif, rol: rol)
    }
  }

  String rolEmpleadoToString(RolEmpleado rol) {
    switch (rol) {
      case RolEmpleado.personal:
        return 'Personal';
      case RolEmpleado.gerente:
        return 'Gerente';
      case RolEmpleado.administrador:
        return 'Administrador';
      default:
        return 'Desconocido'; // Opcional para manejar casos inesperados
    }
  }
}
