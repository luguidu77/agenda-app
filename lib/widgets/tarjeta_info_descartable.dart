import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* Tarjeta emergente para uso de informaciones al usuario que puede quitar o accionar el boton de accion que recibe como funcion */
class TarjetaInfo extends StatefulWidget {
  const TarjetaInfo(
      {super.key,
      required this.texto,
      this.accion,
      required this.colorTarjeta,
      required this.titulo,
      required this.icono,
      required this.colorTexto});
  final String texto;
  final VoidCallback? accion;
  final String titulo;
  final Color colorTarjeta;
  final Color colorTexto;
  final FaIcon icono;
  @override
  State<TarjetaInfo> createState() => _TarjetaInfoState();
}

class _TarjetaInfoState extends State<TarjetaInfo> {
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Card(
          clipBehavior: Clip.antiAlias,
          color: widget.colorTarjeta,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(widget.titulo,
                              style: TextStyle(
                                  color: widget.colorTexto,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          const SizedBox(
                            width: 5,
                          ),
                          FaIcon(
                            widget.icono.icon,
                            color: widget.colorTexto,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.texto,
                        style: TextStyle(
                          color: widget.colorTexto,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    // si no ha funcion para ejecutar(null) no se vera el boton de accion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.accion == null
                            ? const SizedBox()
                            : IconButton(
                                onPressed: widget.accion,
                                icon: Icon(
                                  Icons.settings,
                                  color: widget.colorTexto,
                                )),
                        IconButton(
                            onPressed: () {
                              visible = false;
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.close,
                              color: widget.colorTexto,
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
