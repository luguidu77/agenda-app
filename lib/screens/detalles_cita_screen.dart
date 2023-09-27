import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class DetallesCitaScreen extends StatefulWidget {
  final String emailUsuario;
  final Map<String, dynamic> reserva;
  const DetallesCitaScreen(
      {Key? key, required this.reserva, required this.emailUsuario})
      : super(key: key);

  @override
  State<DetallesCitaScreen> createState() => _DetallesCitaScreenState();
}

class _DetallesCitaScreenState extends State<DetallesCitaScreen> {
  PersonalizaModel personaliza = PersonalizaModel();
  final padding = const EdgeInsets.all(28.0);
  late Map<String, dynamic> reserva;

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  }

  @override
  void initState() {
    getPersonaliza();
    reserva = widget.reserva;

    debugPrint(widget.reserva.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final cita = widget.reserva; //widget.reserva;

    return Scaffold(
      // backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorFondo,
        elevation: 0,
        title: Text(
          'Detalle de la cita',
          style: subTituloEstilo,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalles del cliente
              _cliente(reserva),

              Text(
                'Detalles',
                style: tituloEstilo,
              ),
              // Detalle de la cita
              _detallesCita(reserva),

              const SizedBox(
                height: 100,
              ),

              // compartir cita
            ],
          ),
        ),
      ),
    );
  }

  _detallesCita(cita) {
    String? fechaLarga;
    DateTime resFecha = DateTime.parse(
        cita['horaInicio']); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              // color: Colors.deepPurple[300],
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        // fechaLarga!,
                        fechaLarga.toString(),
                        style: textoEstilo),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      cita['servicio'].toString(),
                      style: subTituloEstilo,
                    ),
                    Text(
                      cita['detalle'].toString(),
                      style: subTituloEstilo,
                    ),
                    Text(
                      'PRECIO: ${cita['precio'].toString()} ${personaliza.moneda}',
                      style: subTituloEstilo,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Notas de la cita: ${cita['comentario'].toString()}',
                      style: subTituloEstilo,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            right: 10,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 60,
                      child: Image.asset('assets/images/whatsapp.png')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 60, child: Image.asset('assets/images/email.png')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                      width: 60, child: Image.asset('assets/images/sms.png')),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _cliente(reserva) {
    return SizedBox(
        width: double.infinity,
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Card(
              color: const Color.fromARGB(255, 13, 182, 173),
              child: Padding(
                padding: padding,
                child: Column(
                  children: [
                    _foto(reserva['foto']),
                    const SizedBox(height: 20),
                    Text(style: textoEstilo, reserva['nombre']),
                    SizedBox(
                        width: 50,
                        child: Image.asset('assets/images/phone-call.png'))
                  ],
                ),
              ),
            )));
  }

  ClipRRect _foto(foto) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(150.0),
        child: Image.network(
          foto != '' ? foto : "./assets/images/nofoto.jpg",
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ));
  }
}
