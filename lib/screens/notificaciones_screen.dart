import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/notificacion_model.dart';
import '../providers/providers.dart';

class PaginaNotificacionesScreen extends StatefulWidget {
  const PaginaNotificacionesScreen({super.key});

  @override
  State<PaginaNotificacionesScreen> createState() =>
      _PaginaNotificacionesScreenState();
}

class _PaginaNotificacionesScreenState
    extends State<PaginaNotificacionesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
        ),
        body: FutureBuilder(
          future: FirebaseProvider()
              .getTodasLasNotificacionesCitas('ritagiove@hotmail.com'),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              // Aquí puedes construir la lista de ListTiles con los datos obtenidos

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final notificacion = snapshot.data![index];

                  final notificacionModelo = NotificacionModel(
                      id: notificacion['id'],
                      iconoCategoria: notificacion['categoria'],
                      visto: notificacion['visto'],
                      data: notificacion['data']);

                  Map<String, dynamic> data =
                      jsonDecode(notificacionModelo.data);
                  debugPrint(data.toString());

                  final (:nombre, :telefono) = _obtieneCliente(data);

                  final (:fecha, :hora) = _obtieneCita(data);

                  return ListTile(
                    leading: _obtieneIcono(notificacion['categoria']),
                    title: Text('$fecha-$hora'),
                    subtitle: Text('$nombre-$telefono'),
                    // Puedes agregar más contenido según tus necesidades

                    trailing: Icon(notificacion['visto']
                        ? Icons.mark_chat_read_outlined
                        : Icons.mark_chat_unread_outlined),
                  );
                },
              );
            } else {
              // Si no hay datos, puedes mostrar un mensaje indicando que no hay notificaciones
              return const Center(
                child: Text('No hay notificaciones disponibles'),
              );
            }
          },
        ));
  }
}

Icon _obtieneIcono(String categoria) {
  return switch (categoria) {
    'cita' => const Icon(Icons.calendar_today_rounded),
    _ => const Icon(Icons.no_crash_outlined),
  };
}

({String fecha, String hora}) _obtieneCita(data) {
  String fechaCita = data['fechaCita']['fechaFormateada'];
  String horaCita = data['fechaCita']['horaFormateada'];

  return (fecha: fechaCita, hora: horaCita);
}

({String nombre, String telefono}) _obtieneCliente(data) {
  String nombreCliente = data['cliente']['nombre'];
  String telefonoCliente = data['cliente']['telefono'];

  return (nombre: nombreCliente, telefono: telefonoCliente);
}
