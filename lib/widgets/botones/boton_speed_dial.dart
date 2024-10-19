import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../screens/screens.dart';

class BotonSpeedDial extends StatefulWidget {
  const BotonSpeedDial({Key? key}) : super(key: key);

  @override
  State<BotonSpeedDial> createState() => _BotonSpeedDialState();
}

class _BotonSpeedDialState extends State<BotonSpeedDial> {
  bool floatExtended = false;

  @override
  void initState() {
    // retardo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _botonSpeedDial(context);
  }

  SpeedDial _botonSpeedDial(BuildContext context) {
    final leerEstadoBotonIndisponibilidad =
        Provider.of<BotonAgregarIndisponibilidadProvider>(context);
    var renderOverlay = true;
    var visible = true;
    var switchLabelPosition = false;
    var extend = floatExtended;
    var mini = false;
    // var rmicons = false;
    //  var customDialRoot = false;
    var closeManually = false;
    var useRAnimation = true;
    var isDialOpen = ValueNotifier<bool>(false);
    var speedDialDirection = SpeedDialDirection.up;
    var buttonSize = const Size(56.0, 56.0);
    var childrenButtonSize = const Size(56.0, 56.0);
    // var selectedfABLocation = FloatingActionButtonLocation.endDocked;
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      mini: mini,
      openCloseDial: isDialOpen,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      /*  dialRoot: customDialRoot
          ? (ctx, open, toggleChildren) {
              return ElevatedButton(
                onPressed: toggleChildren,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                ),
                child: const Text(
                  "Custom Dial Root",
                  style: TextStyle(fontSize: 17),
                ),
              );
            }
          : null, */
      buttonSize:
          buttonSize, // it's the SpeedDial size which defaults to 56 itself
      // iconTheme: IconThemeData(size: 22),
      label: extend
          ? const Text("Cita/No disponible")
          : null, // The label of the main button.
      /// The active label of the main button, Defaults to label if not specified.
      //  activeLabel: extend ? const Text("Close") : null,

      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the SpeedDial childrens size
      childrenButtonSize: childrenButtonSize,
      visible: visible,
      direction: speedDialDirection,
      switchLabelPosition: switchLabelPosition,

      /// If true user is forced to close dial manually
      closeManually: closeManually,

      /// If false, backgroundOverlay will not be rendered.
      renderOverlay: renderOverlay,
      // overlayColor: Colors.black,
      // overlayOpacity: 0.5,
      onOpen: () => debugPrint('OPENING DIAL'),
      onClose: () => debugPrint('DIAL CLOSED'),
      useRotationAnimation: useRAnimation,
      // tooltip: 'Open Speed Dial',
      // heroTag: 'speed-dial-hero-tag',
      // foregroundColor: Colors.black,
      // backgroundColor: Colors.white,
      // activeForegroundColor: Colors.red,
      // activeBackgroundColor: Colors.blue,
      elevation: 8.0,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      shape: /*  customDialRoot
          ? const RoundedRectangleBorder()
          : */
          const StadiumBorder(),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.chat_rounded),
          // backgroundColor: Colors.red,
          // foregroundColor: Colors.white,
          label: 'Crea una cita',
          onTap: () {
            mensajeInfo(context, 'SELECCIONA UNA HORA EN EL CALENDARIO');
            leerEstadoBotonIndisponibilidad
                .setBotonPulsadoIndisponibilidad(false);
            /*   Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ClientaStep(
                      clienteParametro:
                          ClienteModel(nombre: '', telefono: '', email: ''))),
            ); */
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.work_off),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'No disponible',
          onTap: () {
            leerEstadoBotonIndisponibilidad
                .setBotonPulsadoIndisponibilidad(true);

            /*  // formulario de no disponibilidad
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FechasNoDisponibles()),
            ); */
          },
        ),
      ],
    );
  }
}
