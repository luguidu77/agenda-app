import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/validaciones_form_inicio_session_registro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmpleadoRevisaConfirma extends StatefulWidget {
  const EmpleadoRevisaConfirma({super.key});

  @override
  EmpleadoRevisaConfirmaState createState() => EmpleadoRevisaConfirmaState();
}

class EmpleadoRevisaConfirmaState extends State<EmpleadoRevisaConfirma> {
  final _formKey = GlobalKey<FormState>();
  bool _isAgreed = false;

  // datos negocio
  String idNegocio = '';
  String nombreNegocio = '';
  String fotoEmpleado = '';

  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final contextEmpleados = context.read<EmpleadosProvider>();
    final empleado = contextEmpleados.getEmpleadoRegistro;

    idNegocio = empleado.idNegocio!;
    nombreNegocio = empleado.nombreNegocio!;

    _nombreController.text = empleado.nombre;
    _emailController.text = empleado.email;
    _telefonoController.text = empleado.telefono;
    _fotoEmpleado(
        empleado); // traigo la foto a traves de firebase en vez de por la url
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Revisar datos',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Revisa tus datos completados por $nombreNegocio y comprueba que son correctos antes de crear tu cuenta.',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Foto(fotoEmpleado: fotoEmpleado),
                    const SizedBox(height: 20),
                    _buildCard(
                      icon: Icons.person,
                      label: 'Nombre',
                      controller: _nombreController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    _buildCard(
                      icon: Icons.email,
                      label: 'Email',
                      controller: _emailController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        return null;
                      },
                    ),
                    _buildCard(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      controller: _telefonoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor ingresa tu número de teléfono móvil';
                        }
                        return null;
                      },
                    ),
                    _buildCard(
                      icon: Icons.password_outlined,
                      label: 'Contraseña',
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ingresa una contraseña para crear tu cuenta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        'Estoy de acuerdo con Política de Privacidad, Condiciones del servicio y del negocio',
                        style: TextStyle(fontSize: 14),
                      ),
                      value: _isAgreed,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: Icon(icon, color: Colors.blueAccent),
            labelText: label,
            labelStyle: const TextStyle(fontSize: 16),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate() && _isAgreed) {
      final contextEmpleados = context.read<EmpleadosProvider>();

      contextEmpleados.modificaEmpleadoRegistro(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );
      _registrar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor revisa los campos y acepta las condiciones.',
          ),
        ),
      );
    }
  }

  void _registrar() async {
    final contextEmpleados = context.read<EmpleadosProvider>();
    final empleado = contextEmpleados.getEmpleadoRegistro;

    // crea la cuenta en firebase auth
    bool res = await creaCuentaUsuarioApp(
        context, _emailController.text, _passwordController.text);

    if (res) {
      // crear empleado

      final nuevoEmpleado = EmpleadoModel(
        id: empleado.id,
        idNegocio: idNegocio,
        nombreNegocio: nombreNegocio,
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        foto: fotoEmpleado,
        emailUsuarioApp: _emailController.text,
        disponibilidad: [],
        categoriaServicios: [],
        color: empleado.color,
        codVerif: 'verificado',
        roles: [],
      );
      print(nuevoEmpleado.id);
      print(empleado.idNegocio);

      await FirebaseProvider()
          .registroEmpleado(nuevoEmpleado, nuevoEmpleado.idNegocio!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registro exitoso, inicia sesión',
          ),
        ),
      );
      FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, 'Bienvenida');
    }
  }

  void _fotoEmpleado(EmpleadoModel empleado) async {
    final perfilEmpleado = await FirebaseProvider()
        .cargarPerfilEmpleado(idNegocio, empleado.email);
    fotoEmpleado = perfilEmpleado.foto!;
    setState(() {});
  }
}

class Foto extends StatelessWidget {
  const Foto({
    super.key,
    required this.fotoEmpleado,
  });

  final String fotoEmpleado;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage: fotoEmpleado.isNotEmpty
            ? NetworkImage(fotoEmpleado) // Suponiendo que sea una URL válida
            : null, // Si no hay foto, muestra un fondo gris
        child: fotoEmpleado.isEmpty
            ? const Icon(Icons.photo, size: 50, color: Colors.grey)
            : null, // Si hay foto, no mostrar el icono
      ),
    );
  }
}
