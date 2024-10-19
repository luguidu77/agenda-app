import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/lista_de_citas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

import '../models/personaliza_model.dart';
import '../providers/providers.dart';

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
  late PersonalizaProvider contextoPersonaliza;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  PersonalizaModel personaliza = PersonalizaModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    contextoPersonaliza = context.read<PersonalizaProvider>();
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

  vercitas(context, List<Map<String, dynamic>> citas) {
    int contadorCitas = 0;
    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context).botonPulsado;

    // ············DESCUENTA DE LAS CITAS LOS INDISPUESTOS ............................... ;
    for (var cita in citas) {
      if (cita['idCliente'] != '999') {
        contadorCitas++;
      }
    }
    final numCitas = contadorCitas;

    return Column(
      children: [
        // ########## TEXTO SUMA DE GANANCIAS DIARIAS  ##############################
        Visibility(
            visible: !leerEstadoBotonIndisponibilidad,
            child: gananciaDiaria(citas, numCitas)),

        // ########## TARJETAS DE LAS CITAS CONCERTADAS ##############################
        //  SYNCFUSION
        Expanded(
            child: ListaCitasNuevo(
                fechaElegida: widget.fechaElegida, citas: citas)),
      ],
    );
  }

  FutureBuilder<dynamic> gananciaDiaria(
      List<Map<String, dynamic>> citas, int numCitas) {
    return FutureBuilder<dynamic>(
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
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('');
            } else if (snapshot.hasData) {
              final data = snapshot.data;

              // SI TENGO DATOS LOS VISUALIZO EN PANTALLA // TEXTO 3 CITAS - 75,00 €
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${numCitas.toString()} citas', style: textoEstilo),
                  Text(
                      '- $data ${contextoPersonaliza.getPersonaliza['MONEDA']}',
                      style: textoEstilo)
                ],
              );
            } else {
              return const Text('Empty data');
            }
          } else {
            return const Text('fdfd');
          }
        });
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
                  lines: 12,
                  spacing: 6,
                  lineStyle: SkeletonLineStyle(
                    // randomLength: true,
                    height: 40,
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
