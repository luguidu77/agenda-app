import 'package:agendacitas/screens/home.dart';
import 'package:agendacitas/widgets/tarjeta_msm_citas.dart';
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
  late PersonalizaProviderFirebase contextoPersonalizaFirebase;
  late String textoActual;

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
    //  getPersonalizaFirebase(widget.emailSesionUsuario);
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
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    String emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    bool iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    // rescat el texto par enviar a los clientes desde firebase
    contextoPersonalizaFirebase = context.read<PersonalizaProviderFirebase>();
    final personalizaprovider = contextoPersonalizaFirebase.getPersonaliza;
    print(personalizaprovider['MENSAJE_CITA']);

    // ESTA CONDICION SOLO SIRVE PARA LAS INSTALACIONES DE VERSIONES ANTERIORES A LA CREACION MODIFICACION DE TEXTO CONFIRMACION DE CITA
    if (personalizaprovider['MENSAJE_CITA'] == null) {
      // SI ES NULO EL MENSAJE => CREAMOS PERSONALIZA Y MENSAJE DE EJEMPLO EN FIREBASE
      _creaPersonaliza(emailSesionUsuario, contextoPersonalizaFirebase);

      setState(() {});
    }
    textoActual = personalizaprovider['MENSAJE_CITA'].toString();

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
                const SizedBox(height: 30),
                _textoMensajes(context, contextoPersonalizaFirebase,
                    emailSesionUsuario, iniciadaSesionUsuario)
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

  _textoMensajes(
      context, contextoPersonalizaFirebase, emailSesionUsuario, inicioSesion) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Mensaje confirmación cita',
            style: GoogleFonts.bebasNeue(fontSize: 18)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width / 4, 50),
          ),
          onPressed: inicioSesion
              ? () async {
                  await tarjetaModificarMsm(
                          context,
                          contextoPersonalizaFirebase,
                          emailSesionUsuario,
                          textoActual,
                          'texto')
                      .whenComplete(() => actualizar(context));
                }
              : () {
                  mensajeError(context, 'No disponible en versión gratuita');
                },
          child: const Text('EDITAR'),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(index: 3, myBnB: 3),
                    ));
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

  void getPersonalizaFirebase(emailSesionUsuario, con) async {
    await FirebaseProvider().cargarPersonaliza(emailSesionUsuario);
  }

  void _creaPersonaliza(emailSesionUsuario, contextoPersonalizaFirebase) async {
    String mensaje =
        '📢Hola \$cliente,%su cita ha sido reservada con \$denominacion para el día \$fecha h.%Servicio a realizar : \$servicio.%%🙏Si no pudieras asistir cancelala para que otra persona pueda aprovecharla.%%Telefono: \$telefono%Web: \$web%Facebook: \$facebook%Instagram: \$instagram%Dónde estamos: \$ubicacion%';
    await FirebaseProvider().nuevoPersonaliza(emailSesionUsuario, mensaje);

    contextoPersonalizaFirebase.setPersonaliza = {
      'MENSAJE_CITA': mensaje,
    };
  }
}
