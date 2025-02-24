import 'package:flutter/material.dart';

import '../models/models.dart';
import '../providers/providers.dart';

StreamBuilder<PerfilAdministradorModel> denominacionNegocio(emailSesionUsuario,
    {color = Colors.white, size = 18.0}) {
  return StreamBuilder(
      stream: FirebaseProvider().cargarPerfilFB(emailSesionUsuario).asStream(),
      builder: ((context, AsyncSnapshot<PerfilAdministradorModel> snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;

          return InkWell(
            onTap: () =>
                Navigator.pushNamed(context, 'ConfigPerfilAdminstrador'),
            child: Text(
              data!.denominacion.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size,
                color: color,
              ),
            ),
          );
        }
        return const SizedBox();
      }));
}
