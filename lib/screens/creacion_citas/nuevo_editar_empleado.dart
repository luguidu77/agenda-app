import 'dart:async';

import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/Firebase/notificaciones.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EmpleadoEdicion extends StatefulWidget {
  final EmpleadoModel? empleado;

  const EmpleadoEdicion({super.key, this.empleado});

  @override
  EmpleadoEdicionState createState() => EmpleadoEdicionState();
}

class EmpleadoEdicionState extends State<EmpleadoEdicion> {
  final controllerEmail = TextEditingController(text: '');
  final controllerRol = TextEditingController(text: '');
  bool _isEmailFieldEnabled = true; // Controla si el campo está habilitado

  final _formKey = GlobalKey<FormState>();
  late String id;
  late String nombre;
  late List<String> disponibilidad;
  late String email;
  late String telefono;
  late List<String> categoriaServicios;
  late String foto;
  late int color;
  late String codVerif;

  late List<RolEmpleado> rolesEmpleados;

  final ImagePicker _picker = ImagePicker();

  String _emailSesionUsuario = '';
  bool cargandoFoto = false;

  List<String> servicios = [];

  final List<RolEmpleado> roles = [
    RolEmpleado.administrador,
    RolEmpleado.gerente,
    RolEmpleado.personal,
  ];
  final List<RolEmpleado> rolesPersonalInhabilitado = [
    RolEmpleado.administrador,
    RolEmpleado.gerente,
  ];

  String rolEmpleadoToString(RolEmpleado rol) {
    switch (rol) {
      case RolEmpleado.personal:
        return 'personal';
      case RolEmpleado.gerente:
        return 'gerente';
      case RolEmpleado.administrador:
        return 'administrador';
      default:
        return 'Desconocido'; // Opcional para manejar casos inesperados
    }
  }

  RolEmpleado stringToRolEmpleado(String role) {
    switch (role) {
      case 'personal':
        return RolEmpleado.personal;
      case 'gerente':
        return RolEmpleado.gerente;
      case 'administrador':
        return RolEmpleado.administrador;
      default:
        throw ArgumentError('Rol desconocido: $role');
    }
  }

  final List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  estadoPagoEmailApp() async {
    final estadoPagoProvider = context.read<EmailAdministradorAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailAdministradorApp;
    //  _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;

    final categorias =
        await FirebaseProvider().cargarCategorias(_emailSesionUsuario);
    print(categorias.toString());
    for (var categoria in categorias) {
      servicios.add(categoria['nombreCategoria']);
    }
  }

  @override
  void initState() {
    super.initState();

    estadoPagoEmailApp();

    if (widget.empleado != null) {
      id = widget.empleado!.id;
      nombre = widget.empleado!.nombre;
      disponibilidad = List<String>.from(widget.empleado!.disponibilidad);
      email = widget.empleado!.email;
      telefono = widget.empleado!.telefono;
      categoriaServicios =
          List<String>.from(widget.empleado!.categoriaServicios);
      foto = widget.empleado!.foto;
      color = widget.empleado!.color;
      codVerif = widget.empleado!.codVerif;
      rolesEmpleados = List<RolEmpleado>.from(widget.empleado!.roles);

      // Actualiza el controlador con el email del empleado
      controllerEmail.text = email;
    } else {
      id = '';
      nombre = '';
      disponibilidad = [];
      email = '';
      telefono = '';
      categoriaServicios = [];
      foto = '';
      color = 0xFFFFC1C1;
      codVerif = '';
      rolesEmpleados = [];

      // Establece un valor inicial para el controlador
      controllerEmail.text = '';
    }
  }

  void _selectColor() async {
    int? selectedColor = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFFFFC1C1), // Rosa suave
                  child: Container(
                    color: const Color(0xFFFFC1C1),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, 0xFFB0E57C), // Verde suave
                  child: Container(
                    color: const Color(0xFFB0E57C),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFFADD8E6), // Azul suave
                  child: Container(
                    color: const Color(0xFFADD8E6),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, 0xFFFFFFB3), // Amarillo suave
                  child: Container(
                    color: const Color(0xFFFFFFB3),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFFD7BDE2), // Lila suave
                  child: Container(
                    color: const Color(0xFFD7BDE2),
                    height: 50,
                    width: 50,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedColor != null) {
      setState(() {
        color = selectedColor;
      });
    }
  }

  void _rolPorDefecto() {
    controllerRol.text = 'administrador, gerente, personal';
    rolesEmpleados = roles;
  }

  void _selectRol() async {
    final contextoEmpleados = context.read<EmpleadosProvider>();
    List<String>? selectedRoles = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: 'Selecciona sus roles',
          items: obtenerItems(contextoEmpleados.getEmpleadosStaff.length <= 2),
          initialSelectedItems:
              rolesEmpleados.map((rol) => rolEmpleadoToString(rol)).toList(),
        );
      },
    );

    if (selectedRoles != null) {
      setState(() {
        rolesEmpleados =
            selectedRoles.map((e) => stringToRolEmpleado(e)).toList();
      });
    }
  }

  void _selectDisponibilidad() async {
    List<String>? selectedDias = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: 'Selecciona los días de disponibilidad',
          items: diasSemana,
          initialSelectedItems: disponibilidad,
        );
      },
    );

    if (selectedDias != null) {
      setState(() {
        disponibilidad = selectedDias;
      });
    }
  }

  void _selectCategoriaServicios() async {
    List<String>? selectedServicios = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: 'Selecciona las categorías de servicios',
          items: servicios,
          initialSelectedItems: categoriaServicios,
        );
      },
    );

    if (selectedServicios != null) {
      setState(() {
        categoriaServicios = selectedServicios;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final EmpleadosProvider empleadosProvider =
        context.read<EmpleadosProvider>();
    List<EmpleadoModel> empleados = empleadosProvider.getEmpleados;

    if (empleados.isEmpty) {
      controllerEmail.text = _emailSesionUsuario;
      _rolPorDefecto();
      setState(() {
        _isEmailFieldEnabled = false;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empleado == null
            ? 'Agregar Empleado'
            : 'Modificar Empleado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Visibility(
                visible: codVerif != 'verificado' && codVerif != '',
                child: InkWell(
                  onTap: () => _enviarEmailInvitacion(id),
                  child: Card(
                    color: const Color.fromARGB(255, 238, 197, 197),
                    child: Column(
                      children: [
                        Text(
                            style: const TextStyle(color: Colors.white),
                            '$nombre no ha completado su registro,\nenvíale una invitación 📤'),
                        /*  Text(
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                          ' $codVerif',
                        ), */
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundImage: foto.isEmpty
                        ? const AssetImage("assets/images/face.png")
                            as ImageProvider // Imagen local por defecto// Foto por defecto si no hay foto aún
                        : NetworkImage(foto),
                    radius: 50,
                  ),
                  Column(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _subirImagen();
                        },
                        child: cargandoFoto
                            ? const CircularProgressIndicator()
                            : const Icon(
                                Icons.photo_library_outlined,
                                size: 40,
                              ),
                      ),
                      GestureDetector(
                        onTap: _selectColor,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Asignale un color',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => nombre = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                initialValue: controllerEmail.text,
                enabled: _isEmailFieldEnabled,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                initialValue: telefono,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => telefono = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: empleados.isEmpty ? null : _selectRol,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: empleados.isEmpty
                      ? Text(controllerRol.text)
                      : Text(rolesEmpleados.isEmpty
                          ? 'Selecciona rol'
                          : rolesEmpleados
                              .map((rol) => rolEmpleadoToString(rol))
                              .toList()
                              .join(', ')),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDisponibilidad,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(disponibilidad.isEmpty
                      ? 'Selecciona los días'
                      : disponibilidad.join(', ')),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectCategoriaServicios,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(categoriaServicios.isEmpty
                      ? 'Selecciona los servicios'
                      : categoriaServicios.join(', ')),
                ),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Aquí puedes manejar la lógica para guardar o actualizar el empleado
                    if (widget.empleado == null) {
                      // nuevo empleado
                      _nuevoEmpleado(context);
                    } else {
                      // modifica empleado
                      _modificaEmpleado(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(widget.empleado == null ? 'Agregar' : 'Modificar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _subirImagen() async {
    setState(() {
      cargandoFoto = true;
    });
    String pathFireStore = '';
    final empleadoEditado = EmpleadoModel(
      id: id,
      nombre: nombre,
      emailUsuarioApp: _emailSesionUsuario,
      disponibilidad: disponibilidad,
      email: email,
      telefono: telefono,
      categoriaServicios: categoriaServicios,
      foto: pathFireStore,
      color: color,
      codVerif: codVerif,
      roles: roles,
    );

    try {
      final image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 50,
          maxHeight: 600,
          maxWidth: 900);

      // SUBE LA FOTO A FIREBASE STORAGE

      pathFireStore = await FirebaseProvider().subirImagenStorage(
          _emailSesionUsuario, image!.path, empleadoEditado);
      try {
        empleadoEditado.foto = pathFireStore;
        // firebase
        _editaEmpleadoFirebase(empleadoEditado);

        // contexto
        _editaContextoEmpleado(empleadoEditado);

        foto = pathFireStore;
        setState(() {
          cargandoFoto = false;
        });
      } catch (e) {
        debugPrint('Error al modificar el empleado: ${e.toString()}');
      }
    } catch (e) {
      debugPrint('Error de imagen ${e.toString()}');
    }
  }

  void _editaContextoEmpleado(EmpleadoModel empleadoEditado) {
    //contexto empleados
    final providerEmpleado = context.read<EmpleadosProvider>();
    providerEmpleado.modificaEmpleado(empleadoEditado);
    // setea el contexto de empleados personal para acutalizar su lista
    providerEmpleado.setEmpleadosStaff();
  }

  void _nuevoEmpleado(BuildContext context) async {
    String codigoVerificacion = 'verificado';

    // SI EL EMAIL CORRESPONDE CON EL DEL USUARIO DE LA APP , LO DAMOS COMO VERIFICADO
    if (email != _emailSesionUsuario) {
      // GENERACION DE CODIGO DE VERIFICACION DE REGISTROS DE NUEVOS EMPLEADOS
      const uuid = Uuid();
      // Genera un UUID
      String uuidString = uuid.v4();
      // Extraer solo letras de los primeros tres caracteres
      codigoVerificacion = uuidString.substring(0, 3).toUpperCase();
    }

    EmpleadoModel empleadoEditado = EmpleadoModel(
      id: id,
      emailUsuarioApp: _emailSesionUsuario,
      nombre: nombre,
      disponibilidad: disponibilidad,
      email: email,
      telefono: telefono,
      categoriaServicios: categoriaServicios,
      foto: foto,
      color: color,
      codVerif: codigoVerificacion,
      roles: rolesEmpleados,
    );

    try {
      // firebase
      String idEmpleadoGeneradoEnFirebase =
          await _agregaEmpleadoFirebase(empleadoEditado);
      EmpleadoModel empleadoConId =
          empleadoEditado.copyWith(id: idEmpleadoGeneradoEnFirebase);
      agregaEnContexto(empleadoConId);

      _mensajeRegresar();
    } catch (e) {
      debugPrint('Error al agregar el empleado: $e');
    }
  }

  void _modificaEmpleado(BuildContext context) {
    print('id del empleado en el contexto $id');
    final empleadoEditado = EmpleadoModel(
      id: id,
      emailUsuarioApp: _emailSesionUsuario,
      nombre: nombre,
      disponibilidad: disponibilidad,
      email: email,
      telefono: telefono,
      categoriaServicios: categoriaServicios,
      foto: foto,
      color: color,
      codVerif: codVerif,
      roles: rolesEmpleados,
    );

    try {
      // firebase
      _editaEmpleadoFirebase(empleadoEditado);

      // contexto
      _editaContextoEmpleado(empleadoEditado);

      _mensajeRegresar();
    } catch (e) {
      debugPrint('Error al agregar el empleado: $e');
    }
  }

  Future<String> _agregaEmpleadoFirebase(empleadoEditado) async {
    final idEmpleado = await FirebaseProvider()
        .agregaEmpleado(empleadoEditado, _emailSesionUsuario);

    return idEmpleado;
  }

  void _editaEmpleadoFirebase(empleadoEditado) async {
    await FirebaseProvider()
        .editaEmpleado(empleadoEditado, _emailSesionUsuario);
  }

  void agregaEnContexto(EmpleadoModel empleadoConId) {
    // contexto
    final providerEmpleado = context.read<EmpleadosProvider>();
    providerEmpleado.agregaEmpleado(empleadoConId);
    // setea el contexto de empleados personal para acutalizar su lista
    providerEmpleado.setEmpleadosStaff();
  }

  void _mensajeRegresar() {
    if (mounted) {
      // Muestra un mensaje de éxito
      mensajeInfo(context, 'Edición correcta');
      // Navegar hacia atrás
      Navigator.pop(context);
    }
  }

  List<String> obtenerItems(bool hayMenosDeTresStaff) {
    return (hayMenosDeTresStaff ? roles : rolesPersonalInhabilitado)
        .map((rol) => rolEmpleadoToString(rol))
        .toList();
  }

  _enviarEmailInvitacion(idEmpleado) async {
    final providerEmpleado = context.read<EmpleadosProvider>();
    List<EmpleadoModel> empleados = providerEmpleado.getEmpleados;

    // Crear un Completer
    final Completer<void> completer = Completer<void>();

    // Mostrar diálogo de espera con Completer
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre tocando fuera
      builder: (BuildContext context) {
        completer.future.then((_) {
          // Cerramos el diálogo cuando el Completer complete
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return const Center(
          child: CircularProgressIndicator(), // Indicador de carga
        );
      },
    );

    try {
      // Buscar empleado
      final empleado =
          empleados.firstWhere((empleado) => empleado.id == idEmpleado);
      print('id invitacion');
      print(empleado.id);

      // Simular envío de email
      await emailInvitacion(empleado, _emailSesionUsuario);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitación enviada correctamente')),
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar la invitación: $e')),
      );
    } finally {
      // Completar el Completer para cerrar el diálogo
      completer.complete();
    }
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final List<dynamic> initialSelectedItems;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.items,
    required this.initialSelectedItems,
  });

  @override
  MultiSelectDialogState createState() => MultiSelectDialogState();
}

class MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(item),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedItems);
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
