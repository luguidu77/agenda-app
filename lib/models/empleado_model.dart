class EmpleadoModel {
  String id;
  String nombre;
  List<dynamic> disponibilidad;
  String email;
  String telefono;
  List<dynamic> categoriaServicios;
  String foto;

  // Constructor
  EmpleadoModel({
    required this.id,
    required this.nombre,
    required this.disponibilidad,
    required this.email,
    required this.telefono,
    required this.categoriaServicios,
    required this.foto,
  });

  // Factory constructor para crear una instancia de EmpleadoModel desde un mapa (por ejemplo, datos de Firebase)
  factory EmpleadoModel.fromMap(Map<String, dynamic> map) {
    return EmpleadoModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      disponibilidad: List<dynamic>.from(map['disponibilidad'] ?? []),
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      categoriaServicios: List<dynamic>.from(map['categoriaServicios'] ?? []),
      foto: map['foto'] ?? '',
    );
  }

  // Método para convertir la instancia en un mapa (por ejemplo, para guardar en Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'disponibilidad': disponibilidad,
      'email': email,
      'telefono': telefono,
      'categoriaServicios': categoriaServicios,
      'foto': foto,
    };
  }
}
