import 'package:agendacitas/screens/creacion_citas/creacion_cita_cliente.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_confirmar.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_listado_servicios.dart';

import 'package:agendacitas/screens/servicios_screen%20copy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cita_model.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';
import 'creacion_citas/creacion_cita_servicio.dart';
import 'screens.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.index}) : super(key: key);
  int index = 0;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // contextoPersonaliza es la variable para actuar con este contexto
  late PersonalizaProvider contextoPersonaliza;
  late PersonalizaProviderFirebase contextoPersonalizaFirebase;

  //trae mediante funcion de BNavigator el index de la pagina menu de abajo , myBnB
  BNavigator? myBnB;

  ThemeData? tema;

  bool temaDefecto = true;

  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';

  ThemeProvider themeProvider = ThemeProvider();

  estadoPagoEmailApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    //  _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
  }

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
    estadoPagoEmailApp();
    cargarTema();

    personaliza();
    personalizaFirebase();

    messangingFirebase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    contextoPersonaliza = context.read<PersonalizaProvider>();
    contextoPersonalizaFirebase = context.read<PersonalizaProviderFirebase>();

    print(contextoPersonaliza.getPersonaliza['CODPAIS']);
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
                emailUsuario: '',
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

          'creacionCitaCliente': (context) => const CreacionCitaCliente(),
          'creacionCitaServicio': (context) => const CreacionCitaServicio(),
          'creacionCitaComfirmar': (context) => const CreacionCitaConfirmar(),
          'serviciosCitas': (_) => const ServiciosCreacionCita(),
        });
  }

  // ####### GUARDA EL TOKEN PARA ENVIOS DE NOTIFICACIONES
  void messangingFirebase() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    final emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;

    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint(fcmToken.toString());
    if (emailSesionUsuario != '') {
      FirebaseProvider().actualizaTokenMessaging(emailSesionUsuario, fcmToken!);
    }
  }

  void personaliza() async {
    List<PersonalizaModel> data =
        await PersonalizaProvider().cargarPersonaliza();

    if (data.isNotEmpty) {
      contextoPersonaliza.setPersonaliza = {
        'CODPAIS': data[0].codpais,
        'MONEDA': data[0].moneda
      };

      // mensajeModificado('dato actualizado');
      // setState(() {});
    } else {
      await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
      personaliza();
    }
  }

  void personalizaFirebase() async {
    Map<String, dynamic> data = await PersonalizaProviderFirebase()
        .cargarPersonaliza(_emailSesionUsuario);

    if (data.isNotEmpty) {
      contextoPersonalizaFirebase.setPersonaliza = {
        'MENSAJE_CITA': data['mensaje'],
      };

      //
    } else {
      //await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
      personaliza();
    }
  }
}
