import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/models/tiempo_record_model.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';

import 'package:agendacitas/providers/recordatorios_provider.dart';
import 'package:agendacitas/widgets/tarjetaTiempoRecord.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigRecordatorios extends StatefulWidget {
  const ConfigRecordatorios({Key? key}) : super(key: key);

  @override
  State<ConfigRecordatorios> createState() => _ConfigRecordatoriosState();
}

class _ConfigRecordatoriosState extends State<ConfigRecordatorios> {
  String tRecordatorioGuardado = '';
  String tGuardado = '';

  TiempoRecordatorioModel tiempoRecordatorio = TiempoRecordatorioModel();

  TiempoRecordatorioModel nuevoRecordatorio = TiempoRecordatorioModel();

  String textoDia = '';
  String textoFechaHora = '';
  String medida = '';
  late PersonalizaProviderFirebase personalizaProvider;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  late String emailSesionUsuario;

  emailUsuario() {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
  }

  tiempo() async {
    personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);

    final tiempoEstablecido =
        personalizaProvider.getPersonaliza.tiempoRecordatorio;

    tRecordatorioGuardado = tiempoEstablecido!;
    // print('tiempo establecido recordatorio $tiempoEstablecido');
    // si no hay tiempo establecido guarda uno por defecto
    if (tRecordatorioGuardado.isEmpty) {
      await addTiempo();

      //  print( 'se ha establecido tiempo establecido recordatorio $tiempoEstablecido');
    } else {
      // **  SI LOS MINUTOS SON CEROS DEBE SER 24:00
      if (tRecordatorioGuardado[3] == '0') {
        tGuardado = '${tRecordatorioGuardado[0]}${tRecordatorioGuardado[1]}';
        medida = 'h';
      } else {
        tGuardado = '${tRecordatorioGuardado[3]}${tRecordatorioGuardado[4]}';
        medida = 'min';
      }
    }
  }

  @override
  void initState() {
    emailUsuario();
    tiempo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: true);
    final personaliza = personalizaProvider.getPersonaliza;

    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
            backgroundColor: Colors.red),
        onPressed: () async => {
              await tarjetaTiempoRecord(context, emailSesionUsuario, tGuardado)
              /*  .whenComplete(() {
                /*   mensajeModificado(
                    context, '🕑 tiempo recordatorio actualizado'); */
                // **  SI LOS MINUTOS SON CEROS DEBE SER 24:00
              }) */
            },
        child: Text('${personaliza.tiempoRecordatorio}'));
  }

  addTiempo() async {
    personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);
    personaliza = personalizaProvider.getPersonaliza;
    personaliza.tiempoRecordatorio = '00:30';
    // await RecordatoriosProvider().nuevoTiempo('00:30');

    // Establecemos el objeto en el provider

    personalizaProvider.setPersonaliza(personaliza);

    RecordatoriosProvider()
        .acutalizarTiempo(context, emailSesionUsuario, personaliza);
  }
}
