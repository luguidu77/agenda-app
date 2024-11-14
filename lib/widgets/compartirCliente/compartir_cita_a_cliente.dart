import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';

class CompartirCitaConCliente extends StatefulWidget {
  final String cliente;
  final String telefono;
  final dynamic email;
  final dynamic fechaCita;
  final dynamic servicio;
  final dynamic precio;
  const CompartirCitaConCliente(
      {Key? key,
      required this.cliente,
      required this.telefono,
      required this.email,
      required this.fechaCita,
      required this.servicio,
      required this.precio})
      : super(key: key);

  @override
  State<CompartirCitaConCliente> createState() =>
      _CompartirCitaConClienteState();
}

class _CompartirCitaConClienteState extends State<CompartirCitaConCliente> {
  bool animarIcon = false;
  String _emailSesionUsuario = '';
  late PerfilModel perfilUsuarioApp;
  bool pagado =
      true; //deshabilitado, por defecto la variable pagado=true; podria usarlo por ejemplo para hacer una alerta de comprar la app
  String? telefonoCodpais;

  bool visible = true;

  late PersonalizaProviderFirebase contextoPersonalizaFirebase;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
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
    final personalizaProvider =
        Provider.of<PersonalizaProviderFirebase>(context, listen: false);
    PersonalizaModelFirebase personaliza = personalizaProvider.getPersonaliza;
    //COMPRUEBO QUE HAY UN CODIGO DE PAIS ESTABLECIDO PREVIAMENTE, SI NO , ESTABLEZCO EL 34 POR DEFECTO

    return (personaliza.codpais!.isNotEmpty)
        ? int.parse(personaliza.codpais!)
        : 34;
  }

  _estableceCodPais() async {
    int codPais = 34;
    await _getCodPais();

    telefonoCodpais = codPais.toString() + widget.telefono;
    print('telefono -------------$telefonoCodpais');
  }

  _perfilUsuarioApp() async {
    //traigo email del usuario, del PagoProvider

    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;

    //traigo perfil del usuariode la app desde firebase
    await FirebaseProvider().cargarPerfilFB(_emailSesionUsuario).then((value) {
      //setState(() {});
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
    // print(perfilUsuarioApp.telefono);

    // rescat el texto par enviar a los clientes desde firebase
    contextoPersonalizaFirebase = context.read<PersonalizaProviderFirebase>();
    personaliza = contextoPersonalizaFirebase.getPersonaliza;
    textoActual = personaliza.mensaje.toString();
    /* // Muestra tarjeta de sugerencia si no hay denominación del perfil de usuario
        if (perfilUsuarioApp.denominacion == '')
          TarjetaInfo(
            colorTexto: Colors.white,
            colorTarjeta: const Color.fromARGB(83, 64, 88, 226),
            icono: const FaIcon(FontAwesomeIcons.exclamation),
            titulo: 'SUGERENCIA',
            texto: 'Edita tu perfil para que se comparta en las citas',
            accion: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfigUsuarioApp()),
            ),
          ), */

    return
        /*  */
        // Botones de acciones flotantes
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () {
            print('comparte whatsapp');
            /*   print(perfilUsuarioApp.email);
            print(textoActual);
            print(widget.cliente);
            print(telefonoCodpais);
            print(widget.fechaCita);
            print(widget.servicio) */
            try {
              Comunicaciones().compartirCitaWhatsapp(
                perfilUsuarioApp,
                textoActual,
                widget.cliente,
                telefonoCodpais!,
                widget.fechaCita,
                widget.servicio,
              );
            } catch (e) {
              debugPrint(
                  'error de datos al compartir por whatsapp. compartir_cita_a_cliente.dart: ${e.toString()}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Error al compartir por whatsapp. compartir_cita_a_cliente.dart: ${e.toString()}'),
                duration: const Duration(seconds: 6),
              ));
            }
          },
          backgroundColor: Colors.green,
          child: const FaIcon(FontAwesomeIcons.whatsapp),
        ),
        FloatingActionButton(
          mini: true,
          onPressed: () {
            try {
              pagado
                  ? Comunicaciones().compartirCitaSms(
                      perfilUsuarioApp,
                      textoActual,
                      widget.cliente,
                      widget.telefono,
                      widget.fechaCita,
                      widget.servicio)
                  : alerta(context); // Mostrar alerta si no está pagado
            } catch (e) {
              debugPrint(
                  'error de datos al compartir por sms. compartir_cita_a_cliente.dart: ${e.toString()}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Error al compartir por sms. compartir_cita_a_cliente.dart: ${e.toString()}'),
                duration: const Duration(seconds: 6),
              ));
            }
          },
          backgroundColor: Colors.orange,
          child: const FaIcon(FontAwesomeIcons.commentSms),
        ),
        widget.email != '' && widget.email != ''
            ? FloatingActionButton(
                mini: true,
                onPressed: () {
                  animarIcon = true;
                  setState(() {});

                  Future.delayed(const Duration(seconds: 3), () {
                    animarIcon = false;
                    setState(() {});
                  });
                  try {
                    pagado
                        ? Comunicaciones().compartirCitaEmail(
                            context,
                            perfilUsuarioApp,
                            textoActual,
                            widget.cliente,
                            widget.email,
                            widget.fechaCita,
                            widget.servicio,
                            widget.precio)
                        : alerta(context);
                  } catch (e) {
                    debugPrint(
                        'error de datos al compartir por email. compartir_cita_a_cliente.dart: ${e.toString()}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Error al compartir por email. compartir_cita_a_cliente.dart: ${e.toString()}'),
                      duration: const Duration(seconds: 6),
                    ));
                  }
                },
                backgroundColor: Colors.blue,
                child: animarIcon
                    ? const CircularProgressIndicator()
                    : const FaIcon(FontAwesomeIcons.envelope),
              )
            : Container(),
      ],
    );
    /*  const SizedBox(height: 20),
        const Text(
          'El coste de SMS dependerá de su operadora telefónica',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
        const Text(
          '',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
      ], */
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