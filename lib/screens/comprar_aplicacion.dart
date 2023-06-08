import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:pay/pay.dart' as pay;

const _paymentItems = [
  pay.PaymentItem(
    label: 'Total',
    amount: '9.00',
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

  GlobalKey _key = new GlobalKey();

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
      key: _key,
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Versión PRO'),
          actions: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                visible
                    ? Column(
                        children: [
                          const Text(
                            'Mejoras versión PRO: \n\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                              'Sin publicidad para ahorrar tiempo a tus clientes. \n\n'
                              'Con nuevas características como "ficha de cliente" \n\n'
                              'Sincronización en la nube y envios sms /email a tus clientes. \n\n'),
                          ElevatedButton.icon(
                              onPressed: () => {
                                    update(),
                                    visibleFormulario = true,
                                    visible = false,
                                  },
                              icon: const Icon(Icons.app_registration_rounded),
                              label: const Text('Pago y registro online')),
                          const SizedBox(
                            height: 50,
                          ),
                          const Divider(),
                          const Text(
                            'En proyecto versión PREMIUM: \n\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                              'Creación App para tus clientes, con opción a coger cita desde su app. \n\n'
                              'Marketplace App de profesionales como tú que ofrecen diferentes servicios" \n\n'),
                          ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 171, 172, 173))),
                              onPressed: () => {},
                              icon: const Icon(Icons.app_registration_rounded),
                              label: const Text('Pago y registro online')),
                        ],
                      )
                    : const Text('Pago y Registro online'),

                //? FORMULARIO REGISTRO
                visibleFormulario
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Column(
                            children: [
                              TextField(
                                controller: null,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: null,
                                decoration: const InputDecoration(
                                    labelText: 'Contraseña'),
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
                                    color: Color.fromARGB(255, 172, 240, 174),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: const [
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
                                        style: TextStyle(color: Colors.white)),
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
