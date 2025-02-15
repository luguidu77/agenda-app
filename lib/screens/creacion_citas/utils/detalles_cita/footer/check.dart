import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckCompartir extends StatefulWidget {
  const CheckCompartir({super.key});

  @override
  State<CheckCompartir> createState() => _CheckCompartirState();
}

class _CheckCompartirState extends State<CheckCompartir> {
  @override
  Widget build(BuildContext context) {
    final citaProvider = context.watch<CreacionCitaProvider>();
    return Checkbox(
        value: citaProvider.estadoCheck,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              citaProvider.setEstadoCheck(value);
            });
            print(value ? 'Seleccionado' : 'No seleccionado');
          }
        });
  }
}
