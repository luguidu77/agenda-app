import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:flutter/material.dart';

class EmpleadoWidget extends StatelessWidget {
  final String emailUsuario;
  final String idEmpleado;

  const EmpleadoWidget({
    Key? key,
    required this.emailUsuario,
    required this.idEmpleado,
  }) : super(key: key);

  Future<EmpleadoModel> getEmpleado(
      String emailUsuario, String idEmpleado) async {
    return await FirebaseProvider().getEmpleadoporId(emailUsuario, idEmpleado);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EmpleadoModel>(
      future: getEmpleado(emailUsuario, idEmpleado), // Obtener el empleado
      builder: (BuildContext context, AsyncSnapshot<EmpleadoModel> snapshot) {
        // Mostrar indicador de carga mientras los datos se obtienen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        // Mostrar mensaje de error si hay un problema
        if (snapshot.hasError) {
          return const Text('Error al cargar los datos del empleado');
        }

        // Mostrar los datos del empleado una vez que están listos
        if (snapshot.hasData) {
          EmpleadoModel empleado = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                // Mostrar la foto del empleado si existe
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.black, width: 2), // Contorno negro
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
                const SizedBox(height: 4),
                Text(
                  empleado.nombre,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        // Si aún no se han cargado los datos, mostrar un placeholder
        return const Text('Cargando empleado...');
      },
    );
  }
}

Future<String> nombreEmpleado(
    String emailSesionUsuario, String idempleado) async {
  final EmpleadoModel empleado =
      await FirebaseProvider().getEmpleadoporId(emailSesionUsuario, idempleado);

  return empleado.nombre;
}
