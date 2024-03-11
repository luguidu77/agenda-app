import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/notificacion_model.dart';
import '../providers/providers.dart';
import '../widgets/botones/boton_ledido.dart';

class PaginaNotificacionesScreen extends StatefulWidget {
  const PaginaNotificacionesScreen({super.key});

  @override
  State<PaginaNotificacionesScreen> createState() =>
      _PaginaNotificacionesScreenState();
}

class _PaginaNotificacionesScreenState
    extends State<PaginaNotificacionesScreen> {
  late String _emailSesionUsuario;

  inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  @override
  void initState() {
    inicializacion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
        ),
        body: FutureBuilder(
          future: FirebaseProvider()
              .getTodasLasNotificacionesCitas(_emailSesionUsuario),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              // Aquí puedes construir la lista de ListTiles con los datos obtenidos

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                            icon: const Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _eliminaLedidas(_emailSesionUsuario),
                            label: const Text('Borrar leídas')),
                      ],
                    ),
                  ),
                  const Divider(),
                  (snapshot.data.length < 1)
                      ? Padding(
                          padding: const EdgeInsets.only(top: 58.0),
                          child: SizedBox(
                              height: 200,
                              width: 200,
                              child:
                                  Image.asset('assets/images/caja-vacia.png')),
                        )
                      : Expanded(
                          child: ListView.separated(
                            itemCount: snapshot.data!.length,
                            separatorBuilder: (context, index) =>
                                const Divider(), // Separador entre grupos de notificaciones
                            itemBuilder: (context, index) {
                              final notificacion = snapshot.data![index];
                              final notificacionModelo = NotificacionModel(
                                  id: notificacion['id'],
                                  fechaNotificacion:
                                      notificacion['fechaNotificacion'],
                                  iconoCategoria: notificacion['categoria'],
                                  visto: notificacion['visto'],
                                  data: notificacion['data']);

                              String fechaNotificacion = _formateaFecha(
                                  notificacionModelo.fechaNotificacion);
                              Map<String, dynamic> data =
                                  jsonDecode(notificacionModelo.data);
                              final (:nombre, :telefono) =
                                  _obtieneCliente(data);
                              final (:fecha, :hora) = _obtieneCita(data);

                              // Tarjeta de notificación
                              return _tarjetasNotificaciones(
                                  _emailSesionUsuario,
                                  fechaNotificacion,
                                  notificacion,
                                  fecha,
                                  hora,
                                  nombre,
                                  telefono);
                            },
                          ),
                        ),
                ],
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

  // *** tarjetas de las notificaciones ***************************************
  Widget _tarjetasNotificaciones(
      emailSesionUsuario,
      String fechaNotificacion,
      Map<String, dynamic> notificacion,
      String fecha,
      String hora,
      String nombre,
      String telefono) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () {}, // Aquí puedes agregar la acción deseada
          child: Text(fechaNotificacion),
        ),
        ListTile(
          // Contenido de la tarjeta de notificación
          leading: Column(
            children: [
              _obtieneIcono(notificacion['categoria']),
              _obtieneTextoCategoria(notificacion['categoria'])
            ],
          ),
          title: Text(nombre),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$fecha-$hora"),
              Text('Teléfono: $telefono'),
            ],
          ),
          trailing: BotonLedido(
              notificacion: notificacion,
              emailSesionUsuario: emailSesionUsuario),
        ),
      ],
    );
  }

  // ***************************************************************************

  String _formateaFecha(Timestamp fechaNotificacion) {
    Timestamp timestamp = fechaNotificacion;

    // Convertir el Timestamp a DateTime
    DateTime dateTime = timestamp.toDate();

    // Formatear el DateTime según el formato deseado
    String fechaFormateada = DateFormat('dd/MM/yy HH:mm').format(dateTime);
    print("Fecha formateada: $fechaFormateada");
    return fechaFormateada;
  }

  _eliminaLedidas(emailSesionUsuario) async {
    await FirebaseProvider().eliminaLeidas(emailSesionUsuario);
    setState(() {});
  }
}

Icon _obtieneIcono(String categoria) {
  return switch (categoria) {
    'cita' => const Icon(Icons.offline_share_outlined),
    'citaweb' => const Icon(Icons.cloud_done),
    _ => const Icon(Icons.data_array_rounded),
  };
}

Text _obtieneTextoCategoria(String categoria) {
  return switch (categoria) {
    'cita' => const Text('CITA', style: TextStyle(fontSize: 8)),
    'citaweb' => const Text('CITA', style: TextStyle(fontSize: 8)),
    _ => const Text('N/A', style: TextStyle(fontSize: 8)),
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
