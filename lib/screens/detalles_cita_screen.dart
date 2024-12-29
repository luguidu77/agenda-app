import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/screens/screens.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/botones/boton_confirmar_cita_reserva_web.dart';
import 'package:agendacitas/widgets/empleado/empleado.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/botones/form_reprogramar_reserva.dart';
import '../widgets/compartirCliente/compartir_cita_a_cliente.dart';
import '../widgets/elimina_cita.dart';

class DetallesCitaScreen extends StatefulWidget {
  final String emailUsuario;
  final CitaModelFirebase? reserva;
  const DetallesCitaScreen(
      {Key? key, required this.reserva, required this.emailUsuario})
      : super(key: key);

  @override
  State<DetallesCitaScreen> createState() => _DetallesCitaScreenState();
}

class _DetallesCitaScreenState extends State<DetallesCitaScreen> {
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase(
    id: '',
    codpais: '',
    enlace: '',
    moneda: '',
    mensaje: '',
  );
  late String _emailSesionUsuario;
  bool _iniciadaSesionUsuario = false;

  compruebaEstadoCita() {
    bool citaconfirmada = widget.reserva!.confirmada!;
    final estadoCita =
        Provider.of<EstadoConfirmacionCita>(context, listen: false);
    estadoCita.setEstadoCita(citaconfirmada);
  }

  @override
  void initState() {
    Future.microtask(() => compruebaEstadoCita());

    super.initState();
  }

  Future<void> getPersonaliza() async {
    final personalizaProvider = context.read<PersonalizaProviderFirebase>();

    personaliza = personalizaProvider.getPersonaliza;
  }

  Future<void> emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();

    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  Future<void> cargarDatos() async {
    await emailUsuario();
    await getPersonaliza();
  }

  @override
  Widget build(BuildContext context) {
    final citaconfirmada = Provider.of<EstadoConfirmacionCita>(context);
    String fechaCorta = DateFormat('EEE d MMM', 'es_ES')
        .add_Hm()
        .format((widget.reserva!.horaInicio!));

    return Scaffold(
        backgroundColor: colorFondo,
        /*  appBar: AppBar(
          title: Text('Detalle de la cita', style: subTituloEstilo),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: colorFondo,
          elevation: 0,
        ), */
        body: FutureBuilder<void>(
            future:
                cargarDatos(), // Aquí se espera a que los datos estén listos
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Mientras se cargan los datos
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // Si hay error
              } else {
                // Los datos se cargaron correctamente
                return SingleChildScrollView(
                    child: Column(
                  children: [
                    _DetallesCitaWidget(
                      reserva: widget.reserva!,
                      fechaCorta: fechaCorta,
                      citaconfirmada: citaconfirmada.estadoCita,
                      personaliza: personaliza,
                      emailUsuario: _emailSesionUsuario,
                      iniciadaSesionUsuario: _iniciadaSesionUsuario,
                    ),
                  ],
                ));
              }
            }));
  }
}

class _DetallesCitaWidget extends StatefulWidget {
  final CitaModelFirebase reserva;
  final String fechaCorta;
  final bool citaconfirmada;
  final PersonalizaModelFirebase personaliza;
  final String emailUsuario;
  final bool iniciadaSesionUsuario;

  const _DetallesCitaWidget({
    required this.reserva,
    required this.fechaCorta,
    required this.citaconfirmada,
    required this.personaliza,
    required this.emailUsuario,
    required this.iniciadaSesionUsuario,
  });

  @override
  State<_DetallesCitaWidget> createState() => _DetallesCitaWidgetState();
}

class _DetallesCitaWidgetState extends State<_DetallesCitaWidget> {
  @override
  Widget build(BuildContext context) {
    CitasProvider contextoCitaProvider = context.read<CitasProvider>();
    print('····························reserva·······························');
    print(widget.reserva);
    final citaconfirmada =
        Provider.of<EstadoConfirmacionCita>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: _buildGradient(citaconfirmada.estadoCita),
              boxShadow: [_buildBoxShadow()],
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOTON CONFIRMAR DE LA CITA---------------------------------------------
                _buildConfirmationButton(),
                // CLIENTE DE LA CITA-----------------------------------------------------
                _ClienteInfoWidget(reserva: widget.reserva),

                // FECHA DE LA CITA ------------------------------------------------------
                Text(widget.fechaCorta,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),

                // EMPLEADO ASIGNADO DE LA CITA-------------------------------------------
                _EmpleadoInfoWidget(reserva: widget.reserva),
                // SERVICIOS DE LA CITA----------------------------------------------------
                Text(widget.reserva.servicios!.join(', '),
                    style:
                        const TextStyle(fontSize: 14, color: Colors.white54)),

                // PRECIO DE LA CITA------------------------------------------------------
                Text(
                  'PRECIO: ${widget.reserva.precio} ${widget.personaliza.moneda}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),

                // NOTAS DE LA CITA---------------------------
                Text('Notas: ${widget.reserva.comentario}',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.white54)),
                const SizedBox(height: 90),
              ],
            ),
          ),
          Positioned(
            bottom: -10,
            right: 20,
            child: Row(
              children: [
                _buildShareButton(),
                _buildReassignButton(),
                _buildDeleteButton(context, contextoCitaProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationButton() {
    return widget.iniciadaSesionUsuario
        ? BotonConfirmarCitaWeb(
            cita: widget.reserva, emailUsuario: widget.emailUsuario)
        : const Text(
            'Cita confirmada',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          );
  }

  LinearGradient _buildGradient(bool citaconfirmada) {
    return citaconfirmada
        ? const LinearGradient(
            colors: [
              Color.fromARGB(255, 37, 98, 204),
              Color.fromARGB(255, 94, 176, 243)
            ],
            begin: Alignment.center,
            end: Alignment.topRight,
          )
        : const LinearGradient(
            colors: [Colors.pink, Color.fromARGB(255, 238, 175, 80)],
            begin: Alignment.center,
            end: Alignment.bottomLeft,
          );
  }

  BoxShadow _buildBoxShadow() {
    return BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 8,
      offset: const Offset(0, 4),
    );
  }

  Widget _buildShareButton() {
    return CompartirCitaConCliente(
      cliente: widget.reserva.nombreCliente!,
      telefono: widget.reserva.telefonoCliente!,
      email: widget.reserva.email,
      fechaCita: widget.reserva.horaInicio,
      servicio: widget.reserva
          .servicios, // [servicio1, servicio2] por lo que le quito los corchetes
      precio: widget.reserva.precio,
    );
  }

  Widget _buildReassignButton() {
    return FloatingActionButton(
      heroTag: 'reassignButtonTag',
      mini: true,
      backgroundColor: Colors.deepPurpleAccent,
      onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: SizedBox(
              height: 400,
              child: ListView(
                children: [
                  FormReprogramaReserva(
                      idServicio: widget.reserva.idservicio.toString(),
                      cita: widget.reserva),
                ],
              ),
            ));
          }),

      // toggleFormulario,
      child: const Icon(Icons.change_circle_outlined),
    );
  }

  Widget _buildDeleteButton(context, contextoCitaProvider) {
    return FloatingActionButton(
      heroTag: 'deleteButton',
      mini: true,
      backgroundColor: Colors.redAccent,
      onPressed: () async {
        final res = await mensajeAlerta(
            context,
            contextoCitaProvider,
            0,
            widget.reserva,
            (widget.emailUsuario == '') ? false : true,
            widget.emailUsuario);

        if (res == true) {
          await FirebaseProvider()
              .cancelacionCitaCliente(widget.reserva, widget.emailUsuario);
          Navigator.pushReplacementNamed(context, '/');
        }
      },
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

class _ClienteInfoWidget extends StatelessWidget {
  final CitaModelFirebase reserva;

  const _ClienteInfoWidget({required this.reserva});

  @override
  Widget build(BuildContext context) {
    final cliente = ClienteModel(
      id: reserva.idcliente.toString(),
      nombre: reserva.nombreCliente,
      telefono: reserva.telefonoCliente,
      email: reserva.email,
      foto: reserva.fotoCliente,
      nota: reserva.notaCliente,
    );
    return InkWell(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              FichaClienteScreen(clienteParametro: cliente),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      child: TarjetaCliente(
        cliente: cliente,
      ),
    );
  }
}

class _EmpleadoInfoWidget extends StatelessWidget {
  final CitaModelFirebase reserva;

  const _EmpleadoInfoWidget({required this.reserva});

  @override
  Widget build(BuildContext context) {
    final estadoPagoProvider =
        Provider.of<EstadoPagoAppProvider>(context, listen: false);
    String emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    return Row(
      children: [
        const Text(
          'Concertada con ',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          width: 2,
        ),
        EmpleadoWidget(
          emailUsuario: emailSesionUsuario,
          idEmpleado: reserva.idEmpleado!,
          procede: 'detalles_cita',
        ),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}

class _NotasInfo extends StatelessWidget {
  const _NotasInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: const Text(
        'Reprograma o elimina la cita actual y se enviará automáticamente una notificación al cliente registrado por el cambio realizado.',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class EmpleadoAvatar extends StatelessWidget {
  final EmpleadoModel empleado;
  final bool esFichaEmpleado;

  const EmpleadoAvatar(
      {super.key, required this.empleado, this.esFichaEmpleado = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: empleado.foto != ''
              ? NetworkImage(empleado.foto) as ImageProvider
              : const AssetImage('assets/images/nofoto.jpg'),
          radius: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              empleado.nombre,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (esFichaEmpleado)
              Text(
                empleado.telefono,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}

class TarjetaCliente extends StatelessWidget {
  final ClienteModel cliente;

  const TarjetaCliente({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _fotoCliente(cliente.foto),
          const SizedBox(width: 15),
          _infoCliente(cliente),
        ],
      ),
    );
  }

  Widget _fotoCliente(String? fotoUrl) {
    return CircleAvatar(
      backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
          ? NetworkImage(fotoUrl)
          : const AssetImage("assets/images/nofoto.jpg") as ImageProvider,
      radius: 30,
    );
  }

  Widget _infoCliente(ClienteModel cliente) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cliente.nombre ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 5),
          if (cliente.nota != null && cliente.nota.toString().isNotEmpty)
            Text(
              cliente.nota!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
