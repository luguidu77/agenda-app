class PerfilModel {
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

  PerfilModel({
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

  factory PerfilModel.fromJson(Map<String, dynamic> json) => PerfilModel(
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
        "fechaRegistro":
            fechaRegistro != null ? fechaRegistro!.toIso8601String() : null,
        "appPagada": appPagada,
        "email": email, // Nuevo campo
      };
}
