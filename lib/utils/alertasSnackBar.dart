import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> alerta(context) {
  var snackBar = const SnackBar(
    content: Text('NO DISPONIBLE EN LA VERSION GRATUITA'),
  );

  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> alertaNoEmail(
    context) {
  var snackBar = const SnackBar(
    content: Text('ESTE CLIENTE NO TIENE EMAIL'),
  );

  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

mensajeSuccess(context, String texto) {
  return showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      message: texto,
    ),
  );
}

mensajeInfo(context, String texto) {
  return showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info(
      message: texto,
    ),
  );
}

mensajeError(context, String texto) {
  return showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: texto,
    ),
  );
}
