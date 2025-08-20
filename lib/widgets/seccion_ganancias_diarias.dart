import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/calendario_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/personaliza_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class SeccionGananciasDiarias extends StatefulWidget {
  const SeccionGananciasDiarias({super.key});

  @override
  State<SeccionGananciasDiarias> createState() =>
      _SeccionGananciasDiariasState();
}

class _SeccionGananciasDiariasState extends State<SeccionGananciasDiarias> {
  @override
  Widget build(BuildContext context) {
    return gananciaDiaria(context);
  }

  Future<String> getGanancias(
      BuildContext context, List<CitaModelFirebase> todasLasCitas) async {
    // Obtener la fecha seleccionada y formatearla
    var calendarioProvider = context.watch<CalendarioProvider>();
    String fechaElegidaFormateada =
        DateFormat('yyyy-MM-dd').format(calendarioProvider.fechaSeleccionada);

    // Filtrar citas por fecha seleccionada y calcular la ganancia diaria
    double gananciaDiaria = todasLasCitas
        .where((value) => value.dia == fechaElegidaFormateada)
        .fold(0.0, (sum, cita) {
      double precio = double.tryParse(cita.precio ?? '0') ?? 0.0;
      return sum + precio;
    });

    // Devolver 0 si la ganancia es cero, de lo contrario formatear con dos decimales
    return gananciaDiaria == 0
        ? '0.00'
        : NumberFormat("#.00").format(gananciaDiaria);
  }

  FutureBuilder<dynamic> gananciaDiaria(BuildContext context) {
    // TRAIGO PERSONALIZA PARA LA MONEDA
    final contextoPersonaliza = context.watch<PersonalizaProviderFirebase>();
    final personaliza = contextoPersonaliza.getPersonaliza;

    var citasProvider = Provider.of<CitasProvider>(context, listen: false);
    List<CitaModelFirebase> todasLasCitas = citasProvider.getCitas;

    return FutureBuilder<String>(
      future: getGanancias(context, todasLasCitas),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 70,
            child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                lines: 1,
                spacing: 1,
                lineStyle: SkeletonLineStyle(
                  height: 35,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('');
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            final moneda = personaliza.moneda ??
                ''; // Asigna un valor predeterminado si es null
            // Fondo rectangular con el borde izquierdo redondeado
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Color de fondo
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                ' $data $moneda', // Muestra la ganancia diaria}',
                style: textoEstilo,
              ),
            );
          } else {
            return const Text('Empty data');
          }
        } else {
          return const Text('fdfd');
        }
      },
    );
  }
}
