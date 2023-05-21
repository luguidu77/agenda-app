import 'dart:async';

import 'package:flutter/material.dart';

class FloatingActionButonWidget extends StatefulWidget {
  const FloatingActionButonWidget({
    Key? key,
    required this.icono,
    required this.texto,
    required this.funcion,
  }) : super(key: key);
  final Icon icono;
  final String texto;
  final dynamic funcion;
  @override
  State<FloatingActionButonWidget> createState() =>
      _FloatingActionButonWidgetState();
}

class _FloatingActionButonWidgetState extends State<FloatingActionButonWidget> {
  bool floatExtended = false;
  Timer? t;
  retardo() {
    t = Timer(const Duration(milliseconds: 500), () {
      t!.cancel();
      floatExtended = true;
      if (mounted) {
        setState(() {});
      }

      // Here you can write your code for open new view
    });
    // and later, before the timer goes off...
    //t.cancel();
  }

  @override
  void initState() {
    retardo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(widget.texto),
      isExtended: floatExtended,
      icon: widget.icono,
      onPressed: widget.funcion,
    );
  }
}
