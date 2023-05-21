class PlanAmigoModel {
  int? id;

  String? email;

  PlanAmigoModel({
    this.id,
    this.email,
  });

  factory PlanAmigoModel.fromJson(Map<String, dynamic> json) => PlanAmigoModel(
        id: json["id"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
      };
}
