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
    emailUsuario();
    getPersonaliza();
    reserva = widget.reserva;
    final citaconfirmada0 =
        widget.reserva['confirmada'] == 'true' ? true : false;
    final citaconfirmada =
        Provider.of<EstadoConfirmacionCita>(context, listen: false);
    citaconfirmada.setEstadoCita(citaconfirmada0);
    debugPrint(widget.reserva.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final cita = widget.reserva; //widget.reserva;

    final citaconfirmada = Provider.of<EstadoConfirmacionCita>(context);

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
          title: Text(
            'Detalle de la cita',
            style: subTituloEstilo,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: colorFondo,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Detalle de la cita

            _detallesCita(reserva, fechaLarga, citaconfirmada.estadoCita),

            Visibility(
              visible: visibleFormulario,
              child: FormReprogramaReserva(
                  idServicio: reserva['idServicio'].toString(), cita: reserva),
            ),

            _notas()
          ]),
        ));
  }

  _botonesCita(reserva) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.red.shade100),
            ),
            onPressed: () async {
              final res = await mensajeAlerta(
                  context,
                  0,
                  widget.reserva,
                  (widget.emailUsuario == '') ? false : true,
                  widget.emailUsuario);

              if (res == true) {
                await FirebaseProvider()
                    .cancelacionCitaCliente(reserva, widget.emailUsuario);
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

  Widget _detallesCita(
      Map<String, dynamic> cita, fechaLarga, bool citaconfirmada) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip
            .none, // Permite que los botones floten fuera del área principal
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: citaconfirmada
                  ? const Color.fromARGB(255, 43, 91, 173)
                  : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Si la sesión está iniciada, muestra el botón de confirmar cita
                _iniciadaSesionUsuario
                    ? BotonConfirmarCitaWeb(
                        cita: cita, emailUsuario: widget.emailUsuario)
                    : const Text(
                        'Cita confirmada',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                //const Divider(color: Colors.white70),

                // Detalles del cliente
                _cliente(reserva),
                const SizedBox(height: 10),

                // Fecha larga
                Text(
                  fechaLarga.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Servicio
                Text(
                  cita['servicio'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Precio
                Text(
                  'PRECIO: ${cita['precio'].toString()} ${personaliza.moneda}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),

                // Notas o comentarios
                Text(
                  'Notas: ${cita['comentario'].toString()}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 90),

                // Botones para interactuar con la cita
                // _botonesCita(cita),
              ],
            ),
          ),

          // Botones flotantes (como los de la tarjeta del cliente)
          Positioned(
            bottom: -10,
            right: 20,
            child: Row(
              children: [
                SizedBox(
                  //height: 300,
                  width: 200,
                  child: CompartirCitaConCliente(
                    cliente: reserva['nombre'],
                    telefono: reserva['telefono']!,
                    email: reserva['email'],
                    fechaCita: reserva['horaInicio'],
                    servicio: reserva['servicio'],
                    precio: reserva['precio'],
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.deepPurpleAccent,
                  onPressed: () {
                    // Acción para formurio reasignar la cita
                    setState(() {});
                    visibleFormulario
                        ? visibleFormulario = false
                        : visibleFormulario = true;
                  },
                  child: Icon(visibleFormulario
                      ? Icons.close
                      : Icons.change_circle_outlined),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.redAccent,
                  onPressed: () async {
                    // Acción para cancelar la cita
                    final res = await mensajeAlerta(
                        context,
                        0,
                        widget.reserva,
                        (widget.emailUsuario == '') ? false : true,
                        widget.emailUsuario);

                    if (res == true) {
                      await FirebaseProvider()
                          .cancelacionCitaCliente(reserva, widget.emailUsuario);
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
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
      height: 100,
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
        child: tarjetaCliente(context, reserva),
      ),
    );
  }

  _notas() {
    return const Column(
      children: [
        // Espacio entre la tarjeta y las notas
        SizedBox(height: 20),

        // Notas de explicación
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "El coste de los SMS dependerá de su operadora telefónica.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8), // Espacio entre las notas
              Text(
                "Los emails se envían automáticamente.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget tarjetaCliente(context, Map<String, dynamic> reserva) {
  Widget foto(String fotoUrl) {
    return Container(
      width: 90, // Tamaño total con el borde
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white24, // Color del borde
          width: 3.0, // Grosor del borde
        ),
      ),
      child: CircleAvatar(
        backgroundImage: fotoUrl.isNotEmpty
            ? NetworkImage(fotoUrl)
            : const AssetImage("./assets/images/nofoto.jpg") as ImageProvider,
        radius: 40, // Radio de la imagen dentro del borde
        backgroundColor: Colors.transparent, // Fondo transparente
      ),
    );
  }

  return Stack(
    clipBehavior: Clip.none, // Permitir desbordamiento
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white, // Fondo blanco para mayor elegancia
          border: Border.all(
            color: Colors.blueGrey.shade100, // Bordes suaves en azul grisáceo
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15), // Sombra suave
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 4), // Desplazamiento de la sombra
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Foto del cliente con borde circular
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent, // Borde alrededor de la imagen
                    width: 2,
                  ),
                ),
                child: foto(reserva['foto']),
              ),
            ),
            const SizedBox(width: 15), // Espacio entre la foto y el contenido

            // Información del cliente
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva['nombre'].toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600, // Fuente un poco más gruesa
                      color: Colors.blueGrey, // Texto en azul grisáceo
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 5),
                  if (reserva['nota'].toString().isNotEmpty &&
                      reserva['nota'].toString() != 'null')
                    Text(
                      reserva['nota'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey, // Mismo color pero más claro
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    ],
  );
}
