import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../providers.dart';

fotoPerfil(emailSesionUsuario) {
  try {
    return StreamBuilder(
        stream:
            FirebaseProvider().cargarPerfilFB(emailSesionUsuario).asStream(),
        builder: ((context, AsyncSnapshot<PerfilAdministradorModel> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            return CircleAvatar(
              backgroundColor: Colors.transparent,
              child: data!.foto != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: './assets/icon/galeria-de-fotos.gif',
                        image: data.foto.toString(),
                        fit: BoxFit.fill,
                        imageScale: 1.5,
                        //width: 500
                      ),
                    )
                  : Image.asset('./assets/icon/icon.png'),
            );
          }
          return const CircleAvatar();
        }));
  } catch (e) {
    debugPrint(e.toString());
  }
}
