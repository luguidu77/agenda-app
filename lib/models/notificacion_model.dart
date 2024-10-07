import 'package:cloud_firestore/cloud_firestore.dart';

class NotificacionModel {
  final String id;

  final String iconoCategoria;
  final bool? visto;
  final String data; // Nuevo campo para datos adicionales
  final Timestamp fechaNotificacion;
  final List<dynamic>? vistoPor;
  final String? texto;
  final String? link;

  NotificacionModel({
    required this.id,
    required this.iconoCategoria,
    this.visto,
    required this.data,
    required this.fechaNotificacion,
    this.vistoPor,
    this.texto,
    this.link,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: json['id'] ?? '',

      iconoCategoria: json['iconoCategoria'] ?? '',
      visto: json['visto'] ?? false,
      fechaNotificacion: json['fechaNotificacion'],
      data: json['data'], // Lee los datos adicionales desde el JSON
      vistoPor: json['vistoPor'],
      texto: json['texto'], link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iconoCategoria': iconoCategoria,
      'visto': visto,
      'fechaNotificacion': fechaNotificacion,
      'data': data,
      'vistoPor': vistoPor,
      'texto': texto,
      'link': link,
    };
  }
}
