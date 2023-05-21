import 'package:flutter/material.dart';

@override
Future targetaRegistroUsuarioAPP(BuildContext context) {
  return showModalBottomSheet(
    isDismissible: false,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    context: context,
    builder: (context) => Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            Text('Pago realizado !'),
          ],
        ),
        ElevatedButton.icon(
            onPressed: () => {
                  //TODO :   ir a inicio
                  Navigator.pop(context)
                },
            icon: const Icon(Icons.check),
            label: const Text('ACEPTAR')),
      ],
    ),
    // content: Text('Registra la app'),
  );
}
