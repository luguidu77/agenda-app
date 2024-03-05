import 'package:agendacitas/models/tiempo_record_model.dart';

import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/widgets/tarjetaTiempoRecord.dart';
import 'package:flutter/material.dart';

class ConfigRecordatorios extends StatefulWidget {
  const ConfigRecordatorios({Key? key}) : super(key: key);

  @override
  State<ConfigRecordatorios> createState() => _ConfigRecordatoriosState();
}

class _ConfigRecordatoriosState extends State<ConfigRecordatorios> {
  List tRecordatorioGuardado = [];
  String tGuardado = '';

  TiempoRecordatorioModel tiempoRecordatorio = TiempoRecordatorioModel();

  TiempoRecordatorioModel nuevoRecordatorio = TiempoRecordatorioModel();

  String textoDia = '';
  String textoFechaHora = '';
  String medida = '';
  tiempo() async {
    final tiempoEstablecido = await RecordatoriosProvider().cargarTiempo();

    tRecordatorioGuardado = tiempoEstablecido;
    // print('tiempo establecido recordatorio $tiempoEstablecido');
    // si no hay tiempo establecido guarda uno por defecto
    if (tRecordatorioGuardado.isEmpty) {
      await addTiempo();
      tiempo();

      //  print( 'se ha establecido tiempo establecido recordatorio $tiempoEstablecido');
    } else {
      // **  SI LOS MINUTOS SON CEROS DEBE SER 24:00
      if (tRecordatorioGuardado[0].tiempo[3] == '0') {
        tGuardado =
            '${tRecordatorioGuardado[0].tiempo[0]}${tRecordatorioGuardado[0].tiempo[1]}';
        medida = 'h';
      } else {
        tGuardado =
            '${tRecordatorioGuardado[0].tiempo[3]}${tRecordatorioGuardado[0].tiempo[4]}';
        medida = 'min';
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    tiempo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
            backgroundColor: Colors.red),
        onPressed: () async => {
              await tarjetaTiempoRecord(context, tGuardado).whenComplete(() {
                return actualizar(context);
              })
            },
        child: Text('$tGuardado $medida'));
  }

  actualizar(context) {
    tiempo();
    setState(() {});
  }
}

addTiempo() async {
  await RecordatoriosProvider().nuevoTiempo('00:30');
}
