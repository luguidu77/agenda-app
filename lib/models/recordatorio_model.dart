class RecordatorioModel {
  int? id;
  String? idRecordatorio;
  String? fecha;

  RecordatorioModel({
    this.id,
    this.idRecordatorio,
    this.fecha,
  });

  factory RecordatorioModel.fromJson(Map<String, dynamic> json) =>
      RecordatorioModel(
        id: json["id"],
        idRecordatorio: json["idRecordatorio"],
        fecha: json["fecha"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "idRecordatorio": idRecordatorio,
        "fecha": fecha,
      };
}
