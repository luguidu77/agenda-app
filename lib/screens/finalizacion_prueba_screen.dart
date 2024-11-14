import 'dart:async';

import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class FinalizacionPrueba extends StatefulWidget {
  final usuarioAPP;
  const FinalizacionPrueba({Key? key, this.usuarioAPP = ''}) : super(key: key);

  @override
  State<FinalizacionPrueba> createState() => _FinalizacionPruebaState();
}

class _FinalizacionPruebaState extends State<FinalizacionPrueba> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<dynamic> _streamSubscription;
  List<ProductDetails> _products = [];
  final _variant = {"agenda"}; // id del producto googleplay console

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //// pago de la aplicacion
    Stream pruchaseUpdated = InAppPurchase.instance.purchaseStream;
    _streamSubscription = pruchaseUpdated.listen((purchaseList) {
      _listenToPurchase(purchaseList);
    }, onDone: () {
      _streamSubscription.cancel();
    }, onError: (error) {
      mensajeError(context, '$error');
    });

    initStore();
    ///////////////////////////////
  }

  _listenToPurchase(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        mensajeInfo(context, 'Pendiente');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        mensajeError(context, 'Error');
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        mensajeSuccess(context, 'Pago realizado');
        _modificaPagoFb();
      }
    });
  }

  //!!!!! COMPRA CON GOOGLEPAY !!!!!!!
  _buy() {
    final PurchaseParam param = PurchaseParam(productDetails: _products[0]);
    _inAppPurchase.buyConsumable(purchaseParam: param);
  }

  initStore() async {
    // Asegúrate de que este ID sea el correcto y esté configurado en Google Play Console
    ProductDetailsResponse productDetailsResponse =
        await _inAppPurchase.queryProductDetails(_variant);
    if (productDetailsResponse.error == null) {
      if (productDetailsResponse.productDetails.isNotEmpty) {
        setState(() {
          _products = productDetailsResponse.productDetails;
        });
      } else {
        mensajeError(context, 'No se encontraron productos.');
      }
    } else {
      mensajeError(context, 'Error al recuperar los detalles del producto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final parametros = ModalRoute.of(context)?.settings.arguments;
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hola, ${widget.usuarioAPP.toString().split('@')[0]}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'El periodo de prueba ha finalizado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¿Deseas continuar disfrutando de todas las funcionalidades?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    _buy(); // Asumiendo que tienes un método para iniciar la compra
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Sí, un sólo pago 💳 sin suscripción',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: () async {
                    await PagoProvider().guardaPagado(false, '');
                    await FirebaseAuth.instance.signOut();
                    estadoPagoProvider.estadoPagoEmailApp('');

                    _irPaginaInicio();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'No, en otro momento',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*   _irPaginaCompra() {
    // compra con pagina Stripe
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const ComprarAplicacion(
              // usuarioAPP: email,
              )),
    );
  } */

  _irPaginaInicio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(
                index: 0,
                myBnB: 0,
              )),
    );
  }

  void _modificaPagoFb() async {
    // LLEE CONTEXTO ESTADO DE PAGO y lo seteo a COMPRADA
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    estadoPagoProvider.setearPagado('COMPRADA');
    //ACTUALIZO PAGO EN FIREBASE
    await FirebaseProvider().actualizaPago(widget.usuarioAPP);
    _irPaginaInicio();
  }
}
