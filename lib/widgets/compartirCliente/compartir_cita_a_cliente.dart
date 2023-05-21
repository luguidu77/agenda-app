
import 'package:agendacitas/models/perfil_model.dart';
import 'package:agendacitas/models/personaliza_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String emailPerfilUsuarioApp = '';
  PerfilModel perfilUsuarioApp = PerfilModel();
  bool pagado =
      true; //deshabilitado, por defecto la variable pagado=true; podria usarlo por ejemplo para hacer una alerta de comprar la app
  String? telefonoCodpais;
  compruebaPago() async {
    //   PagoProvider para obtener pago y el email del usuarioAPP
    final providerPagoUsuarioAPP =
        Provider.of<PagoProvider>(context, listen: false);

    setState(() {
      pagado = providerPagoUsuarioAPP.pagado['pago'];
    });

    print(
        'datos gardados en tabla Pago (fichaClienteScreen.dart) PAGO: $pagado');
  }

  _getCodPais() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();
    //COMPRUEBO QUE HAY UN CODIGO DE PAIS ESTABLECIDO PREVIAMENTE, SI NO , ESTABLEZCO EL 34 POR DEFECTO
    //TODO: SI NO HAY CODIGO ESTABLECIDO, REDIRIGIR A PERSONALIZAR O TARJETA ESTABLECER CODIGO PAIS
    return (data.isNotEmpty) ? data[0].codpais : 34;
  }

  _estableceCodPais() async {
    int codPais = await _getCodPais();

    telefonoCodpais = codPais.toString() + widget.telefono;
    //print('telefono -------------$telefonoTexto');
  }

  _perfilUsuarioApp() async {
    //traigo email del usuario, del PagoProvider

    final providerPagoUsuarioAPP =
        Provider.of<PagoProvider>(context, listen: false);
    emailPerfilUsuarioApp = await providerPagoUsuarioAPP.pagado['email'];

    //traigo perfil del usuariode la app desde firebase
    await FirebaseProvider()
        .cargarPerfilFB(emailPerfilUsuarioApp)
        .then((value) {
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

    return Center(
      child: Column(
        children: [
          const Text(
            'Comparte la cita con tu client@',
            style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              _enviarWhatsapp(perfilUsuarioApp, widget.cliente,
                  telefonoCodpais!, widget.fechaCita, widget.servicio);
            },
            child: const Card(
              child: ListTile(
                title: Text('Whatsapp'),
                trailing: Icon(Icons.messenger_outline_sharp),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              pagado
                  ? (widget.email != '')
                      ? _enviarEmail(widget.cliente, widget.email,
                          widget.fechaCita, widget.servicio)
                      : alertaNoEmail(context)
                  : alerta(context);
            },
            child: const Card(
              child: ListTile(
                title: Text('Email'),
                trailing: Icon(Icons.email),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              pagado
                  ? _enviarSms(widget.cliente, widget.telefono,
                      widget.fechaCita, widget.servicio)
                  : alerta(context); //  /utils/alertaNodisponible.dart
            },
            child: const Card(
              child: ListTile(
                title: Text('SMS'),
                subtitle: Text(
                  'El coste de SMS dependerá de su operadora telefónica',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                trailing: Icon(Icons.sms),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String textoCompartir(PerfilModel perfilUsuarioApp, String clienta,
      String fecha, String servicio) {
    //EL MENSAJE CAMBIA SI HAY INICIADO UN USUARIO DE APP
    if (perfilUsuarioApp.denominacion != '') {
      return 'Hola $clienta,\n' +
          'su cita ha sido reservada con ${perfilUsuarioApp.denominacion} para el día $fecha h.\n'
              'Servicio a realizar : $servicio.\n\n'
              'Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.\n\n'
              'Telefono: ${perfilUsuarioApp.telefono}\n'
              'Web: ${perfilUsuarioApp.website}\n'
              'Facebook: ${perfilUsuarioApp.facebook}\n'
              'Instagram: ${perfilUsuarioApp.instagram}\n'
              'Dónde estamos: ${perfilUsuarioApp.ubicacion}\n';
    } else {
      return 'Hola $clienta,\n'
          'su cita ha sido reservada para el día $fecha h.\n'
          'Servicio a realizar : $servicio.\n\n'
          'Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.';
    }
  }

  _enviarWhatsapp(PerfilModel perfilUsuarioApp, String clienta, String telefono,
      String fecha, String servicio) async {
    String telef = '+$telefono';

    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);

    await launch('https://api.whatsapp.com/send?phone=$telef&text=$texto');
  }

  _enviarEmail(
      String clienta, String email, String fecha, String servicio) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': texto,
      }),
    );

    await launchUrl(emailLaunchUri);
  }

  _enviarSms(
      String clienta, String telefono, String fecha, String servicio) async {
    String texto = textoCompartir(perfilUsuarioApp, clienta, fecha, servicio);
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: telefono,
      queryParameters: <String, String>{
        'body': texto,
      },
    );

    await launchUrl(smsLaunchUri);
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