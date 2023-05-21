class TemaModel {
  int? id;
  int? color;

  TemaModel({
    this.id,
    this.color,
  });

  factory TemaModel.fromJson(Map<String, dynamic> json) => TemaModel(
        id: json["id"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "color": color,
      };
}
