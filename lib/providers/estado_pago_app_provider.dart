import 'package:flutter/material.dart';

class EstadoPagoApp with ChangeNotifier {
  String _perfil = 'INITIAL';

// _perfil ES LA DATA QUE SE ENVIA AL HACER UN  final perfil = await Provider.of<PerfilUsuarioAppProvider>(context, listen: false);
  String get perfil => _perfil;

  //      [true/false, true/false];
  set perfil(String newperfil) {
    _perfil = newperfil;
    notifyListeners();
  }

  Future<String> perfilPorPago(bool pago, String usuarioAPP) async {
    String perfilUsuario = '';
    bool email = usuarioAPP != '' ? true : false;

    if (!pago & !email) {
      perfilUsuario = 'GRATUITA';
    }
    if (!pago & email) {
      perfilUsuario = 'PRUEBA_ACTIVA';
    }
    if (pago) {
      perfilUsuario = 'COMPRADA';
    }

    return perfilUsuario;
  }
}
