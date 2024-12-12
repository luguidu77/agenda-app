import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/perfil_usuarioapp_model.dart';
import 'package:agendacitas/providers/Firebase/foto_perfil_usuarioAPP.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/screens/creacion_citas/nuevo_editar_empleado.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de personal'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () {
          Navigator.pushNamed(context, 'empleadosEdicionScreen');
        },
      ),
      body: (empleados.isEmpty)
          ? _noHayEmpleados()
          : ListView.builder(
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
                        backgroundImage: NetworkImage(empleados[index].foto),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            empleados[index].nombre,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(empleados[index].color),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1),
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
                                    empleados[index].rol.join(', '),
                                    style: TextStyle(color: Colors.grey[600]),
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
                                    style: TextStyle(color: Colors.grey[600]),
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
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.schedule,
                                    color: Colors.grey, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Disponibilidad: ${empleados[index].disponibilidad.join(', ')}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.category,
                                    color: Colors.grey, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Categoría: ${empleados[index].categoriaServicios.join(', ')}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                            if (empleados[index].codVerif != 'verificado') ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.error,
                                      color: Colors.red, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pendiente Verificación: ${empleados[index].codVerif}',
                                    style: const TextStyle(color: Colors.red),
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
    );
  }

  _noHayEmpleados() {
    return Card(
      elevation: 4, // Añade una ligera sombra para un efecto moderno
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
      ),
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Margen ajustado
      child: const Padding(
        padding: EdgeInsets.all(16.0), // Espaciado interno
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
          children: [
            Icon(
              Icons.warning_amber_rounded, // Ícono de advertencia
              color: Colors.orange, // Color llamativo
              size: 28,
            ),
            SizedBox(width: 12), // Espaciado entre el ícono y el texto
            Flexible(
              child: Text(
                'Debe haber al menos un empleado para asignarle las citas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Texto en un tono más moderno
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
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
}
