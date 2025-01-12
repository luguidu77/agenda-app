import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../providers/providers.dart';
import '../utils/utils.dart';

mensajeAlerta(
    context,
    CitasProvider contextoCitaProvider,
    int index,
    List<CitaModelFirebase> citas,
    bool iniciadaSesionUsuario,
    String emailusuario) async {
  String textoPregunta = '';
  bool respuesta = false;
  late String textoNombre;
  late dynamic idCita;

  textoNombre = citas[index].nombreCliente.toString();
  if (textoNombre == 'null') {
    textoNombre = 'NO DISPONIBLE';

    textoPregunta = '¿ Quieres eliminar esta indisponibilidad ?';

    idCita = citas[index].id;
  } else {
    textoNombre = citas[index].nombreCliente!;

    textoPregunta = '¿ Quieres eliminar la cita de $textoNombre ?';

    idCita = citas[index].id.toString();
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
            content: Text(textoPregunta),
            actions: [
              Row(
                children: [
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.red.shade100)),
                      onPressed: () {
                        iniciadaSesionUsuario
                            //ELIMINA CITA EN FIREBASE
                            ? _eliminarCitaFB(context, contextoCitaProvider,
                                emailusuario, idCita)
                            //ELIMINA CITA EN DISPOSITIVO
                            : _eliminarCita(context, idCita, textoNombre);

                        respuesta = true;
                        Navigator.pushNamed(context, "/");
                      },
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Eliminar')),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        ' No ',
                      ))
                ],
              ),
            ],
          ));
  return respuesta;
}

void _eliminarCitaFB(context, contextoCitaProvider, usuarioAPP, id) {
  SincronizarFirebase().eliminaCitaId(usuarioAPP, id.toString());

  contextoCitaProvider.eliminacitaAlContexto(id);

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
