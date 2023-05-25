import 'package:agendacitas/providers/pago_dispositivo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../models/models.dart';
import '../../screens/screens.dart';

class BotonAgregarServicios extends StatefulWidget {
  const BotonAgregarServicios({Key? key}) : super(key: key);

  @override
  State<BotonAgregarServicios> createState() => _BotonAgregarServiciosState();
}

class _BotonAgregarServiciosState extends State<BotonAgregarServicios> {
  bool floatExtended = false;
  String? usuarioAPP;
  bool iniciadaSesionUsuario = false;
  // anulado porque da errores de memoria dispose...
  /* Timer? t;
  retardo() {
    t = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        t!.cancel();
        floatExtended = true;

        // Here you can write your code for open new view
      });
    });
  } */
  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar
    final pago = await PagoProvider().cargarPago();
    final emailUsuario = pago['email'];
    usuarioAPP = emailUsuario;
    iniciadaSesionUsuario = usuarioAPP != '' ? true : false;
    setState(() {});

    /*  if (iniciadaSesionUsuario) {
      await cargaServiciosConCategoriasFB(emailUsuario);
    } */
  }

  @override
  void initState() {
    // retardo();
    emailUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _BotonAgregarServicios(context);
  }

  SpeedDial _BotonAgregarServicios(BuildContext context) {
    var renderOverlay = true;
    var visible = true;
    var switchLabelPosition = false;
    var extend = floatExtended;
    var mini = false;
    // var rmicons = false;
    var customDialRoot = false;
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
      dialRoot: customDialRoot
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
          : null,
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
      shape: customDialRoot
          ? const RoundedRectangleBorder()
          : const StadiumBorder(),
      children: [
        iniciadaSesionUsuario
            ? SpeedDialChild(
                child: const Icon(Icons.category),
                // backgroundColor: Colors.red,
                // foregroundColor: Colors.white,
                label: 'Categorias',
                onTap: () {
                  //todo hacer modal desde abajo de pantalla
                  /*  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfigCategoriaServiciosScreen();
                    },
                  ); */
                  // formulario categorias de servicios
                  Navigator.pushNamed(context, 'ConfigCategoriaServiciosScreen',
                      arguments: CategoriaServicioModel());
                },
              )
            : SpeedDialChild(
                child: const Icon(Icons.no_encryption_outlined),
                label: 'Categorias no disponible',
              ),
        SpeedDialChild(
          child: const Icon(Icons.add),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Agrega servicio',
          onTap: () {
            // formulario agregar servicio
            Navigator.pushNamed(context, 'configServicios',
                arguments: iniciadaSesionUsuario
                    ? ServicioModelFB()
                    : ServicioModel());
          },
        ),
      ],
    );
  }
}
