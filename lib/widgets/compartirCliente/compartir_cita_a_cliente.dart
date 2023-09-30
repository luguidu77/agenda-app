import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../screens/screens.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class CompartirCitaConCliente extends StatefulWidget {
  final String cliente;
  final String telefono;
  final dynamic email;
  final dynamic fechaCita;
  final dynamic servicio;
  const CompartirCitaConCliente({
    Key? key,
    required this.cliente,
    required this.telefono,
    required this.email,
    required this.fechaCita,
    required this.servicio,
  }) : super(key: key);

  @override
  State<CompartirCitaConCliente> createState() =>
      _CompartirCitaConClienteState();
}

class _CompartirCitaConClienteState extends State<CompartirCitaConCliente> {
  String _emailSesionUsuario = '';
  PerfilModel perfilUsuarioApp = PerfilModel();
  bool pagado =
      true; //deshabilitado, por defecto la variable pagado=true; podria usarlo por ejemplo para hacer una alerta de comprar la app
  String? telefonoCodpais;

  bool visible = true;

  late PersonalizaProviderFirebase contextoPersonalizaFirebase;
  late String textoActual;

  compruebaPago() async {
    //   PagoProvider para obtener pago y el email del usuarioAPP
    final providerPagoUsuarioAPP =
        Provider.of<PagoProvider>(context, listen: false);

    setState(() {
      pagado = providerPagoUsuarioAPP.pagado['pago'];
    });

    debugPrint(
        'datos gardados en tabla Pago (fichaClienteScreen.dart) PAGO: ${pagado.toString()}');
  }

  _getCodPais() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();
    //COMPRUEBO QUE HAY UN CODIGO DE PAIS ESTABLECIDO PREVIAMENTE, SI NO , ESTABLEZCO EL 34 POR DEFECTO

    return (data.isNotEmpty) ? data[0].codpais : 34;
  }

  _estableceCodPais() async {
    int codPais = await _getCodPais();

    telefonoCodpais = codPais.toString() + widget.telefono;
    //print('telefono -------------$telefonoTexto');
  }

  _perfilUsuarioApp() async {
    //traigo email del usuario, del PagoProvider

    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;

    //traigo perfil del usuariode la app desde firebase
    await FirebaseProvider().cargarPerfilFB(_emailSesionUsuario).then((value) {
      setState(() {});
      return perfilUsuarioApp = value;
    });
  }

  @override
  void initState() {
    // compruebaPago(); //deshabilitado, por defecto la variable pagado=true; podria usarlo por ejemplo para hacer una alerta de comprar la app

    _estableceCodPais();
    _perfilUsuarioApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(perfilUsuarioApp.telefono);

    // rescat el texto par enviar a los clientes desde firebase
    contextoPersonalizaFirebase = context.read<PersonalizaProviderFirebase>();
    final personalizaprovider = contextoPersonalizaFirebase.getPersonaliza;
    textoActual = personalizaprovider['MENSAJE_CITA'].toString();

    return Column(
      children: [
        const Text(
          'Comparte la cita con tu client@',
          style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        // VISIBLE UNA TARJETA INFO SI NO HAY DENOMINACION DEL PERFIL DE USUARIO
        if (perfilUsuarioApp.denominacion == '')
          TarjetaInfo(
              colorTexto: Colors.white,
              colorTarjeta: const Color.fromARGB(83, 64, 88, 226),
              icono: const FaIcon(FontAwesomeIcons.exclamation),
              titulo: 'SUGERENCIA',
              texto: 'Edita tu perfil para que se comparta en las citas',
              accion: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ConfigUsuarioApp()))),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            Comunicaciones().compartirCitaWhatsapp(
              perfilUsuarioApp,
              textoActual,
              widget.cliente,
              telefonoCodpais!,
              widget.fechaCita,
              widget.servicio,
            );
          },
          child: const Card(
            child: ListTile(
              title: Text('Whatsapp'),
              trailing: FaIcon(FontAwesomeIcons.whatsapp),
            ),
          ),
        ),
        // LA PANTALLA DETALLES DE LA CITA DEVUELVE UN ESPACIO CUANDO NO HAY EMAIL
        // LA PANTALLA DE CITA CONFIRMADA NO TIENE ESPACIO EN EMAIL VACIO
        widget.email != ' ' && widget.email != ''
            ? GestureDetector(
                onTap: () {
                  pagado
                      ? Comunicaciones().compartirCitaEmail(
                          perfilUsuarioApp,
                          textoActual,
                          widget.cliente,
                          widget.email,
                          widget.fechaCita,
                          widget.servicio)
                      : alerta(context);
                },
                child: const Card(
                  child: ListTile(
                    title: Text('Email'),
                    trailing: FaIcon(FontAwesomeIcons.envelope),
                  ),
                ),
              )
            : Container(),
        GestureDetector(
          onTap: () {
            pagado
                ? Comunicaciones().compartirCitaSms(
                    perfilUsuarioApp,
                    textoActual,
                    widget.cliente,
                    widget.telefono,
                    widget.fechaCita,
                    widget.servicio)
                : alerta(context); //  /utils/alertaNodisponible.dart
          },
          child: const Card(
            child: ListTile(
              title: Text('SMS'),
              subtitle: Text(
                'El coste de SMS dependerá de su operadora telefónica',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              trailing: FaIcon(FontAwesomeIcons.commentSms),
            ),
          ),
        ),
      ],
    );
  }
}


// para playStore hay se necesita solicitar permiso de usuario para SMS, y formularios para poder cambiar textos web y como llegar

/* _enviarSms(context, String telefono, String fecha, String horaInicio) {
  SmsSender sender = SmsSender();
  String address = telefono;
  //Su cita ha sido reservada para el día $fecha, a las $horaInicio horas  ¡Gracias! Web https://giovenails.com  Sigeme en Instagram https://www.instagram.com/giove_nails/?hl=es  Cómo llegar https://maps.google.com/?q=37.39649830679616,%20-6.029338963460662"
  String texto =
      "Su cita ha sido reservada para el día $fecha a las $horaInicio horas";
  SmsMessage message = SmsMessage(address, texto);

  message.onStateChanged.listen((state) {
    if (state == SmsMessageState.Sending) {
      _alertaEnviado(
          context, 'SMS enviado al $telefono', const Icon(Icons.sms));
      print("SMS is sent!");
    } else if (state == SmsMessageState.Delivered) {
      print("SMS is delivered!");
    }
  });
  sender.sendSms(message);
} */