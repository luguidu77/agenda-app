import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/personaliza_model.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';

class ListaCitas extends StatefulWidget {
  final String emailusuario;
  final DateTime fechaElegida;
  final bool iniciadaSesionUsuario;
  final String
      filter; // todo: parametro que se manda del menu filtro y en base al string que reciba haremos el filter correspondiente a la lista de citas

  const ListaCitas(
      {Key? key,
      required this.emailusuario,
      required this.fechaElegida,
      required this.iniciadaSesionUsuario,
      required this.filter})
      : super(key: key);
  @override
  State<ListaCitas> createState() => _ListaCitasState();
}

class _ListaCitasState extends State<ListaCitas> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  PersonalizaModel personaliza = PersonalizaModel();

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;

      setState(() {});
    }
  }

  @override
  void initState() {
    getPersonaliza();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fecha = dateFormat.format(widget.fechaElegida);
    // CITAS SEGUN SELECCION FILTRO (TODAS, SOLO PENDIENTES)
    if (widget.filter == 'TODAS') {
      //no hay aplicado filtro o filtro TODAS , VISUALIZA TODAS LAS CITAS
      return todasLasCitas(fecha);
    } else if (widget.filter == 'PENDIENTES') {
      // SOLO VISIALIZA CITAS PENDIENTES

      return listaCitasFiltrada(fecha);
    } else {
      //no hay aplicado filtro
      return todasLasCitas(fecha);
    }
  }

  vercitas(context, citas) {
    return citas.isEmpty
        ? Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text('No tienes citas para este día'),
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/images/caja-vacia.png',
                width: MediaQuery.of(context).size.width - 250,
              ),
            ],
          )
        : Column(
            children: [
              // TEXTO SUMA DE GANANCIAS DIARIAS
              FutureBuilder<dynamic>(
                  future: widget.iniciadaSesionUsuario
                      ? FirebaseProvider().calculaGananciaDiariasFB(citas)
                      : CitaListProvider().calculaGananciasDiarias(citas),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<dynamic> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                          width: 160,
                          child: SkeletonParagraph(
                            style: SkeletonParagraphStyle(
                                lines: 1,
                                spacing: 1,
                                lineStyle: SkeletonLineStyle(
                                  // randomLength: true,
                                  height: 10,
                                  borderRadius: BorderRadius.circular(5),
                                  // minLength: MediaQuery.of(context).size.width,
                                  // maxLength: MediaQuery.of(context).size.width,
                                )),
                          ));
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        return const Text('');
                      } else if (snapshot.hasData) {
                        final data = snapshot.data;

                        // SI TENGO DATOS LOS VISUALIZO EN PANTALLA
                        return Text(
                          'GANANCIAS HOY $data ${personaliza.moneda}',
                          style: const TextStyle(fontSize: 12),
                        );
                      } else {
                        return const Text('Empty data');
                      }
                    } else {
                      return const Text('fdfd');
                    }
                  }),
              Expanded(
                // TARJETAS DE LAS CITAS CONCERTADAS
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: citas.length,
                  itemBuilder: (BuildContext context, int index) {
                    String horaInicio = FormatearFechaHora()
                        .formatearHora(citas[index]['horaInicio'].toString());
                    String horaFinal = FormatearFechaHora()
                        .formatearHora(citas[index]['horaFinal'].toString());

                    var horainiciocita =
                        DateTime.parse(citas[index]['horaInicio']);

                    Color estiloHorario;
                    // variable para comprobar si la cita es una fecha no disponible (idServicio=999)
                    //idServicio es String en Firebase e int en Dispositivo
                    bool compruebafechaDisponible;
                    if (widget.iniciadaSesionUsuario) {
                      compruebafechaDisponible =
                          citas[index]['idServicio'] != null;
                    } else {
                      compruebafechaDisponible =
                          citas[index]['idServicio'] != 999;
                    }

                    debugPrint('dia cita ${horainiciocita.day}');
                    debugPrint('ID de la cita ${citas[index]['id']}');
                    DateTime ahoraUtcLocal = DateTime.now().toUtc().toLocal();

                    ///.add(const Duration(hours: 1));
                    debugPrint(ahoraUtcLocal.toString());

                    debugPrint('hora de inicio ${horainiciocita.toUtc()}');

                    // para hacer las comparaciones de fechas, tienen que estar las dos en Utc,
                    // la hora actual DateTime.now().toUtc().toLocal()
                    (horainiciocita.toUtc().isBefore(ahoraUtcLocal))
                        ? estiloHorario = Colors.redAccent
                        : estiloHorario = Colors.blueGrey;

                    return Column(
                      children: [
                        Dismissible(
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.0,
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Row(
                              children: [
                                SizedBox(width: 15.0),
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          key: GlobalKey(),
                          onDismissed: (direction) {
                            _mensajeAlerta(context, index, citas);
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (compruebafechaDisponible) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetallesCitaScreen(
                                        reserva: citas[index]),
                                  ),
                                );
                              } else {
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.info(
                                    message:
                                        'NO HAY DETALLES.PUEDES ELIMINAR DESPLANZANDO TARJETA',
                                  ),
                                );
                              }
                            },
                            child: _tarjetasCitas(
                                compruebafechaDisponible,
                                citas,
                                index,
                                horaInicio,
                                estiloHorario,
                                horaFinal),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
  }

  Card _tarjetasCitas(bool compruebafechaDisponible, citas, int index,
      String horaInicio, Color estiloHorario, String horaFinal) {
    print('todas las citas $citas <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    return Card(
        elevation: 2,
        color: compruebafechaDisponible
            ? null
            : const Color.fromARGB(214, 230, 123, 123),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Color.fromARGB(179, 232, 5, 5),
                  width: 5,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //? CLIENTE Y SERVICIO
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // la condicion (citas[index]['nombre'] != null) la utilizo para las fechas no disponibles ya que se guarda el nombre como null
                          Text(
                            compruebafechaDisponible
                                ? citas[index]['nombre'].toString()
                                : 'NO DISPONIBLE',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          compruebafechaDisponible
                              ? Row(
                                  children: [
                                    Text(
                                      '${citas[index]['precio']} ${personaliza.moneda}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(citas[index]['servicio'].toString()),
                                  ],
                                )
                              : Text(citas[index]['comentario'].toString()),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 12,
                              ),
                              Text(
                                compruebafechaDisponible
                                    ? ' ${citas[index]['comentario']}'
                                        .toString()
                                    : '',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      //? HORARIO
                      SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // reloj!,
                              // icono cambia si cita realizada o a realizar
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                //mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(horaInicio,
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                          color: estiloHorario)),
                                  Text(
                                    horaFinal,
                                    // style: estiloHorario,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _eliminarCitaFB(usuarioAPP, id) {
    SincronizarFirebase().eliminaCitaId(usuarioAPP, id.toString());
    // convierto el id que viene como String en int
    int idEntero = convertirIdEnEntero(id);
    //elimina recordatorio de la cita
    eliminaRecordatorio(idEntero);
    setState(() {});
  }

  void _eliminarCita(int id, String nombreClienta) async {
    await CitaListProvider().elimarCita(id);
    _mensajeEliminado(nombreClienta.toString());
    //elimina recordatorio de la cita
    eliminaRecordatorio(id);
    setState(() {});
  }

  _mensajeEliminado(String nombreClienta) {
    nombreClienta == 'null'
        ? nombreClienta = 'NO DISPONIBLE'
        : nombreClienta = nombreClienta;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: '🗑️ CITA DE $nombreClienta ELIMINADA',
      ),
    );
  }

  Future<dynamic> _mensajeAlerta(BuildContext context, int index, citas) {
    String textoNombre = citas[index]['nombre'].toString();
    (textoNombre == 'null')
        ? textoNombre = 'NO DISPONIBLE'
        : textoNombre = citas[index]['nombre'];

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Icon(
                Icons.warning,
                color: Colors.red,
              ),
              content: Text('¿ Quieres eliminar la cita de $textoNombre ?'),
              actions: [
                ElevatedButton.icon(
                    onPressed: () {
                      widget.iniciadaSesionUsuario
                          ? _eliminarCitaFB(
                              widget.emailusuario, citas[index]['id'])
                          //ELIMINA CITA EN DISPOSITIVO
                          : _eliminarCita(citas[index]['id'], textoNombre);

                      //ELIMINA CITA EN FIREBASE

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: const Text('Eliminar')),
                const SizedBox(
                  width: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text(
                      ' No ',
                      style: TextStyle(fontSize: 18),
                    )),
              ],
            ));
  }

  todasLasCitas(fecha) {
    return FutureBuilder<dynamic>(
      future: widget.iniciadaSesionUsuario
          //? TRAE LAS CITAS DEL DISPOSITIVO O DE FIREBASE CON LA CONDICION INICIO DE SESION
          ? FirebaseProvider().leerBasedatosFirebase(widget.emailusuario, fecha)
          : CitaListProvider().leerBasedatosDispositivo(fecha),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: SizedBox(
                child: Center(
                    child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 4,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 80,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            ))),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            // SI TENGO DATOS LOS VISUALIZO EN PANTALLA  DATA TRAE TODAS LAS CITAS

            return vercitas(context, data);
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }

  listaCitasFiltrada(fecha) {
    DateTime ahoraUtcLocal = DateTime.now().toUtc().toLocal();
    List<Map<String, dynamic>> listaFiltrada = [];
    List<Map<String, dynamic>> listaFiltradaAux = [];
    return FutureBuilder<dynamic>(
      future: widget.iniciadaSesionUsuario
          //? TRAE LAS CITAS DEL DISPOSITIVO O DE FIREBASE CON LA CONDICION INICIO DE SESION
          ? FirebaseProvider().leerBasedatosFirebase(widget.emailusuario, fecha)
          : CitaListProvider().leerBasedatosDispositivo(fecha),
      builder: (
        BuildContext context,
        AsyncSnapshot<dynamic> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: SizedBox(
                child: Center(
                    child: SkeletonParagraph(
              style: SkeletonParagraphStyle(
                  lines: 4,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 80,
                    borderRadius: BorderRadius.circular(5),
                    // minLength: MediaQuery.of(context).size.width,
                    // maxLength: MediaQuery.of(context).size.width,
                  )),
            ))),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error');
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            // SI TENGO DATOS LOS VISUALIZO EN PANTALLA  DATA TRAE TODAS LAS CITAS

            // FILTRO DE LAS CITAS SEGUN SELECCION FILTRO (TODAS, SOLO PENDIENTES)

            //  print('datos filtrados $data');

            listaFiltradaAux.addAll(data);
            for (var element in listaFiltradaAux) {
              if (DateTime.parse(element['horaInicio'])
                  .toUtc()
                  .isAfter(ahoraUtcLocal)) {
                listaFiltrada.add(element);
              }
            }

            return vercitas(context, listaFiltrada);
          } else {
            return const Text('Empty data');
          }
        } else {
          return Text('State: ${snapshot.connectionState}');
        }
      },
    );
  }

  void eliminaRecordatorio(int id) async {
    await NotificationService().cancelaNotificacion(id);
  }
}
