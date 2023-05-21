import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cita_model.dart';
import '../models/personaliza_model.dart';

import '../mylogic_formularios/mylogic.dart';
import '../widgets/botones/form_reprogramar_reserva.dart';
import '../widgets/compartirCliente/compartir_cita_a_cliente.dart';

class DetallesCitaScreen extends StatefulWidget {
  final Map<String, dynamic> reserva;
  const DetallesCitaScreen({Key? key, required this.reserva}) : super(key: key);

  @override
  State<DetallesCitaScreen> createState() => _DetallesCitaScreenState();
}

class _DetallesCitaScreenState extends State<DetallesCitaScreen> {
  final CitaModel _cita = CitaModel();

  late MyLogicCliente myLogicCliente;
  late MyLogicServicio myLogicServicio;
  late MyLogicCita myLogicCita;

  bool visibleFormulario = false;
  bool visibleBotonFormulario = true;

  late Map<String, dynamic> cita;
  PersonalizaModel personaliza = PersonalizaModel();
  String? comentario;
  String? nombre;
  late String foto;
  String? telefono;
  String? email;
  String? servicio;
  String? precio;
  String? detalle;
  String? fechaLarga;
  late String idCliente;
  late String idEmpleado;
  late String idServicio;

  String? textoDia;
  String? textoHora;

  DateTime? horaInicio;

  reserva(reserva) {
    cita = reserva;

    horaInicio = DateTime.parse(reserva[
            'horaInicio']) // lo utilizo para deshabilitar reprogramacion de cita si es una cita pasada
        .toLocal();
    DateTime ahora = DateTime.now();
    debugPrint(horaInicio.toString());
    debugPrint(ahora.toString());
    debugPrint(horaInicio!.isBefore(ahora).toString());
    if (horaInicio!.isBefore(ahora)) visibleBotonFormulario = false;
    comentario = reserva!['comentario'];
    nombre = reserva!['nombre'];
    telefono = reserva!['telefono'];
    email = reserva!['email'];
    servicio = reserva!['servicio'];
    foto = reserva!['foto'];

    precio = reserva!['precio'].toString();
    detalle = reserva!['detalle'];
    idServicio = reserva!['idServicio'].toString();
    idCliente = reserva!['idCliente'].toString();
    idEmpleado = reserva!['idEmpleado'].toString();

    DateTime resFecha = DateTime.parse(
        reserva['horaInicio']); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));

    debugPrint(cita.toString());
    debugPrint(resFecha.toString());

    //? descompone fecha para modificar formulario
    // _cita.dia
    // _cita.horaInicio
    _cita.dia = 'fecha momentanea';
    _cita.horaInicio = 'hora momentanea';
    return _cita;
  }

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
    final res = reserva(widget.reserva);
    myLogicCita = MyLogicCita(res);
    myLogicCita.init();

    debugPrint(widget.reserva.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: _formulario(context)),
    );
  }

  _formulario(context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _botonCerrar(context),
            const SizedBox(
              height: 30,
            ),
            _detallesCliente(),
            const Divider(),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'DETALLES DE LA CITA',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              fechaLarga!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            visibleBotonFormulario
                ? ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                      visibleFormulario
                          ? visibleFormulario = false
                          : visibleFormulario = true;
                    },
                    icon: Icon(visibleFormulario ? Icons.cancel : Icons.edit),
                    label: Text(visibleFormulario
                        ? 'Cerrar Reprogramación'
                        : 'Reprogramar cita'))
                : Container(),
            const SizedBox(
              height: 20,
            ),
            visibleFormulario
                ? FormReprogramaReserva(idServicio: idServicio, cita: cita)
                : Container(),
            Text(
              servicio!,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              detalle!,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'PRECIO: $precio ${personaliza.moneda}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Información de la cita: $comentario',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 50,
            ),
            visibleBotonFormulario
                ?
                // EN CARPETA WIDGET/ COMPARTIRCLIENTE/
                CompartirCitaConCliente(
                    cliente: nombre!,
                    telefono: telefono!,
                    email: email,
                    fechaCita: fechaLarga,
                    servicio: servicio)
                : Container()
          ],
        ),
      ),
    );
  }

  _botonCerrar(context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(
                Icons.close,
                size: 50,
                color: Color.fromARGB(167, 114, 136, 150),
              )),
        ],
      ),
    );
  }

  _detallesCliente() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              _foto(),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone),
                label: Text(
                  telefono!,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                )),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mail),
                label: Text(
                  email!,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                )),
          ],
        )
      ],
    );
  }

  ClipRRect _foto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(150.0),
      child: foto != ''
          ? Image.network(
              foto,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            )
          : Image.asset(
              "./assets/images/nofoto.jpg",
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
    );
  }
}
