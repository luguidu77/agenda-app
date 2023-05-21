class PagoModel {
  int? id;
  String? pago;
  String? email;

  PagoModel({
    this.id,
    this.pago,
    this.email,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) => PagoModel(
        id: json["id"],
        pago: json["pago"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pago": pago,
        "email": email,
      };
}
