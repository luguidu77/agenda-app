import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/.configuraciones.dart';
import '../utils/utils.dart';

class EstadoPagoAppProvider extends ChangeNotifier {
  String _estadoPagadaApp = 'INITIAL';
  String _emailUsuarioApp = '';

// _perfil ES LA DATA QUE SE ENVIA AL HACER UN  final perfil = await Provider.of<PerfilUsuarioAppProvider>(context, listen: false);
  String get estadoPagoApp => _estadoPagadaApp;

  String get emailUsuarioApp => _emailUsuarioApp;

  estadoPagoEmailApp(String usuarioAPP) async {
    bool email = usuarioAPP != '' ? true : false;

    switch (email) {
      case false:
        _estadoPagadaApp = 'GRATUITA';
        // notifyListeners();
        debugPrint('#######   estado ###### GRATUITA');
        break;

      case true:
        print('------------------------usuarioapp provider $usuarioAPP');
        // asigno el email de usuario

        _emailUsuarioApp = usuarioAPP;
        notifyListeners();

        //?  si hay usuario disponible, seteo en provider la disponibilidad semanal para el servicio

        // ignore: use_build_context_synchronously
        //  await DisponibilidadSemanal.disponibilidadSemanal(context,
        //      usuarioAPP); // diasNoDisponibles desde la carpeta utils    //Lunes = 1, Martes = 2,Miercoles =3....Domingo = 7

        // verifica pago en perfil usuario FB
        bool? pago = await FirebaseProvider().compruebaPagoFB(usuarioAPP);

        if (pago) {
          _estadoPagadaApp = 'COMPRADA';

          // notifyListeners();
          debugPrint('#######   estado ###### COMPRADA');
        } else {
          // comprueba tiempo registro
          bool pruebaActiva = await compruebaTiempoRegistro(usuarioAPP);
          pruebaActiva
              ? _estadoPagadaApp = 'PRUEBA_ACTIVA'
              : _estadoPagadaApp = 'PRUEBA_CADUCADA';
          debugPrint('#######   estado ###### $_estadoPagadaApp');
          //  notifyListeners();
        }

        break;
    }
  }

  Future<bool> compruebaTiempoRegistro(String usuarioAPP) async {
    bool pruebaActiva = false;

    try {
      // ignore: await_only_futures necesario el await para esperar retorno
      await FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          DateTime now = DateTime.now();
          DateTime fecha =
              DateTime.parse(user.metadata.creationTime.toString());
          debugPrint(
              '##  LOS DIAS DE PRUEBA LOS CONFIGURO EN config/.configuracions.dart ##');
          Duration diasDePrueba = perido_de_prueba;

          if (now.subtract(diasDePrueba).isAfter(fecha)) {
            debugPrint('fecha cumplida prueba caducada');
            pruebaActiva = false;
            /*  Navigator.pushReplacementNamed(
                  context, 'finalizacionPruebaScreen',
                  arguments: {
                    'usuarioAPP': user.email.toString(),
                  }); */
          } else {
            pruebaActiva = true;
            debugPrint('en tiempo prueba gratuita');
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    return pruebaActiva;
  }
}
