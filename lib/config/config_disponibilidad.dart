import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class ConfigDisponibilidad extends StatefulWidget {
  const ConfigDisponibilidad({Key? key}) : super(key: key);

  @override
  State<ConfigDisponibilidad> createState() => _ConfigDisponibilidadState();
}

class _ConfigDisponibilidadState extends State<ConfigDisponibilidad> {
  String _emailSesionUsuario = '';
  bool _iniciadaSesionUsuario = false;
  List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo'
  ];

  Map<String, bool> diasDisp = {
    'Lunes': true,
    'Martes': true,
    'Miercoles': true,
    'Jueves': true,
    'Viernes': true,
    'Sabado': true,
    'Domingo': true
  };

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

  crearEstructuraDisponibilidadFB(usuarioAPP) async {
    await SincronizarFirebase()
        .actualizaDisponibilidadSemanal(usuarioAPP, diasDisp)
        .then((e) {
      setState(() {});
    });
  }

  @override
  void initState() {
    emailUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _emailSesionUsuario != '' && _iniciadaSesionUsuario
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Disponibilidad para el servicio',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        './assets/icon/beach.png',
                        width: 105,
                      ),
                      Image.asset(
                        './assets/icon/work.png',
                        width: 105,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: StreamBuilder(
                        stream: SincronizarFirebase()
                            .getDisponibilidadSemanal(_emailSesionUsuario)
                            .asStream(),
                        builder: ((context, AsyncSnapshot<dynamic> snapshot) {
                          final data = snapshot.data;
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                  width: 20.0,
                                  height: 20.0,
                                  child: CircularProgressIndicator(
                                      //backgroundColor: Colors.amber,
                                      )),
                            );
                          } else if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            } else if (snapshot.hasData) {
                              return ListView.builder(
                                  itemCount: 7,
                                  itemBuilder: ((context, index) {
                                    var disp = data[diasSemana[index]];

                                    return ListTile(
                                      title: Text(diasSemana[index].toString()),
                                      trailing: BotonDisponibilidad(
                                          valorBoton:
                                              disp!, //var disp = diasDisp[diasSemana[index]];
                                          disponibilidad: data,
                                          diaS: diasSemana[index].toString()),
                                    );
                                  }));
                            } else {
                              //creamos la estructura en firebase
                              crearEstructuraDisponibilidadFB(
                                  _emailSesionUsuario);

                              return const Text('CARGANDO...');
                            }
                          } else {
                            return Text('State: ${snapshot.connectionState}');
                          }
                        })),
                  ),
                ],
              )
            : Column(
                children: [
                  Card(
                      child: Column(
                    children: [
                      const Text(
                          'Inicia sesión para configurar tu disponibilidad semanal'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lunes'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Martes'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Miercoles'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jueves'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Viernes'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sabado'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Domingo'),
                          Switch(value: false, onChanged: ((value) {})),
                        ],
                      ),
                    ],
                  ))
                ],
              ),
      ),
    );
  }
}

// ignore: must_be_immutable
class BotonDisponibilidad extends StatefulWidget {
  bool valorBoton;
  final Map disponibilidad;
  final String diaS;

  BotonDisponibilidad(
      {Key? key,
      required this.valorBoton,
      required this.disponibilidad,
      required this.diaS})
      : super(key: key);

  @override
  State<BotonDisponibilidad> createState() => _BotonDisponibilidadState();
}

class _BotonDisponibilidadState extends State<BotonDisponibilidad> {
  bool val = false;
  @override
  Widget build(BuildContext context) {
    val = widget.valorBoton;

    //traigo email del usuario, del EstadoPagoAppProvider
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    String usuarioAPP = estadoPagoProvider.emailUsuarioApp;

    //Disponibilidad semanal provider
    final disponibilidadSemanalProvider = context.read<DispoSemanalProvider>();

    return Column(
      children: [
        Switch.adaptive(
          activeThumbImage: const AssetImage('./assets/icon/work.png'),
          inactiveThumbImage: const AssetImage('./assets/icon/beach.png'),
          activeColor: Colors.orange,
          value: val, //themeProvider.isLightMode,
          onChanged: (value) {
            setState(() {
              value = !val;
              widget.valorBoton = value;
              widget.disponibilidad[widget.diaS] = value;
              //ENVIA A FIREBASE DISPONIBILIDAD SEMANAL
              SincronizarFirebase().actualizaDisponibilidadSemanal(
                usuarioAPP,
                widget.disponibilidad,
              );
              // SETEA EL PROVIDER DE DISPONIBILIDAD
              disponibilidadSemanalProvider
                  .setDiasDispibles(widget.disponibilidad);
            });
          },
        ),
      ],
    );
  }
}
