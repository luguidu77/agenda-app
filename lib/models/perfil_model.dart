class PerfilModel {
  String? denominacion;
  String? descripcion;
  String? facebook;
  String? instagram;
  String? foto;
  String? telefono;
  String? ubicacion;
  String? website;

  PerfilModel({
    this.denominacion,
    this.descripcion,
    this.facebook,
    this.instagram,
    this.foto,
    this.telefono,
    this.ubicacion,
    this.website,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) => PerfilModel(
        denominacion: json["denominacion"],
        descripcion: json["descripcion"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        foto: json["foto"],
        telefono: json["telefono"],
        ubicacion: json["ubicacion"],
        website: json["website"],
      );

  Map<String, dynamic> toJson() => {
        "denominacion": denominacion,
        "descripcion": descripcion,
        "facebook": facebook,
        "instagram": instagram,
        "foto": foto,
        "telefono": telefono,
        "ubicacion": ubicacion,
        "website": website,
      };
}
