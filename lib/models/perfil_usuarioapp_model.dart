class PerfilUsuarioAppModel {
  int? id;
  String? perfil;

  PerfilUsuarioAppModel({
    this.id,
    this.perfil,
  });

  factory PerfilUsuarioAppModel.fromJson(Map<String, dynamic> json) =>
      PerfilUsuarioAppModel(
        id: json["id"],
        perfil: json["perfil"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "perfil": perfil,
      };
}
