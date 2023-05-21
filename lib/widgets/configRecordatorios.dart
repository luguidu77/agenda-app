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
      tGuardado =
          '${tRecordatorioGuardado[0].tiempo[3]}${tRecordatorioGuardado[0].tiempo[4]}';
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
        child: Text('$tGuardado min'));
  }

  actualizar(context) {
    tiempo();
    setState(() {});
  }
}

addTiempo() async {
  await RecordatoriosProvider().nuevoTiempo('00:30');
}
