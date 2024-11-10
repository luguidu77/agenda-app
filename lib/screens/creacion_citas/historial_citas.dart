import 'package:agendacitas/models/personaliza_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';

class HistorialCitas extends StatefulWidget {
  final ClienteModel clienteParametro;
  const HistorialCitas({Key? key, required this.clienteParametro})
      : super(key: key);

  @override
  State<HistorialCitas> createState() => _HistorialCitasState();
}

class _HistorialCitasState extends State<HistorialCitas> {
  late PersonalizaProviderFirebase personalizaProvider;
  PersonalizaModelFirebase personaliza = PersonalizaModelFirebase();
  final List<Map<String, dynamic>> _citas = [];
  bool pagado = false;
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;

  @override
  void initState() {
    inicializacion();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TRAE CONTEXTO PERSONALIZA ( MONEDA )
    personalizaProvider = context.read<PersonalizaProviderFirebase>();
    personaliza = personalizaProvider.getPersonaliza;
    return Scaffold(
      body: _historial(context, _citas, widget.clienteParametro.id),
    );
  }

  _historial(context, List<Map<String, dynamic>> citas, idCliente) {
    return FutureBuilder<dynamic>(
        future: _iniciadaSesionUsuario
            ? FirebaseProvider()
                .cargarCitasPorCliente(_emailSesionUsuario, idCliente)
            : CitaListProvider().cargarCitasPorCliente(idCliente),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 1,
                  spacing: 5,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 70,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            );
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            //#### SNAPSHOT TRAE LAS CITAS, LAS CUALES LAS PASO POR ORDEN DE FECHAS A LA VARIABLE  citas
            List citas = listaCitasOrdenadasPorFecha(snapshot.data);

            if (snapshot.hasError) {
              return const Text('Error');

              //###################    SI HAY DATOS Y LA CITAS NO ESTA VACIA ###########################
            } else if (snapshot.hasData && citas.isNotEmpty) {
              return ListView.builder(
                  itemCount: citas.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat.MMMMEEEEd('es_ES').format(
                                  DateTime.parse(
                                      citas[index]['dia'].toString())),
                              style: const TextStyle(fontSize: 10),
                            ),
                            Text('${citas[index]['servicio']}'),
                            Text(
                                '${citas[index]['precio']} ${personaliza.moneda}')
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/caja-vacia.png',
                    width: MediaQuery.of(context).size.width - 280,
                  ),
                ),
              );
              /*  */
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
  }

  List listaCitasOrdenadasPorFecha(List<dynamic> citas) {
    citas.sort((b, a) {
      //sorting in ascending order
      return DateTime.parse(a['dia']).compareTo(DateTime.parse(b['dia']));
    });

    return citas;
  }

  void inicializacion() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    debugPrint(
        'datos gardados en tabla Pago (fichaClienteScreen.dart) PAGO: $pagado // EMAIL:$_emailSesionUsuario ');
  }
}
