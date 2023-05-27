import 'package:flutter/material.dart';

Future<void> dialogoLinealProgressIndicator(context, String texto) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
        ),
      );
    },
  );
}
