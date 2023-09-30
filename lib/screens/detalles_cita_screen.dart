import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../widgets/compartirCliente/compartir_cita_a_cliente.dart';

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
  EdgeInsets miPadding = const EdgeInsets.all(18.0);
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
      // height: 250,
      child: Column(
        // clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              // color: Colors.deepPurple[300],
              child: Padding(
                padding: miPadding,
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
                    /* Text(
                      cita['detalle'].toString(),
                      style: subTituloEstilo,
                    ), */
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
          CompartirCitaConCliente(
              cliente: reserva['nombre'],
              telefono: reserva['telefono']!,
              email: reserva['email'],
              fechaCita: fechaLarga,
              servicio: reserva['servicio'])
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
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              child: Padding(
                padding: miPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _foto(reserva['foto']),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Text(style: textoEstilo, reserva['nombre'].toString()),
                        Text(style: textoEstilo, reserva['nota'].toString()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      //  mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            Comunicaciones.hacerLlamadaTelefonica(
                                reserva['telefono'].toString());
                          },
                          icon: const FaIcon(FontAwesomeIcons.phone),
                        ),
                        reserva['email'] != ' '
                            ? IconButton(
                                onPressed: () {
                                  Comunicaciones.enviarEmail(
                                      reserva['email'].toString());
                                },
                                icon: const FaIcon(
                                    FontAwesomeIcons.solidEnvelope))
                            : Container(),
                      ],
                    )
                  ],
                ),
              ),
            )));
  }

  ClipRRect _foto(foto) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: foto != ''
            ? Image.network(
                foto,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            : Image.asset(
                "./assets/images/nofoto.jpg",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ));
  }
}
