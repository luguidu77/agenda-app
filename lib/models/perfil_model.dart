class PerfilAdministradorModel {
  String? id; // Nuevo campo
  String? denominacion;
  String? descripcion;
  String? facebook;
  String? instagram;
  String? foto;
  String? telefono;
  String? ubicacion;
  String? website;
  String? moneda;
  List<String>? servicios;
  String? tokenMessaging;
  String? ciudad;
  List<Map<String, dynamic>>? horarios;
  String? informacion;
  String? normas;
  double? latitud;
  double? longitud;
  DateTime? fechaRegistro;
  bool? appPagada;
  String? email; // Nuevo campo

  PerfilAdministradorModel({
    this.id, // Nuevo campo
    this.denominacion,
    this.descripcion,
    this.facebook,
    this.instagram,
    this.foto,
    this.telefono,
    this.ubicacion,
    this.website,
    this.moneda,
    this.servicios,
    this.tokenMessaging,
    this.ciudad,
    this.horarios,
    this.informacion,
    this.normas,
    this.latitud,
    this.longitud,
    this.fechaRegistro,
    this.appPagada,
    this.email, // Nuevo campo
  });

  factory PerfilAdministradorModel.fromJson(Map<String, dynamic> json) =>
      PerfilAdministradorModel(
        id: json["id"], // Nuevo campo
        denominacion: json["denominacion"],
        descripcion: json["descripcion"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        foto: json["foto"],
        telefono: json["telefono"],
        ubicacion: json["ubicacion"],
        website: json["website"],
        moneda: json["moneda"],
        servicios: List<String>.from(json["servicios"].map((x) => x)),
        tokenMessaging: json["tokenMessaging"],
        ciudad: json["ciudad"],
        horarios:
            List<Map<String, dynamic>>.from(json["horarios"].map((x) => x)),
        informacion: json["informacion"],
        normas: json["normas"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        fechaRegistro: json["fechaRegistro"] != null
            ? DateTime.parse(json["fechaRegistro"])
            : null,
        appPagada: json["appPagada"],
        email: json["email"], // Nuevo campo
      );

  Map<String, dynamic> toJson() => {
        "id": id, // Nuevo campo
        "denominacion": denominacion,
        "descripcion": descripcion,
        "facebook": facebook,
        "instagram": instagram,
        "foto": foto,
        "telefono": telefono,
        "ubicacion": ubicacion,
        "website": website,
        "moneda": moneda,
        "servicios": servicios,
        "tokenMessaging": tokenMessaging,
        "ciudad": ciudad,
        "horarios": horarios,
        "informacion": informacion,
        "normas": normas,
        "latitud": latitud,
        "longitud": longitud,
        "fechaRegistro": fechaRegistro?.toIso8601String(),
        "appPagada": appPagada,
        "email": email, // Nuevo campo
      };
}

class PerfilEmpleadoModel {
  String? nombre;
  List<dynamic>? categoriaServicios;
  String? codVerif;
  int? color;
  List<dynamic>? disponibilidadSemanal;
  String? email;
  String? emailUsuarioApp;
  String? foto;
  List<String>? rol;
  String? telefono;

  PerfilEmpleadoModel({
    this.nombre,
    this.categoriaServicios,
    this.codVerif,
    this.color,
    this.disponibilidadSemanal,
    this.email,
    this.emailUsuarioApp,
    this.foto,
    this.rol,
    this.telefono,
  });

  // Factory constructor para inicializar desde un mapa
  factory PerfilEmpleadoModel.fromMap(Map<String, dynamic> map) {
    return PerfilEmpleadoModel(
      nombre: map['nombre'] ?? '',
      categoriaServicios: List<dynamic>.from(map['categoriaServicios'] ?? []),
      codVerif: map['cod_verif'] ?? '',
      color: map['color'] ?? 0,
      disponibilidadSemanal:
          List<dynamic>.from(map['disponibilidadSemanal'] ?? []),
      email: map['email'] ?? '',
      emailUsuarioApp: map['emailUsuarioApp'] ?? '',
      foto: map['foto'] ?? '',
      rol: List<String>.from(map['rol'] ?? []),
      telefono: map['telefono'] ?? '',
    );
  }

  // Método para convertir el modelo a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'categoriaServicios': categoriaServicios,
      'cod_verif': codVerif,
      'color': color,
      'disponibilidadSemanal': disponibilidadSemanal,
      'email': email,
      'emailUsuarioApp': emailUsuarioApp,
      'foto': foto,
      'rol': rol,
      'telefono': telefono,
    };
  }
}
