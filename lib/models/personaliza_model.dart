/* class PersonalizaModel {
  int? id;
  int? codpais;
  String? mensaje;
  String? enlace;
  String? moneda;

  PersonalizaModel({
    this.id,
    this.codpais,
    this.mensaje,
    this.enlace,
    this.moneda,
  });

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
} */

class PersonalizaModelFirebase {
  String? id;
  String? codpais;
  String? enlace;
  String? moneda;
  String? mensaje;
  String? colorTema;
  String? tiempoRecordatorio;
  //horario de apertura y cierre de la app . ? deberia ser coordinado con la

  PersonalizaModelFirebase({
    this.id,
    this.codpais,
    this.enlace,
    this.moneda,
    this.mensaje,
    this.colorTema,
    this.tiempoRecordatorio,
  });

  factory PersonalizaModelFirebase.fromJson(Map<String, dynamic> json) =>
      PersonalizaModelFirebase(
        id: json["id"],
        codpais: json["codpais"],
        enlace: json["enlace"],
        moneda: json["moneda"],
        mensaje: json["mensaje"],
        colorTema: json["color_tema"],
        tiempoRecordatorio: json["tiempo_recordatorio"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "codpais": codpais,
        "enlace": enlace,
        "moneda": moneda,
        "mensaje": mensaje,
        "color_tema": colorTema,
        "tiempo_recordatorio": tiempoRecordatorio,
      };
}
