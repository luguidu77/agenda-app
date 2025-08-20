import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GuardarCitaModificada extends StatefulWidget {
  final Function funcion;

  const GuardarCitaModificada({
    Key? key,
    required this.funcion,
  }) : super(key: key);

  @override
  State<GuardarCitaModificada> createState() => _GuardarCitaModificadaState();
}

class _GuardarCitaModificadaState extends State<GuardarCitaModificada> {
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void initState() {
    super.initState();
    // Ejecutamos la función después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarBottomSheet();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Builder para obtener un nuevo contexto que esté dentro del Scaffold
    return Builder(
      builder: (BuildContext innerContext) {
        return _mostrarBottomSheet();
      },
    );
  }

  _mostrarBottomSheet() {
    // Utilizamos el context actual, que debería estar debajo de un Scaffold
    if (_bottomSheetController != null) return;

    try {
      _bottomSheetController = Scaffold.of(context).showBottomSheet(
        (BuildContext ctx) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Desea guardar los cambios?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.funcion();
                        _cerrarBottomSheet();
                      },
                      child: const Text('Guardar'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.redAccent),
                      ),
                      onPressed: _cerrarBottomSheet,
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      // Si ocurre un error, imprime el mensaje para depuración.
      debugPrint('Error al mostrar BottomSheet: $e');
    }
  }

  void _cerrarBottomSheet() {
    _bottomSheetController?.close();
    _bottomSheetController = null;
  }
}
