class PersonalizaModel {
  int? id;
  int? codpais;
  String? mensaje;
  String? enlace;
  String? moneda;

  PersonalizaModel(
      {this.id, this.codpais, this.mensaje, this.enlace, this.moneda});

  factory PersonalizaModel.fromJson(Map<String, dynamic> json) =>
      PersonalizaModel(
        id: json["id"],
        codpais: json["codpais"],
        mensaje: json["mensaje"],
        enlace: json["enlace"],
        moneda: json["moneda"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "codpais": codpais,
        "mensaje": mensaje,
        "enlace": enlace,
        "moneda": moneda,
      };
}
