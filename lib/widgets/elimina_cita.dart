import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../providers/providers.dart';
import '../utils/utils.dart';

mensajeAlerta(BuildContext context, int index, citas,
    bool iniciadaSesionUsuario, String emailusuario) async {
  bool respuesta = false;
  late String textoNombre;
  late dynamic idCita;
  print(citas is List);

  if (citas is List) {
    textoNombre = citas[index]['nombre'].toString();
    (textoNombre == 'null')
        ? textoNombre = 'NO DISPONIBLE'
        : textoNombre = citas[index]['nombre'];

    idCita = citas[index]['id'];
  } else {
    textoNombre = citas['nombre'].toString();
    idCita = citas['id'].toString();
  }
  print(idCita);

  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
            title: const Icon(
              Icons.warning,
              color: Colors.red,
            ),
            content: Text('¿ Quieres eliminar la cita de $textoNombre ?'),
            actions: [
              ElevatedButton.icon(
                  onPressed: () {
                    iniciadaSesionUsuario
                        //ELIMINA CITA EN FIREBASE
                        ? _eliminarCitaFB(emailusuario, idCita)
                        //ELIMINA CITA EN DISPOSITIVO
                        : _eliminarCita(context, idCita, textoNombre);

                    
                    respuesta = true;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Eliminar')),
              const SizedBox(
                width: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    //  setState(() {});
                  },
                  child: const Text(
                    ' No ',
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          ));
  return respuesta;
}

void _eliminarCitaFB(usuarioAPP, id) {
  SincronizarFirebase().eliminaCitaId(usuarioAPP, id.toString());
  // convierto el id que viene como String en int
  int idEntero = convertirIdEnEntero(id);
  //elimina recordatorio de la cita
  eliminaRecordatorio(idEntero);
  // setState(() {});
}

void _eliminarCita(context, int id, String nombreClienta) async {
  await CitaListProvider().elimarCita(id);
  _mensajeEliminado(context, nombreClienta.toString());
  //elimina recordatorio de la cita
  eliminaRecordatorio(id);
  //setState(() {});
}

_mensajeEliminado(context, String nombreClienta) {
  nombreClienta == 'null'
      ? nombreClienta = 'NO DISPONIBLE'
      : nombreClienta = nombreClienta;
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      message: '🗑️ CITA DE $nombreClienta ELIMINADA',
    ),
  );
}

void eliminaRecordatorio(int id) async {
  await NotificationService().cancelaNotificacion(id);
}
