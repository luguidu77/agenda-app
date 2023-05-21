import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../models/personaliza_model.dart';
import '../../providers/personaliza_provider.dart';
import '../../utils/alertasSnackBar.dart';
import '../../widgets/configRecordatorios.dart';
import '../../widgets/tarjeta_cod_moneda.dart';

class ConfigPersonalizar extends StatefulWidget {
  const ConfigPersonalizar({Key? key}) : super(key: key);

  @override
  State<ConfigPersonalizar> createState() => _ConfigPersonalizarState();
}

class _ConfigPersonalizarState extends State<ConfigPersonalizar> {
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
      personaliza.codpais = data[0].codpais;
      personaliza.moneda = data[0].moneda;
      mensajeModificado('dato actualizado');
      setState(() {});
    } else {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
      getPersonaliza();
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Elige el color del tema',
            style: GoogleFonts.bebasNeue(fontSize: 18)),
        const SizedBox(width: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
            ),
            onPressed: () async {
              // todo picker color
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
            },
            child: const Icon(Icons.palette)),
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
    // setState(() {});
  }

  void mensajeModificado(String texto) {
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
