import 'package:flutter/material.dart';

import '../models/models.dart';
import '../providers/providers.dart';

StreamBuilder<PerfilModel> denominacionNegocio(emailSesionUsuario,
    {color = Colors.black, size = 18.0}) {
  return StreamBuilder(
      stream: FirebaseProvider().cargarPerfilFB(emailSesionUsuario).asStream(),
      builder: ((context, AsyncSnapshot<PerfilModel> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;

          return Text(
            data!.denominacion.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size,
              color: color,
              shadows: [
                Shadow(
                  offset: const Offset(2.0, 2.0), // Desplazamiento de la sombra
                  blurRadius: 5.0, // Radio de desenfoque de la sombra
                  color: Colors.black.withOpacity(0.5), // Color de la sombra
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      }));
}
