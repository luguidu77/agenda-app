import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeleccionFechaHora {
  Future<DateTime?> seleccionFecha(context) async {
    var firstDate = DateTime.now().subtract(const Duration(days: 60));
    var lastDate = DateTime.now().add(const Duration(days: 365));
    Intl.defaultLocale = 'es_EU';
    // print(localization.supportedLocales);
    DateTime? diaSeleccionado = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return child!;
      },
    );

    return diaSeleccionado;
  }

  Future<TimeOfDay?> seleccionHora(context) async {
    TimeOfDay time = const TimeOfDay(hour: 1, minute: 00);
    Intl.defaultLocale = 'es';

    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      helpText: 'INTRODUCE HORA DE LA CITA',
      initialEntryMode: TimePickerEntryMode.dialOnly,
      hourLabelText: 'Horas',
      minuteLabelText: 'Minutos',
      initialTime: time,
    );

    return newTime;
  }
}
