import 'package:agendacitas/screens/screens.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/botones/boton_confirmar_cita_reserva_web.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
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
  bool visibleFormulario = false;
  PersonalizaModel personaliza = PersonalizaModel();
  EdgeInsets miPadding = const EdgeInsets.all(18.0);
  late Map<String, dynamic> reserva;
  double altura = 300;
  String _emailSesionUsuario = '';

  bool _iniciadaSesionUsuario = false;

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
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
    String? fechaLarga;
    DateTime resFecha = DateTime.parse(
        reserva['horaInicio']); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));
    return Scaffold(
        backgroundColor: colorFondo,
        appBar: AppBar(
          backgroundColor: colorFondo,
          elevation: 0,
          title: Text(
            'Detalle de la cita',
            style: subTituloEstilo,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Detalles del cliente

            _cliente(reserva),
            // Detalle de la cita

            _detallesCita(
              reserva,
              fechaLarga,
            ),

            Visibility(
              visible: visibleFormulario,
              child: FormReprogramaReserva(
                  idServicio: reserva['idServicio'].toString(), cita: reserva),
            ),
            SizedBox(
              height: 300,
              child: CompartirCitaConCliente(
                  cliente: reserva['nombre'],
                  telefono: reserva['telefono']!,
                  email: reserva['email'],
                  fechaCita: fechaLarga,
                  servicio: reserva['servicio']),
            ),
          ]),
        ));
  }

  _botonesCita() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.red.shade100),
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
            label: const Text('Elimina'))

        // HE QUITADO EL BOTON REPROGRAMAR

        ,
        ElevatedButton.icon(
            onPressed: () {
              setState(() {});
              visibleFormulario
                  ? visibleFormulario = false
                  : visibleFormulario = true;
            },
            icon: Icon(visibleFormulario
                ? Icons.cancel
                : Icons.change_circle_outlined),
            label: Text(visibleFormulario ? 'Cancelar' : 'Reasignar'))
      ],
    );
  }

  _detallesCita(Map<String, dynamic> cita, fechaLarga) {
    print(
        'cita actual **************************************************************** $cita');
    return SizedBox(
      child: Column(
        // clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            // height: 250,
            child: Card(
              // color: Colors.deepPurple[300],
              child: Padding(
                padding: miPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iniciadaSesionUsuario
                        ? BotonConfirmarCitaWeb(
                            cita: cita, emailUsuario: widget.emailUsuario)
                        : const Text('Cita confirmada'),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
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
                      'Notas: ${cita['comentario'].toString()}',
                      style: subTituloEstilo,
                    ),
                    const SizedBox(height: 10),
                    _botonesCita()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _cliente(reserva) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  FichaClienteScreen(
                    clienteParametro: ClienteModel(
                        id: reserva['idCliente'].toString(),
                        nombre: reserva['nombre'],
                        telefono: reserva['telefono'],
                        email: reserva['email'],
                        foto: reserva['foto'],
                        nota: reserva['nota']),
                  ),
              transitionDuration: // ? TIEMPO PARA QUE SE APRECIE EL HERO DE LA FOTO
                  const Duration(milliseconds: 600)),
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Card(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              child: tarjetaCliente()),
        ),
      ),
    );
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

  tarjetaCliente() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _foto(reserva['foto']),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: textoEstilo,
                      reserva['nombre'].toString()),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    reserva['nota'].toString() == ''
                        ? 'Notas'
                        : reserva['nota'].toString(),
                    style: textoPequenoEstilo,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Column(
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
                          icon: const FaIcon(FontAwesomeIcons.solidEnvelope))
                      : Container(),
                ],
              ),
            )
          ]),
    );
  }
}
