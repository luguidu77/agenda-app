import 'package:flutter/material.dart';

class BackdropFilterCitas extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  final String usuarioAPP;

  const BackdropFilterCitas(
      {Key? key,
      required this.frontLayer, // contenido de la lista citas
      required this.backLayer, // contenido lista filtros detras de la lista
      required this.frontTitle, // titulo citas
      required this.backTitle,
      required this.usuarioAPP}) // titulo alternativo detras lista citas
      : super(key: key);

  @override
  State<BackdropFilterCitas> createState() => _BackdropFilterCitasState();
}

class _BackdropFilterCitasState extends State<BackdropFilterCitas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        value: 1.0, duration: const Duration(milliseconds: 250), vsync: this);

    _controller.addStatusListener((status) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color colorTema = Theme.of(context).primaryColor;
    return Scaffold(
        appBar: AppBar(
          // ESTABLE EL COLOR DEL TEMA EN EL TITULO DEL WIDGET ( Citas para loli)
          backgroundColor: colorTema,
          //flexibleSpace establece un colores con gradiente
          /*   flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: <Color>[
                    Color.fromARGB(255, 219, 217, 217),
                    Theme.of(context).primaryColor.withOpacity(.5)
                  ]),
            ),
          ), */
          toolbarHeight: 25,
          automaticallyImplyLeading: false,
          title: isFrontLayerVisible ? widget.frontTitle : widget.backTitle,
          elevation: 0.0,
          //todo DESACTIVADO EL BOTON PARA ABRIR Y CERRAR EL LAUYOUT TRASERO
          /*  actions: [
            GestureDetector(
              onTap: () => _toggleLayer(),   // DESPLAZA EL CALENDARIO Y DEJA VER LA PARTE DE ATRAS
              child: Container(
                  padding: const EdgeInsets.only(right: 4, top: 7.5),
                  child: const SizedBox(child: Icon(Icons.filter_list))),
            ),
          ], */
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const titleHeight = 30;
            final Size canvasSize = constraints.biggest;
            final double h = canvasSize.height - titleHeight;

            Animation<RelativeRect> layerAnimation = RelativeRectTween(
              begin:
                  RelativeRect.fromLTRB(0, h - 300, 0, h - canvasSize.height),
              end: const RelativeRect.fromLTRB(0, 0, 0, 0),
            ).animate(_controller.view);

            return Stack(children: [
              widget.backLayer,
              PositionedTransition(
                  rect: layerAnimation,
                  child: _FrontLayer(child: widget.frontLayer))
            ]);
          },
        ));
  }

  bool get isFrontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  _toggleLayer() {
    _controller.fling(velocity: isFrontLayerVisible ? -2 : 2);
  }
}

class _FrontLayer extends StatelessWidget {
  final Widget child;

  const _FrontLayer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 22.0,
      shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(topRight: Radius.elliptical(35, 15))),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [Expanded(child: child)],
          ),
        ),
      ),
    );
  }
}
