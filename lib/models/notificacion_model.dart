class NotificacionModel {
  final String id;

  final String iconoCategoria;
  final bool visto;
  final String data; // Nuevo campo para datos adicionales

  NotificacionModel({
    required this.id,
    required this.iconoCategoria,
    required this.visto,
    required this.data,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'] ?? '',

      iconoCategoria: json['iconoCategoria'] ?? '',
      visto: json['visto'] ?? false,
      data: json['data'], // Lee los datos adicionales desde el JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconoCategoria': iconoCategoria,
      'visto': visto,
      'data': data,
    };
  }
}
