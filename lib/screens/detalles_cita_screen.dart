import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cita_model.dart';
import '../models/personaliza_model.dart';

import '../mylogic_formularios/mylogic.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../widgets/botones/form_reprogramar_reserva.dart';
import '../widgets/compartirCliente/compartir_cita_a_cliente.dart';
import '../widgets/elimina_cita.dart';

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
          children: [
            _botonCerrar(context),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'DETALLES DE LA CITA',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 20,
            ),
            _detallesCita(),
            const SizedBox(
              height: 30,
            ),
            const Divider(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _foto(),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        Comunicaciones.hacerLlamadaTelefonica(
                            telefono.toString());
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text(
                        'llamar',
                        style: TextStyle(fontSize: 12),
                      )),
                  ElevatedButton.icon(
                      onPressed: () {
                        Comunicaciones.enviarEmail(email.toString());
                      },
                      icon: const Icon(Icons.mail),
                      label: const Text(
                        'Enviar un email',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  ClipRRect _foto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(150.0),
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
            ),
    );
  }

  _botonesCita() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        !visibleFormulario
            ? ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: () async {
                  final res = await mensajeAlerta(
                      context,
                      0,
                      widget.reserva,
                      (widget.emailUsuario == '') ? false : true,
                      widget.emailUsuario);

                  if (res == true) {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'))
            : Container(),
        visibleBotonFormulario
            ? ElevatedButton.icon(
                onPressed: () {
                  setState(() {});
                  visibleFormulario
                      ? visibleFormulario = false
                      : visibleFormulario = true;
                },
                icon: Icon(visibleFormulario ? Icons.cancel : Icons.edit),
                label:
                    Text(visibleFormulario ? 'Cancelar' : 'Reprogramar cita'))
            : Container(),
      ],
    );
  }

  _detallesCita() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.reserva['nombre'] == null
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'El cliente fué eliminado',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : _detallesCliente(),
            visibleFormulario
                ? FormReprogramaReserva(idServicio: idServicio, cita: cita)
                : _detalles(),
            _botonesCita(),
          ],
        ),
      ),
    );
  }

  _detalles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fechaLarga!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'SERVICIO: $servicio',
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          detalle!,
          style: const TextStyle(fontSize: 15),
        ),
        Text(
          'PRECIO: $precio ${personaliza.moneda}',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Notas de la cita: $comentario',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
