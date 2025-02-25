import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:agendacitas/screens/creacion_citas/utils/detalles_cita/exportaciones_detalles_cita.dart';
import 'package:agendacitas/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class DetallesCitaWidget extends StatefulWidget {
  final CitaModelFirebase? reserva;
  final String fechaCorta;
  final bool citaconfirmada;
  final String emailUsuario;
  final bool iniciadaSesionUsuario;

  const DetallesCitaWidget({
    super.key,
    this.reserva,
    required this.fechaCorta,
    required this.citaconfirmada,
    required this.emailUsuario,
    required this.iniciadaSesionUsuario,
  });

  @override
  State<DetallesCitaWidget> createState() => _DetallesCitaWidgetState();
}

class _DetallesCitaWidgetState extends State<DetallesCitaWidget> {
  late DateTime
      _fechaOriginal; // utlizo esta variable para verificar si se modificó la fecha antes de salir de la vista

  @override
  void initState() {
    super.initState();
    _fechaOriginal = (widget.reserva!.horaInicio!);
  }

  @override
  Widget build(BuildContext context) {
    String dia = formatearFechaDiaCita(widget.reserva!.horaInicio!);
    final personaliza =
        context.read<PersonalizaProviderFirebase>().getPersonaliza;
    bool citaConfirmada = widget.reserva!.confirmada!;
    final citaContexto = context.read<CreacionCitaProvider>();
    citaContexto.contextoCita.dia = dia;
    citaContexto.setContextoCita(widget.reserva!);

    return Scaffold(
      appBar: AppBar(
        //title: Text(fechaCorta, style: subTituloEstilo),
        leading: Container(),
        backgroundColor: citaConfirmada ? Colors.blue : Colors.red,
        elevation: 0,
        actions: [
          IconButton(
              color: Colors.white,
              onPressed: () {
                if (citaContexto.visibleGuardar == false) {
                  // no se ha modificado la fecha

                  Navigator.pop(context);
                } else {
                  // se ha modificado la fecha
                  _alertaSinGuardar();
                }
              },
              icon: const Icon(Icons.close)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER DE LA VISTA   ################################
              // fecha y boton reserva
              HeaderSection(
                // fecha: _fechaOriginal,
                reserva: widget.reserva!,
                citaconfirmada: citaConfirmada,
              ),
              const SizedBox(height: 20),
              // CONTENIDO DE LA VISTA ################################
              // Cliente, fecha y hora, servicios
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ContentSection(
                    reserva: widget.reserva!,
                    personaliza: personaliza,
                    emailUsuario: widget.emailUsuario,
                  ),
                ),
              ),
              // FOOTER DE LA VISTA ################################

              FooterSeccion(
                reserva: widget.reserva!,
                emailUsuario: widget.emailUsuario,
                contextoCitaProvider: context.read<CitasProvider>(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _alertaSinGuardar() {
    final citaContexto = context.read<CreacionCitaProvider>();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 20,
                  children: [
                    const Text('Tienes cambios sin guardar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                    const Text(
                      'Si cierras la cita perderás los cambios, ¿deseas salir?',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Alinea el botón a la derecha
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 30),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Text(
                              'Volver',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // no visualizar el footer_guardar_cambios.dart
                            citaContexto.setVisibleGuardar(false);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: const Text(
                              'Sí, salir',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ));
        });
  }
}

class EmpleadoAvatar extends StatelessWidget {
  final EmpleadoModel empleado;
  final bool esFichaEmpleado;

  const EmpleadoAvatar(
      {super.key, required this.empleado, this.esFichaEmpleado = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: empleado.foto != ''
              ? NetworkImage(empleado.foto) as ImageProvider
              : const AssetImage('assets/images/nofoto.jpg'),
          radius: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              empleado.nombre,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (esFichaEmpleado)
              Text(
                empleado.telefono,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}

class TarjetaCliente extends StatelessWidget {
  final ClienteModel cliente;

  const TarjetaCliente({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _fotoCliente(cliente.foto),
          const SizedBox(width: 15),
          _infoCliente(cliente),
        ],
      ),
    );
  }

  Widget _fotoCliente(String? fotoUrl) {
    return CircleAvatar(
      backgroundImage: fotoUrl != null && fotoUrl.isNotEmpty
          ? NetworkImage(fotoUrl)
          : const AssetImage("assets/images/nofoto.jpg") as ImageProvider,
      radius: 30,
    );
  }

  Widget _infoCliente(ClienteModel cliente) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cliente.nombre ?? 'Sin nombre',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 5),
          if (cliente.nota != null && cliente.nota.toString().isNotEmpty)
            Text(
              cliente.nota!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
