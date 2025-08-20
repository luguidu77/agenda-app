import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/comprobacion_reasignacion_citas.dart';
import 'package:agendacitas/providers/empleados_provider.dart';
import 'package:agendacitas/providers/estado_pago_app_provider.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Alertas {
  static Widget agregarEmpleadoAlerta(context, {bool enableOnTap = true}) {
    return Expanded(
      child: InkWell(
        onTap: () => enableOnTap
            ? Navigator.pushNamed(context, 'empleadosScreen')
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // Espaciado interno
          margin: const EdgeInsets.all(16), // Margen alrededor
          decoration: BoxDecoration(
            color: Colors.orange, // Color de fondo llamativo
            borderRadius: BorderRadius.circular(8), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Sombra ligera
                blurRadius: 4, // Difusión de la sombra
                offset: const Offset(0, 2), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: const Row(
            spacing: 12,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white, // Ícono en blanco
                size: 20,
              ),
              Expanded(
                child: Text(
                  'Debe haber al menos, un empleado con rol "personal" para asignarle citas',
                  style: TextStyle(
                    fontSize:
                        14, // Texto más grande que el original para mejor legibilidad
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // Texto en blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget reasignacionCitas(context) {
    return Expanded(
      child: InkWell(
        onTap: () => _procesarReasignacion(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12), // Espaciado interno
          margin: const EdgeInsets.all(16), // Margen alrededor
          decoration: BoxDecoration(
            color: Colors.orange, // Color de fondo llamativo
            borderRadius: BorderRadius.circular(8), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Sombra ligera
                blurRadius: 4, // Difusión de la sombra
                offset: const Offset(0, 2), // Desplazamiento de la sombra
              ),
            ],
          ),
          child: const Row(
            spacing: 12,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white, // Ícono en blanco
                size: 20,
              ),
              Expanded(
                child: Text(
                  'Se ha detectado que hay citas sin empleados asignados, esto dará errores graves por lo que debe tratarlo, pulse aquí para reasignarlas',
                  style: TextStyle(
                    fontSize:
                        14, // Texto más grande que el original para mejor legibilidad
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // Texto en blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _procesarReasignacion(BuildContext context) {
    final usuarioAppProvider = context.read<EstadoPagoAppProvider>();

    final empleados = context.read<EmpleadosProvider>();
    EmpleadoModel empleado = empleados.getEmpleados.first;

    final citasProvider = context.read<CitasProvider>();
    final List<CitaModelFirebase> citas = citasProvider.getCitas;

    // mensaje de alerta
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informamos que:'),
          content: const Text(
              'Se va a proceder a reasignar las citas sin empleados.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // reasignar todoas las citas en Firebase
                bool res = false;
                for (var cita in citas) {
                  res = await FirebaseProvider().reasignacionCtasEmpleado(
                      usuarioAppProvider.emailUsuarioApp, cita.id, empleado.id);
                }
                res
                    ? mensajeSuccess(context, 'Citas reasignadas correctamente')
                    : mensajeError(
                        context, 'Error: contacta con el administrador');
                // reasignar todoas las citas en el contexto

                context.read<CitasProvider>().reasignacionCita();

                // establecer el contexto de reasignación a true para que no se visualice más alerta
                context
                    .read<ComprobacionReasignacionCitas>()
                    .setReasignado(true);

                // cerrar el dialogo
                Navigator.of(context).pop();
              },
              child: const Text('Proceder'),
            ),
          ],
        );
      },
    );
  }
}
