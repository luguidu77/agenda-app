// Enum para los roles de empleados
enum RolEmpleado {
  personal,
  gerente,
  administrador,
}

class EmpleadoModel {
  String id;
  String emailUsuarioApp;
  String nombre;
  List<dynamic> disponibilidad;
  String email;
  String telefono;
  List<dynamic> categoriaServicios;
  String foto;
  int color;
  String codVerif;
  List<RolEmpleado> roles;

  // Constructor
  EmpleadoModel({
    required this.id,
    required this.emailUsuarioApp,
    required this.nombre,
    required this.disponibilidad,
    required this.email,
    required this.telefono,
    required this.categoriaServicios,
    required this.foto,
    required this.color,
    required this.codVerif,
    required this.roles,
  });
  EmpleadoModel copyWith({
    String? id,
    String? emailUsuarioApp,
    String? nombre,
    List<dynamic>? disponibilidad,
    String? email,
    String? telefono,
    List<dynamic>? categoriaServicios,
    String? foto,
    int? color,
    String? codVerif,
    List<RolEmpleado>? roles,
  }) {
    return EmpleadoModel(
      id: id ?? this.id,
      emailUsuarioApp: emailUsuarioApp ?? this.emailUsuarioApp,
      nombre: nombre ?? this.nombre,
      disponibilidad: disponibilidad ?? this.disponibilidad,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      categoriaServicios: categoriaServicios ?? this.categoriaServicios,
      foto: foto ?? this.foto,
      color: color ?? this.color,
      codVerif: codVerif ?? this.codVerif,
      roles: roles ?? this.roles,
    );
  }

  // Factory constructor para crear una instancia de EmpleadoModel desde un mapa (por ejemplo, datos de Firebase)
  factory EmpleadoModel.fromMap(Map<String, dynamic> map) {
    return EmpleadoModel(
      id: map['id'] ?? '',
      emailUsuarioApp: map['emailUsuarioApp'] ?? '',
      nombre: map['nombre'] ?? '',
      disponibilidad: List<dynamic>.from(map['disponibilidad'] ?? []),
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      categoriaServicios: List<dynamic>.from(map['categoriaServicios'] ?? []),
      foto: map['foto'] ?? '',
      color: map['color'] ??
          '#FFFFFF', // Valor por defecto para color si no está definido
      codVerif: map['cod_verif'] ?? '',
      roles: (map['rol'] as List<dynamic>? ?? [])
          .map((rol) => _stringToRolEmpleado(rol as String))
          .toList(),
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
      'color': color, // Agregar color al mapa
      'cod_verif': codVerif,
      'rol': roles.map((rol) => _rolEmpleadoToString(rol)).toList(),
    };
  }

  // Método privado para convertir un String a RolEmpleado
  static RolEmpleado _stringToRolEmpleado(String role) {
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

  // Método privado para convertir un RolEmpleado a String
  static String _rolEmpleadoToString(RolEmpleado role) {
    return role.name; // name es equivalente al String del Enum (ej. 'staff')
  }
}
