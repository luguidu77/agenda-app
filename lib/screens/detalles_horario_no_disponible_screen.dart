import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/elimina_cita.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetallesHorarioNoDisponibleScreen extends StatefulWidget {
  final String emailUsuario;
  final CitaModelFirebase reserva;
  const DetallesHorarioNoDisponibleScreen(
      {super.key, required this.reserva, required this.emailUsuario});

  @override
  State<DetallesHorarioNoDisponibleScreen> createState() =>
      _DetallesHorarioNoDisponibleScreenState();
}

class _DetallesHorarioNoDisponibleScreenState
    extends State<DetallesHorarioNoDisponibleScreen> {
  bool visibleFormulario = false;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  EdgeInsets miPadding = const EdgeInsets.all(18.0);
  late CitaModelFirebase reserva;
  double altura = 300;
  String _emailSesionUsuario = '';

  bool _iniciadaSesionUsuario = false;

  getPersonaliza() async {
    final personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);
    personaliza = personalizaProvider.getPersonaliza;

    setState(() {});
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  @override
  void initState() {
    emailUsuario();
    getPersonaliza();
    reserva = widget.reserva;

    debugPrint(widget.reserva.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CitasProvider contextoCitaProvider = context.read<CitasProvider>();
    // final cita = widget.reserva; //widget.reserva;
    String? fechaLarga;
    DateTime resFecha = DateTime.parse(reserva.horaInicio
        .toString()); // horaInicio trae 2022-12-05 20:27:00.000Z
    //? FECHA LARGA EN ESPAÑOL
    fechaLarga = DateFormat.MMMMEEEEd('es_ES')
        .add_Hm()
        .format(DateTime.parse(resFecha.toString()));
    return Scaffold(
        backgroundColor: colorFondo,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          backgroundColor: colorFondo,
          elevation: 0,
          title: Text(
            'Detalle horario no disponible',
            style: subTituloEstilo,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Detalles del cliente

            // _cliente(reserva),
            // Detalle de la cita

            _detallesCita(
              widget.reserva,
              fechaLarga,
              contextoCitaProvider,
            ),

            /*  Visibility(
              visible: visibleFormulario,
              child: FormReprogramaReserva(
                  idServicio: reserva['idServicio'].toString(), cita: reserva),
            ), */
            /*  SizedBox(
              height: 300,
              child: CompartirCitaConCliente(
                cliente: reserva['nombre'],
                telefono: reserva['telefono']!,
                email: reserva['email'],
                fechaCita: reserva['horaInicio'],
                servicio: reserva['servicio'],
                precio: reserva['precio'],
              ),
            ), */
          ]),
        ));
  }

  _botonesCita(CitaModelFirebase reserva, contextoCitaProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.red.shade100),
            ),
            onPressed: () async {
              final res = await mensajeAlerta(
                  context,
                  contextoCitaProvider,
                  0,
                  [reserva],
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
        /*  ElevatedButton.icon(
            onPressed: () {
              setState(() {});
              visibleFormulario
                  ? visibleFormulario = false
                  : visibleFormulario = true;
            },
            icon: Icon(visibleFormulario
                ? Icons.cancel
                : Icons.change_circle_outlined),
            label: Text(visibleFormulario ? 'Cancelar' : 'Reasignar')) */
      ],
    );
  }

  _detallesCita(CitaModelFirebase cita, fechaLarga, contextoCitaProvider) {
    print(
        'cita actual **************************************************************** $cita');
    return SizedBox(
      child: Column(
        // clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            // height: 250,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: Colors.grey[300]!, width: 1), // Borde gris tenue
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Padding(
                  padding: miPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        'Notas: ${cita.comentario.toString()}',
                        style: subTituloEstilo,
                      ),
                      const SizedBox(height: 40),
                      _botonesCita(reserva, contextoCitaProvider)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* _cliente(reserva) {
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
  } */

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

  /*  tarjetaCliente() {
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
                      maxLines: 2,
                      style: textoEstilo,
                      reserva['telefono'].toString()),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    reserva['nota'].toString() == '' ||
                            reserva['nota'].toString() == 'null'
                        ? ''
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
                  reserva['email'] != ''
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
  } */
}
