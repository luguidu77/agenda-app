class NegocioModel {
  final String id;
  final String denominacion;
  final String direccion;
  final String ubicacion;
  final String email;
  final String telefono;
  final String imagen;
  final String moneda;
  final double latitud;
  final double longitud;
  final String valoracion;
  final String categoria;
  final dynamic servicios;
  final String tokenMessaging;
  final String descripcion;
  final String facebook;
  final String instagram;
  final dynamic horarios;
  final bool destacado; // Propiedad booleana
  final bool publicado; // Propiedad booleana
  final Map<String, dynamic> blog; // Nuevo campo

  NegocioModel({
    required this.id,
    required this.denominacion,
    required this.direccion,
    required this.ubicacion,
    required this.email,
    required this.telefono,
    required this.imagen,
    required this.moneda,
    required this.latitud,
    required this.longitud,
    required this.valoracion,
    required this.categoria,
    required this.servicios,
    required this.tokenMessaging,
    required this.descripcion,
    required this.facebook,
    required this.instagram,
    required this.horarios,
    required this.destacado,
    required this.publicado,
    required this.blog, // Agregamos el nuevo campo al constructor
  });

  // Constructor de fábrica para crear una instancia de NegocioModel a partir de un mapa
  factory NegocioModel.fromMap(Map<String, dynamic> map) {
    return NegocioModel(
      id: map['id'],
      denominacion: map['denominacion'],
      direccion: map['direccion'],
      ubicacion: map['ubicacion'],
      email: map['usuario'],
      telefono: map['usuario'],
      imagen: map['imagen'],
      moneda: map['moneda'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      valoracion: map['valoracion'],
      categoria: map['categoria'],
      servicios: map['servicios'],
      tokenMessaging: map['tokenMessaging'],
      descripcion: map['descripcion'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      horarios: map['horarios'],
      destacado: map['destacado'] ?? false,
      publicado: map['publicado'] ?? false,
      blog: map['blog'], // Agregamos el nuevo campo al constructor
    );
  }
}
