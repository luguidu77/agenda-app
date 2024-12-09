import 'package:agendacitas/models/empleado_model.dart';
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
  @override
  Widget build(BuildContext context) {
    final empleadosProvider = context.watch<EmpleadosProvider>();
    List<EmpleadoModel> empleados = empleadosProvider.getEmpleados;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.plus_one),
        onPressed: () {
          Navigator.pushNamed(context, 'empleadosEdicionScreen');
        },
      ),
      body: ListView.builder(
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
              leading: Badge(
                isLabelVisible:
                    empleados[index].codVerif != 'verificado' ? true : false,
                backgroundColor: Colors.white,
                label: const Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(empleados[index].foto),
                ),
              ),
              title: Text(empleados[index].nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${empleados[index].email}'),
                  Text('Teléfono: ${empleados[index].telefono}'),
                  Text(
                      'Categoría de Servicios: ${empleados[index].categoriaServicios.join(', ')}'),
                  Row(
                    children: [
                      const Text('Color: '),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(empleados[index].color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: empleados[index].codVerif != 'verificado'
                          ? true
                          : false,
                      child: Text(
                          style: const TextStyle(color: Colors.red),
                          'Pendiente Verificación: ${empleados[index].codVerif}')),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
