import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cita_model.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //trae mediante funcion de BNavigator el index de la pagina menu de abajo , myBnB
  BNavigator? myBnB;

  ThemeData? tema;

  bool temaDefecto = true;

  ThemeProvider themeProvider = ThemeProvider();

  cargarTema() async {
    // comprobamos si hay un color de tema guardado en sqlite, si lo hay cambia el tema con el color guardado
    final colorTema = await ThemeProvider().cargarTema();

    final color = colorTema.map((e) => e.color);

    if (color.isNotEmpty) {
      temaDefecto = false;

      ThemeData newTheme =
          themeProvider.mitemalight.copyWith(primaryColor: Color(color.first!));
      themeProvider.themeData = newTheme;
      setState(() {});
    }
  }

  @override
  void initState() {
    //iniciamos myBnB(bottomNavigationBar) trayendo BNavigator
    myBnB = BNavigator(currentIndex: (i) {
      setState(() {
        widget.index = i;
      });
    });

    cargarTema();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agenda de citas',
        themeMode: themeProvider.themeMode,
        theme: temaDefecto
            ? ThemeData(
                primarySwatch: Colors.teal,
              )
            : ThemeData(
                primaryColor: themeProvider.mitemalight.primaryColor,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: themeProvider.mitemalight.primaryColor),
              ),
        darkTheme: MyTheme.darkTheme,
        home: WillPopScope(
          onWillPop: () async {
            // Mostrar alerta antes de salir
            return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('¿Quieres salir de la agenda?'),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green)),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blueGrey)),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Sí'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          child: Scaffold(
              bottomNavigationBar: myBnB,
              body: RutasNav(
                index: widget.index,
              )),
        ),
        routes: {
          'MenuAplicacion': (context) => const MenuAplicacion(),
          //'Login': (context) => RegistroUsuarioScreen(registroLogin: 'Login'),
          'Personalizar': (_) => const ConfigPersonalizar(),
          'configClientaScreen': (_) => const ConfigClienteScreen(),
          'Tema': (BuildContext context) => const TemaScreen(),
          'Servicios': (_) => const ServiciosScreen(),
          'Recordatorios': (_) => const ConfigRecordatorios(),
          'configServicios': (BuildContext context) =>
              const ConfigServiciosScreen(),
          'ConfigCategoriaServiciosScreen': (context) =>
              const ConfigCategoriaServiciosScreen(),
          /* 'clientaStep': (BuildContext context) => ClientaStep(
                clienteParametro: ClienteModel(nombre: '', telefono: ''),
              ), */
          'servicioStep': (BuildContext context) => const ServicioStep(),
          'citaStep': (BuildContext context) => const CitaStep(),
          'confirmarStep': (context) => const ConfirmarStep(),
          'clientesScreen': (_) => const ClientesScreen(),
          'calendarioScreen': (BuildContext context) =>
              const CalendarioCitasScreen(),

          //  'GooglePayStripeScreen': (context) => const GooglePayStripeScreen(),
          /*  'RegistroUsuarioScreen': (context) => RegistroUsuarioScreen(
                registroLogin: 'Registro',
              ), */
          'ConfigUsuarioApp': (context) => const ConfigUsuarioApp(),
          'NuevoActualizacionCliente': (context) =>
              const NuevoActualizacionCliente(
                cliente: null,
                pagado: false,
                usuarioAPP: '',
              ),
          'NuevoAcutalizacionUsuarioApp': (context) =>
              NuevoAcutalizacionUsuarioApp(
                perfilUsuarioApp: null,
                usuarioAPP: '',
              ),
          'ModificacionCitaScreen': (context) => const DetallesCitaScreen(
                reserva: {},
              ),
          'FichaClienteScreen': (context) => FichaClienteScreen(
                clienteParametro: ClienteModel(),
              ),

          // 'TarjetaPago': (context) => TarjetaPago(),
          'FechasNoDisponibles': (context) => const FechasNoDisponibles(),
          'InstruccionRegistroNuevoUsuario': (context) =>
              const InstruccionRegistroNuevoUsuario(),

          'PlanAmigo': (context) => const PlanAmigo(),
          'PlanAmigoVinculaCuenta': (context) => const PlanAmigoVinculaCuenta(),
          'DisponibilidadSemanalScreen': (context) =>
              const DisponibilidadSemanalScreen(),
        });
  }
}
