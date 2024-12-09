import 'package:flutter/material.dart';
import 'package:agendacitas/models/empleado_model.dart';

class EmpleadoEdicion extends StatefulWidget {
  final EmpleadoModel? empleado;

  const EmpleadoEdicion({super.key, this.empleado});

  @override
  EmpleadoEdicionState createState() => EmpleadoEdicionState();
}

class EmpleadoEdicionState extends State<EmpleadoEdicion> {
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

  final List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  final List<String> servicios = [
    'Servicio 1',
    'Servicio 2',
    'Servicio 3',
    'Servicio 4',
    'Servicio 5'
  ];

  @override
  void initState() {
    super.initState();
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
    } else {
      id = '';
      nombre = '';
      disponibilidad = [];
      email = '';
      telefono = '';
      categoriaServicios = [];
      foto = '';
      color = 0xFFFFFFFF;
      codVerif = '';
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
                  onTap: () => Navigator.pop(context, 0xFFFF0000),
                  child: Container(
                    color: const Color(0xFFFF0000),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFF00FF00),
                  child: Container(
                    color: const Color(0xFF00FF00),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFF0000FF),
                  child: Container(
                    color: const Color(0xFF0000FF),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFFFFFF00),
                  child: Container(
                    color: const Color(0xFFFFFF00),
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 0xFFFF00FF),
                  child: Container(
                    color: const Color(0xFFFF00FF),
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
                child: Card(
                  color: Colors.red[200],
                  child: Column(
                    children: [
                      Text(
                          style: const TextStyle(color: Colors.white),
                          '$nombre no ha completado su registro,\nfacilítale su código de verificación:'),
                      Text(
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 19),
                        ' $codVerif',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(foto),
                    radius: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.photo_size_select_actual_rounded,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
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
                initialValue: email,
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
              const Text('Disponibilidad Semanal:'),
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
              const Text('Categoría de Servicios:'),
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
                    Navigator.pop(context);
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
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialSelectedItems;

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
