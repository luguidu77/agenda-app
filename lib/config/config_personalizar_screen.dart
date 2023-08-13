import 'package:flutter/material.dart';
import 'package:flutter_picker/picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/personaliza_model.dart';
import '../providers/providers.dart';
import '../utils/alertasSnackBar.dart';
import '../widgets/configRecordatorios.dart';
import '../widgets/tarjeta_cod_moneda.dart';

class ConfigPersonalizar extends StatefulWidget {
  const ConfigPersonalizar({Key? key}) : super(key: key);

  @override
  State<ConfigPersonalizar> createState() => _ConfigPersonalizarState();
}

class _ConfigPersonalizarState extends State<ConfigPersonalizar> {
  // contextoPersonaliza es la variable para actuar con este contexto
  late PersonalizaProvider contextoPersonaliza;

  List<Color> colorsList = const [
    Colors.red,
    Color.fromARGB(255, 117, 187, 120),
    Color.fromARGB(255, 120, 139, 88),
    Color.fromARGB(255, 54, 204, 196),
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Color.fromARGB(255, 238, 84, 136),
    Color.fromARGB(255, 231, 157, 207),
    Color.fromARGB(255, 255, 149, 28),
  ];

  PersonalizaModel personaliza = PersonalizaModel();

  String cerrado = '';
  Color color = Colors.blue;

  @override
  void initState() {
    getPersonaliza();
    super.initState();
  }

  getPersonaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      contextoPersonaliza.setPersonaliza = {
        'CODPAIS': data[0].codpais,
        'MONEDA': data[0].moneda
      };
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;
      // mensajeModificado('dato actualizado');
      setState(() {});
    } else {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
      getPersonaliza();
    }
  }

  @override
  Widget build(BuildContext context) {
    contextoPersonaliza = context.read<PersonalizaProvider>();
    print(contextoPersonaliza.getPersonaliza['CODPAIS']);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 28.0, right: 28.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _botonCerrar(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  //todo: HACER CATEGORIAS DE SERVICIOS
                  'Personaliza',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 100),
                _recordatorios(context),
                const SizedBox(height: 30),
                _tema(context),
                const SizedBox(height: 30),
                _codigoPais(context),
                const SizedBox(height: 30),
                _monedaPais(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _recordatorios(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notificame antes de la cita',
          style: GoogleFonts.bebasNeue(fontSize: 18),
        ),
        const SizedBox(width: 10),
        const ConfigRecordatorios()
      ],
    );
  }

  _tema(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Elige el color del tema',
            style: GoogleFonts.bebasNeue(fontSize: 18)),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
                backgroundColor: themeProvider.mitemalight.primaryColor),
            onPressed: () async {
              await Picker(
                title: const Text('Selecciona color tema'),
                hideHeader: true,
                itemExtent: 50,
                confirmText: 'Aceptar',
                cancelText: 'Cancelar',
                adapter: PickerDataAdapter<Color>(
                  data: colorsList
                      .map((color) => PickerItem<Color>(
                          value: color,
                          text: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: color,
                            ),
                          )))
                      .toList(),
                ),
                selectedTextStyle: const TextStyle(color: Colors.blue),
                onConfirm: (Picker picker, List<int> selectedValues) async {
                  int selectedIndex = selectedValues[0];
                  Color selectedColor = colorsList[selectedIndex];
                  // Realiza las acciones necesarias con el color seleccionado

                  /*  final provider =
                      Provider.of<ThemeProvider>(context, listen: false);

                  await provider.cambiaColor(selectedColor.value); */
                  // Cambiar el color del tema
                  // Cambiar el color del tema
                  ThemeData newTheme = themeProvider.mitemalight.copyWith(
                    primaryColor: selectedColor,
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                        backgroundColor: selectedColor),

                    /*  iconButtonTheme: IconButtonThemeData(
                          style: ButtonStyle(
                        iconColor:
                            MaterialStateProperty.all<Color>(selectedColor),
                      )) */
                  );
                  themeProvider.themeData = newTheme;

                  //  graba en sqlite el tema elegido
                  final colorTema = await ThemeProvider().cargarTema();

                  final color = colorTema.map((e) => e.color);

                  if (color.isEmpty) {
                    await ThemeProvider().nuevoTema(selectedColor.value);
                  } else {
                    await ThemeProvider().acutalizarTema(selectedColor.value);

                    mensajeModificado('Tema modificado');
                  }
                },
              ).showDialog(context);
            },
            child: const Icon(Icons.palette))

        /*       await showMaterialColorPicker(
                title: 'Elige color',
                context: context,
                selectedColor: color,
                onChanged: (value) async {
                  // aqui el setState no resulve que la primera vez no se acualize el tema
                  print(value.value);
                  final provider =
                      Provider.of<ThemeProvider>(context, listen: false);
                  provider.cambiaColor(value.value);
                  //  graba en sqlite el tema elegido

                  final colorTema = await ThemeProvider().cargarTema();

                  final color = colorTema.map((e) => e.color);
                  if (color.isEmpty) {
                    await ThemeProvider().nuevoTema(value.value);
                  } else {
                    await ThemeProvider().acutalizarTema(value.value);
                    mensajeModificado('Tema modificado');
                  }
                },
              ); */
      ],
    );
  }

  _codigoPais(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Código teléfonico de país',
            style: GoogleFonts.bebasNeue(fontSize: 18)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
          ),
          onPressed: () async {
            await tarjetaModificarValores(context, personaliza, 'codPais')
                .whenComplete(() => actualizar(context));
          },
          child: Text('+${personaliza.codpais}'),
        )
      ],
    );
  }

  _monedaPais(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Moneda de tu país', style: GoogleFonts.bebasNeue(fontSize: 18)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
          ),
          onPressed: () async {
            await tarjetaModificarValores(context, personaliza, 'monedaPais')
                .whenComplete(() => actualizar(context));
          },
          child: Text('${personaliza.moneda}'),
        )
      ],
    );
  }

  actualizar(context) {
    getPersonaliza();
  }

  void mensajeModificado(String texto) {
    setState(() {});
    mensajeSuccess(context, texto);
  }

  _botonCerrar() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', ModalRoute.withName('/'));
              },
              icon: const Icon(
                Icons.close,
                size: 50,
                color: Color.fromARGB(167, 114, 136, 150),
              )),
        ],
      ),
    );
  }
}
