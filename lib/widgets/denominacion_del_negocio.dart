import 'package:flutter/material.dart';

import '../models/models.dart';
import '../providers/providers.dart';

StreamBuilder<PerfilModel> denominacionNegocio(emailSesionUsuario,
    {color = Colors.white, size = 20.0}) {
  return StreamBuilder(
      stream: FirebaseProvider().cargarPerfilFB(emailSesionUsuario).asStream(),
      builder: ((context, AsyncSnapshot<PerfilModel> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;

          return Text(
            data!.denominacion.toString(),
            style: TextStyle(
              fontSize: size,
              color: color,
            ),
          );
        }
        return const SizedBox();
      }));
}
