import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroEmpleados extends StatefulWidget {
  final String dataPorLink;
  const RegistroEmpleados({Key? key, this.dataPorLink = ''}) : super(key: key);

  @override
  _RegistroEmpleadosState createState() => _RegistroEmpleadosState();
}

class _RegistroEmpleadosState extends State<RegistroEmpleados> {
  String idNegocio = 'default_idnegocio';
  String nombreNegocio = 'default_nombreNegocio';
  String id = 'default_id';
  String name = 'default_name';
  String email = 'default_email';
  String telefono = 'default_telefono';

  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _procesarParametros();
  }

  void _procesarParametros() {
    if (widget.dataPorLink.isNotEmpty) {
      try {
        final uri = Uri.parse(widget.dataPorLink);
        final queryParams = uri.queryParameters;

        setState(() {
          idNegocio = queryParams['idNegocio'] ?? idNegocio;
          nombreNegocio = queryParams['nombreNegocio'] ?? nombreNegocio;
          id = queryParams['id'] ?? id;

          name = queryParams['name'] ?? name;
          email = queryParams['email'] ?? email;
          telefono = queryParams['telefono'] ?? telefono;

          emailController.text = email; // Prellenar el campo de email
        });
        debugPrint('Parámetros cargados exitosamente: $queryParams');
// Obtén la URL sin decodificar.
        String rawFotoUrl = _getParamFromUrl(widget.dataPorLink, 'foto');

// Esto te da la URL sin decodificación.
        print(rawFotoUrl); // Aquí verás la URL tal cual como la quieres.
      } catch (e) {
        debugPrint('Error al procesar el enlace: $e');
      }
    } else {
      debugPrint('El enlace está vacío.');
    }
  }

  String _getParamFromUrl(String url, String param) {
    final startIndex = url.indexOf('$param=');
    if (startIndex != -1) {
      final valueStart = startIndex + param.length + 1;
      final valueEnd = url.indexOf('&', valueStart);
      return valueEnd != -1
          ? url.substring(valueStart, valueEnd)
          : url.substring(valueStart);
    }
    return ''; // el valor decodificado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.dataPorLink,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Icon(Icons.store, size: 100, color: Colors.blue),
            Text(
              'Únete a $nombreNegocio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'Crea una cuenta para aceptar la invitación',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint(
                    'Continuar presionado: Email ingresado -> ${emailController.text}');

                final contextEmpleados = context.read<EmpleadosProvider>();
                final empleado = EmpleadoModel(
                    idNegocio: idNegocio,
                    nombreNegocio: nombreNegocio,
                    id: id,
                    emailUsuarioApp: emailController.text,
                    nombre: name,
                    disponibilidad: [],
                    email: email,
                    telefono: telefono,
                    categoriaServicios: [],
                    foto: '',
                    color: 000000,
                    codVerif: '',
                    roles: [RolEmpleado.personal]);

                contextEmpleados.setEmpleadoRegistro(empleado);

                Navigator.pushNamed(context, '/empleadoRevisaConfirma');
              },
              child: Text('Continuar'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset('assets/icon/icon.png', height: 50),
      ),
    );
  }
}
