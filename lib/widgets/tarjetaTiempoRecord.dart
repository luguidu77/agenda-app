import 'package:agendacitas/models/tiempo_record_model.dart';
import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';

TiempoRecordatorioModel nuevoRecordatorio = TiempoRecordatorioModel();
tarjetaTiempoRecord(context, String tGuardado) {
  return showModalBottomSheet(
    isDismissible: false,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                const Text('Tiempo recordatorio '),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: Text('$tGuardado min'),
                  items: <String>['10', '20', '30', '60', '24']
                      .map((String value) {
                    String medida = 'min';
                    if (value == '24') {
                      medida = 'h';
                    }
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('$value $medida'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    botonActualizarRecordatorio(context, value.toString());
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}

botonActualizarRecordatorio(context, String minutos) async {
  String nuevahora = '00:$minutos';
  if (minutos == '24') {
    nuevahora = '24:00';
  }
  
  nuevoRecordatorio.id = 0;
  nuevoRecordatorio.tiempo = nuevahora;

  await updateTiempo(context, nuevoRecordatorio);
}

updateTiempo(context, TiempoRecordatorioModel recordatorio) async {
  await RecordatoriosProvider().acutalizarTiempo(recordatorio);
  mensajeModificado(context, '🕑 tiempo recordatorio actualizado');
}

void mensajeModificado(context, String texto) {
  mensajeSuccess(context, texto);
}
