
/* import 'package:agendacitas/screens/screens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:pay/pay.dart' as pay;
import 'package:url_launcher/url_launcher.dart';

const _paymentItems = [
  pay.PaymentItem(
    label: 'Total',
    amount: '1.50',
    status: pay.PaymentItemStatus.final_price,
  )
];

class ComprarAplicacion extends StatefulWidget {
  const ComprarAplicacion({Key? key}) : super(key: key);

  @override
  State<ComprarAplicacion> createState() => _ComprarAplicacionState();
}

class _ComprarAplicacionState extends State<ComprarAplicacion> {
  double? valorindicator;
  bool configuracionFinalizada = false;
  bool visible = true;
  bool visibleBotonGPAY = false;
  bool visibleIndicator = false;
  bool visibleFormulario = false;
  bool visiblePagoRealizado = false;
  bool visibleGuardarPagoRealizado = false;
  bool visibleRespaldoRealizado = false;
  // MyLogicUsuarioAPP myLogic = MyLogicUsuarioAPP();

  final GlobalKey _key = GlobalKey();

  void update() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: _key,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(''),
          actions: [
            IconButton(
                onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Bienvenida(
                              // usuarioAPP: email,
                              )),
                    ),
                icon: const Icon(Icons.close)),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  visible
                      ? Column(
                          children: [
                            const Text(
                              'Mejoras versión de pago:\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                                '👉 Sin publicidad para ahorrar tiempo a tus clientes.\n'
                                '👉 Con nuevas características.\n'
                                '👉 Crea una cuenta en la nube y accede desde otro dispositivo.\n'
                                '🌍 Publicamos tu actividad en agendadecitas.online, marketplace de profesionales como tú que ofrecen diferentes servicios y desde la que futuros clientes podrán reservar contigo.\n'),

                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                        text:
                                            '🧐 En el formulario de pago introduce el',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 136, 133, 133))),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                        text:
                                            'mismo email de sesión de la aplicación'),
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                        text:
                                            'para una vez comprobado el pago poder activar tu cuenta como pagada.(ES UN PROCESO MANUAL)'),
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 136, 133, 133)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'UN SÓLO PAGO !!!, NO HAY SUSCRIPCIONES',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            //botonGPAY(context), ############## BOTON GOOGLE PAY -------------------------------------
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // 5,45€ https://buy.stripe.com/7sIcPEclB53EbCwfYY
                                    const url =
                                        'https://buy.stripe.com/4gwcPE5XdeEecGA001'; //10,90€
                                    if (await launchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.app_registration_rounded),
                                  label: const Text('Comprar')),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                            const Divider(),
                            const Text(
                              'En proyecto versión PREMIUM: \n\n',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                                'Creación App para tus clientes, con opción a coger cita desde su app.\n'),
                            /*  ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromARGB(
                                            255, 171, 172, 173))),
                                onPressed: () => {},
                                icon: const Icon(Icons.app_registration_rounded),
                                label: const Text('Pago de la aplicación')), */
                          ],
                        )
                      : const Text('Pago de la aplicación'),

                  //? FORMULARIO REGISTRO
                  visibleFormulario
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            child: Column(
                              children: [
                                const TextField(
                                  controller: null,
                                  decoration:
                                      InputDecoration(labelText: 'Email'),
                                ),
                                const TextField(
                                  keyboardType: TextInputType.number,
                                  controller: null,
                                  decoration:
                                      InputDecoration(labelText: 'Contraseña'),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton.icon(
                                    onPressed: () => {
                                          update(),
                                          //  visibleIndicator = false,

                                          visibleBotonGPAY = true
                                        },
                                    icon: const Icon(
                                        Icons.app_registration_rounded),
                                    label: const Text('REGISTRAR'))
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  //?BOTON PAGA CON GOOGLEPAY
                  visibleBotonGPAY ? botonGPAY(context) : Container(),
                  //? INDICATOR ESPERA...

                  visibleIndicator
                      ? Column(
                          children: [
                            configuracionFinalizada
                                ? Container()
                                : LinearProgressIndicator(
                                    value: valorindicator,
                                    color: Colors.greenAccent,
                                    backgroundColor: Colors.green,
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  visiblePagoRealizado
                                      ? const Icon(Icons.check)
                                      : const SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator()),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Pago app Pro')
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  visibleGuardarPagoRealizado
                                      ? const Icon(Icons.check)
                                      : const SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator()),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Guardado de pago')
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  visibleRespaldoRealizado
                                      ? const Icon(Icons.check)
                                      : const SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator()),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Respaldo en la nube')
                                ],
                              ),
                            ),
                            configuracionFinalizada
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      color: const Color.fromARGB(
                                          255, 172, 240, 174),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                                '¡ Configuración realizada con exito !'),
                                            Text(
                                                'Reinicia la App e inicia sesión')
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.red,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('NO CIERRE LA APLICACIÓN',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ))
                          ],
                        )
                      : Container(),

                  //  visiblePagoRealizado
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  botonGPAY(BuildContext context) {
    return pay.GooglePayButton(
      paymentConfigurationAsset: 'google_pay_payment_profile.json',
      paymentItems: _paymentItems,
      margin: const EdgeInsets.only(top: 15),
      onPaymentResult: onGooglePayResult,
      loadingIndicator: const Center(
        child: CircularProgressIndicator(),
      ),
      onPressed: () async {
        // 1. Add your stripe publishable key to assets/google_pay_payment_profile.json

        visibleBotonGPAY = false;

        await debugChangedStripePublishableKey();
      },
      childOnError:
          const Text('Google Pay no está habilitado en este dispositivo'),
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error mientras se intentaba realizar el pago'),
          ),
        );
      },
    );
  }

  Future<void> onGooglePayResult(paymentResult) async {
    //? VISUALIZA IDICADOR, NO VISUALIZA FORMULARIO NI BOTON REGISTRAR
    visibleIndicator = true;
    visibleFormulario = false;

    setState(() {});
    try {
      // 1. Add your stripe publishable key to assets/google_pay_payment_profile.json

      debugPrint(paymentResult.toString());
      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret();
      final clientSecret = response['client_secret'];
      final token =
          paymentResult['paymentMethodData']['tokenizationData']['token'];
      final tokenJson = Map.castFrom(json.decode(token));
      print('response ------------$response');
      // print('response ------------${tokenJson['']}');

      print('token ------------$tokenJson');

      final params = PaymentMethodParams.cardFromToken(
        paymentMethodData: PaymentMethodDataCardFromToken(
          token: tokenJson['id'], // TODO extract the actual token
        ),
      );

      // 3. Confirm Google pay payment method
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: params,
      );

      //? -------PAGO REALIZADO -------------------
      visiblePagoRealizado = true;

      setState(() {});
      //GUARDA PAGO EN DISPOSITIVO
      //  PagoProvider().guardaPagado(true, myLogic.textControllerEmail.text);
      //GUARDA PAGO EN FIREBASE
      //  FirebaseProvider().actualizaPago(myLogic.textControllerEmail.text); //
      visibleGuardarPagoRealizado = true;

      // RESPALDO DATOS EN FIREBASE
      // SincronizarFirebase().sincronizaSubeFB(myLogic.textControllerEmail.text);
      visibleRespaldoRealizado = true;
      configuracionFinalizada = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret() async {
    Map<String, String> headers = {
      'Authorization':
          "Bearer sk_test_51JpFagEaW0pHhZCIc85qc0cj9mVnFK9wZPdjtoPXCVVf3dSHYfhvEf2RWD3W8MqJq6HgYUDfhKrKq3gVLoboyumt00GIMvQ8aJ",
      'Content-type': 'application/x-www-form-urlencoded'
    };
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

    Map<String, dynamic> body = {
      "amount": '545',
      "currency": "eur",
    }; //payment_method_types: [] : 'card'
    var response = await http.post(url, headers: headers, body: body);
    return jsonDecode(response.body);
  }

  Future<void> debugChangedStripePublishableKey() async {
    if (kDebugMode) {
      final profile =
          await rootBundle.loadString('assets/google_pay_payment_profile.json');
      final isValidKey = !profile.contains('<ADD_YOUR_KEY_HERE>');
      assert(
        isValidKey,
        'No stripe publishable key added to assets/google_pay_payment_profile.json',
      );
    }
  }
}
 */