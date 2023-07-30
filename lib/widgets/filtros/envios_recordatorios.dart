import 'package:agendacitas/models/cita_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import '../../providers/providers.dart';

class EnviosRecordatorios extends StatefulWidget {
  final String usuarioAPP;
  final DateTime fechaElegida;

  const EnviosRecordatorios(
      {Key? key, required this.fechaElegida, required this.usuarioAPP})
      : super(key: key);

  @override
  State<EnviosRecordatorios> createState() => _EnviosRecordatoriosState();
}

class _EnviosRecordatoriosState extends State<EnviosRecordatorios> {
  late TwilioFlutter twilioFlutter;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  var _isSelected = false;
  Set<Map<String, dynamic>> listaCitas = {};

  @override
  void initState() {
    twilioFlutter = TwilioFlutter(
        accountSid: 'AC5d956c5b9f56bc443b58cf9a22741e34',
        authToken: 'c757d746a509291c70e0099081c4fd76',
        twilioNumber: '+14155238886');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fecha = dateFormat.format(widget.fechaElegida);
    _citasPorFecha(fecha);

    print(' lista de citas para enviar recordatorios :    ${listaCitas}');

    return Container(
      color: Theme.of(context).primaryColor,
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Text('Envía recordatorios para las citas de este día'),
          Wrap(spacing: 5, children: [
            const SizedBox(height: 30),
            FilterChip(
              selected: _isSelected,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(
                  color: Colors.blue,
                ),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(8.0),
              label: const Text(
                'ENVIAR RECORDATORIOS ',
                style: TextStyle(
                  fontSize: 14.0,
                  height: 1.4,
                  fontWeight: FontWeight.normal,
                  color: Colors.blue,
                ),
              ),
              onSelected: (bool value) {
                setState(() {});
                _isSelected = value;
                print('pulsado');
                for (var element in listaCitas) {
                  print(element['nombre']);
                  if (element['telefono'] != null) {
                    sendWhatsApp(
                        element['telefono'], // telefonosClientes,
                        element['servicio'], //servicio,
                        'negocio',
                        element['horaInicio'], // fecha,
                        'empleado',
                        'telefonoNegocio');
                  }
                }
              },
            ),
          ]),
        ],
      ),
    );
  }

  _citasPorFecha(fecha) async {
    List<Map<String, dynamic>> citas = await FirebaseProvider()
        .leerBasedatosFirebase(widget.usuarioAPP, fecha);

    for (var element in citas) {
      // print(element['id']);

      listaCitas.add(element);
    }

    List<Map<String, dynamic>> lista = listaCitas.toList();
    return lista;
  }

  void sendWhatsApp(String telefonoCliente, String servicio, String negocio,
      String fecha, String empleado, String telefonoNegocio) {
    twilioFlutter.sendWhatsApp(
        toNumber: '+34666020102',
        messageBody:
            '¡Confirmamos su cita para $servicio en $negocio el $fecha con $empleado!  Si necesita cancelar, reprogramar o tiene alguna pregunta, llame al $telefonoNegocio ¡Esperamos verle!');
  }
}
