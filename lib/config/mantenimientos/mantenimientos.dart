import 'package:agendacitas/config/mantenimientos/firebase_manteninimientos.dart';
import 'package:agendacitas/providers/Firebase/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Mantenimientos extends StatefulWidget {
  final String? emailSesionUsuario;

  const Mantenimientos({Key? key, this.emailSesionUsuario}) : super(key: key);

  @override
  State<Mantenimientos> createState() => _MantenimientosState();
}

class _MantenimientosState extends State<Mantenimientos> {
  @override
  void initState() {
    super.initState();
    _comprobacionMantenimiento(widget.emailSesionUsuario);
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Aquí deberías retornar el contenido principal de tu pantalla
  }

  Future<void> _comprobacionMantenimiento(String? emailSesionUsuario) async {
    try {
      // Consultar el documento dentro de la subcolección 'usuario'
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('agendacitasapp')
          .doc(emailSesionUsuario)
          .get();

      // Verificar si el campo 'a' existe en el documento
      dynamic fieldValue;
      if (snapshot.exists) {
        dynamic docs = snapshot.data();
        fieldValue = docs.containsKey('a');
      }

      // Mostrar un diálogo de mantenimiento si el campo 'a' existe y es verdadero
      if (fieldValue == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return DialogoMantenimiento(
                emailUsuaio: widget.emailSesionUsuario!);
          },
        );
      }
    } catch (error) {
      // Manejar errores
      print('Error al verificar el mantenimiento: $error');
    }
  }
}

class DialogoMantenimiento extends StatefulWidget {
  final String emailUsuaio;
  const DialogoMantenimiento({Key? key, required this.emailUsuaio})
      : super(key: key);

  @override
  State<DialogoMantenimiento> createState() => _DialogoMantenimientoState();
}

class _DialogoMantenimientoState extends State<DialogoMantenimiento> {
  //**** TEXTOS TRABAJO REALIZADO */
  String textoTrabajosRealizados = 'Cambio de ubicacion del perfil y pago';

  bool _finalizado = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.construction),
          SizedBox(width: 15),
          Text(
            'MANTENIMIENTOS',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _finalizado
              ? const Icon(Icons.check)
              : const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(_finalizado ? 'TRABAJO FINALIZADO' : 'ESPERE...'),
        ],
      ),
      actions: [
        Visibility(
          visible: _finalizado,
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MaintenanceDialog();
                },
              ); // Cerrar el diálogo
            },
            child: const Text('+ info'),
          ),
        ),
        Visibility(
          visible: _finalizado,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
              MantenimientosFirebase.nuevoMantenimiento(
                  widget.emailUsuaio, textoTrabajosRealizados);
            },
            child: const Text('Cerrar'),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Simular un retraso para el mantenimiento
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _finalizado = true;
      });
    });
  }
}

class MaintenanceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mejoras realizadas'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimado cliente,\n\n'
              'Nos complace informarle que hemos llevado a cabo una mejora en su sistema mediante la optimización de la estructura de datos del perfil de usuario. Nuestro objetivo ha sido mejorar el rendimiento de su plataforma mediante una organización más eficiente de la información del usuario.\n\n'
              '**Beneficios:**\n'
              '- Mayor eficiencia y velocidad de respuesta.\n'
              '- Experiencia del usuario mejorada.\n'
              '- Diseño escalable y fácil de mantener.\n\n'
              'Queremos asegurarnos de que su plataforma siga brindando la mejor experiencia posible a sus usuarios, y estamos encantados de haber podido implementar esta mejora para lograr ese objetivo.\n\n'
              'Atentamente,\n'
              'Juan M.',
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
          },
          child: Text('Cerrar'),
        ),
      ],
    );
  }
}
// Para mostrar el diálogo, simplemente llama a showDialog:
 