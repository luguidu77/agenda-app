import 'package:flutter/material.dart';



class TemaScreen extends StatefulWidget {
  const TemaScreen({Key? key}) : super(key: key);

  @override
  State<TemaScreen> createState() => _TemaScreenState();
}

class _TemaScreenState extends State<TemaScreen> {
  Color color = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Paleta de colores'),
                ElevatedButton(
                    onPressed: () {

                      //todo: picker color
           /*            showMaterialColorPicker(
                        title: 'Elige color',
                        context: context,
                        selectedColor: color,
                        onChanged: (value) async {
                          debugPrint(value.value.toString());
                          final provider = Provider.of<ThemeProvider>(context,
                              listen: false);
                          provider.cambiaColor(value.value);
                          //  graba en sqlite el tema elegido

                          final colorTema = await ThemeProvider().cargarTema();
                         
                          final color = colorTema.map((e) => e.color);
                          if (color.isEmpty) {
                            await ThemeProvider().nuevoTema(value.value);
                          } else {
                            await ThemeProvider().acutalizarTema(value.value);
                          }
                          
                         
                        },
                      ); */
                    },
                    child: const Icon(Icons.palette)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
