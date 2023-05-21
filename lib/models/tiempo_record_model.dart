class TiempoRecordatorioModel {
  int? id;
  String? tiempo;

  TiempoRecordatorioModel({
    this.id,
    this.tiempo,
  });

  factory TiempoRecordatorioModel.fromJson(Map<String, dynamic> json) =>
      TiempoRecordatorioModel(
        id: json["id"],
        tiempo: json["tiempo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tiempo": tiempo,
      };
}
