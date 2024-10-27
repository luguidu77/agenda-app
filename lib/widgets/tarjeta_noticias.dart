import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TarjetaNoticias extends StatefulWidget {
  final List<dynamic> notificaciones;
  final String emailSesionUsuario;
  const TarjetaNoticias({
    super.key,
    required this.notificaciones,
    required this.emailSesionUsuario,
  });

  @override
  State<TarjetaNoticias> createState() => _TarjetaNoticiasState();
}

class _TarjetaNoticiasState extends State<TarjetaNoticias> {
  bool _visto = false;
  List<dynamic> pruebas = [];

  @override
  Widget build(BuildContext context) {
    // Ordenamos las notificaciones por fecha, de más reciente a más antigua
    widget.notificaciones.sort((a, b) {
      return (b['fechaNotificacion'] as Timestamp)
          .compareTo(a['fechaNotificacion'] as Timestamp);
    });

    return Expanded(
        child: ListView.separated(
            itemCount: widget.notificaciones.length,
            separatorBuilder: (context, index) => Container(),
            itemBuilder: (context, index) {
              final notificacion = widget.notificaciones[index];

              return tarjetas(notificacion);
            }));
  }

  Widget tarjetas(notificacion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.grey[300]!, width: 1), // Borde gris tenue
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alineación a la izquierda
          children: [
            Text(
              notificacion['data'], // Añadimos un título
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fecha(notificacion['fechaNotificacion']),
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.grey[400], // Texto más sutil
                    height:
                        1.5, // Espaciado entre líneas para mayor legibilidad
                  ),
                ),

                /// testigo notificacion vista
                Badge(
                  isLabelVisible: !notificacion['vistoPor']
                      .contains(widget.emailSesionUsuario),
                  backgroundColor: Colors.blue,
                  smallSize: 18.0, // Ajuste para hacerlo más grande
                  largeSize:
                      25.0, // Ajuste para hacerlo más grande en contextos mayores
                )
              ],
            ),
            const SizedBox(height: 8.0), // Espacio entre título y contenido
            Text(
              notificacion['texto'].toString(),
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[900], // Texto más sutil
                height: 1.5, // Espaciado entre líneas para mayor legibilidad
              ),
            ),
            const SizedBox(height: 30.0), // Espacio entre el texto y el botón

            notificacion['link'] != ''
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cambiar estado en Firebase
                        await FirebaseProvider()
                            .cambiarEstadoVistoNotifAdministrador(
                          widget.emailSesionUsuario,
                          notificacion['id'],
                        );

                        launchUrlString(notificacion['link']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Color del botón
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Botón redondeado
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), // Tamaño del botón
                      ),
                      child: Text(
                        notificacion['textoBoton'],
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.white),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  String fecha(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    String formattedDate =
        DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES').format(date);
    return formattedDate;
  }
}
