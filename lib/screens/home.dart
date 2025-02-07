import 'dart:math';

import 'package:agendacitas/config/config_perfil_usuario.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/providers/tab_notificaciones_screen_provider.dart';
import 'package:agendacitas/registro_empleados/empleado_revisa_confirma.dart';

import 'package:agendacitas/screens/creacion_citas/creacion_cita_cliente.dart';
import 'package:agendacitas/screens/creacion_citas/creacion_cita_confirmar.dart';
import 'package:agendacitas/screens/creacion_citas/empleados_screen.dart';
import 'package:agendacitas/screens/creacion_citas/nuevo_editar_empleado.dart';

import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';

import 'package:agendacitas/screens/detalles_cita_screen.dart';
import 'package:agendacitas/screens/notificaciones_screen.dart';

import 'package:agendacitas/screens/servicios_screen.dart';

import 'package:agendacitas/utils/disponibilidad_semanal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/Firebase/notificaciones.dart';
import '../providers/providers.dart';

import '../widgets/widgets.dart';
import 'creacion_citas/creacion_cita_servicio.dart';
import 'screens.dart';
import 'style/estilo_pantalla.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  HomeScreen(
      {Key? key, required this.index, required this.myBnB, this.emailUsuario})
      : super(key: key);
  int myBnB = 0;
  int index = 0;

  String? emailUsuario;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  // contextoPersonaliza es la variable para actuar con este contexto

  late PersonalizaProviderFirebase contextoPersonalizaFirebase;
  int tabRegordatorios = 0;
  //trae mediante funcion de BNavigator el index de la pagina menu de abajo , myBnB
  BNavigator? myBnB;

  ThemeData? tema;

  bool temaDefecto = true;

  bool _iniciadaSesionUsuario = false;
  String _emailSesionUsuario = '';

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

  //***********ESCUCHANDO NOTIFICACIONES Y ACTUACION *************************************/
  void showFlutterNotification(RemoteMessage message) async {
    switch (message.data['categoria']) {
      case 'recordatorio':
        context.read<TabNotifiacionesScreenProvider>().setTap(0);

        break;
      case 'citaweb':
        context.read<TabNotifiacionesScreenProvider>().setTap(1);
        break;
      case 'administrador':
        context.read<TabNotifiacionesScreenProvider>().setTap(2);
        break;
      default:
        context.read<TabNotifiacionesScreenProvider>().setTap(0);
    }

    debugPrint('A continuacion los datos que trae la notificacion:');
    print(
        '************ mensaje notificacion recibida *************************************');
    print(message.data);
    if (message.data['categoria'] == 'administrador') {
      print('guarda en firebase notificacionesAdministrador');
      //guardaNotificacionAdministrador(message);
    } else {
      //*GUARDA LA NOTIFICACION EN FIRESTORE agendadecitasapp->notificaciones
      guardaNotificacionAlUsuarioApp(message);
      final titulo = message.notification!.title;
      final texto = message.notification!.body;
      //mensajeInfo(context, 'Nueva notificación');

      final snackBar = SnackBar(
          content: textoConTituloNegrita(
        titulo!,
        texto!,
      ));
      scaffoldKey.currentState?.showSnackBar(snackBar);
    }

    //  navigatorKey.currentState?.pushNamed('PaginaNotificacionesScreen');

    //final cita = notificacion['notificacion'];
    /* showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text(
                '📣 NOTIFICACIONES',
                style: TextStyle(fontSize: 10),
              ), // 'citaweb'
              content: textoConTituloNegrita(
                titulo!,
                texto!,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            )); */

    /*  Map<String, dynamic> notificacion =
        jsonDecode(message.data['notificacion']);

    Map<String, dynamic> nombreCliente = notificacion['cliente'];
    Map<String, dynamic> cita = notificacion[
        'fechaCita']; //{"horaFormateada":"11:00","fechaFormateada":"7 de febrero de 2024"}} */

    /*  Future.delayed(
        const Duration(seconds: 5),
        () => {
              navigatorKey.currentState?.push(MaterialPageRoute(
                builder: (context) => HomeScreen(
                  index: 1,
                  myBnB: 1,
                ),
              ))
            }); */
    HomeScreen(
      index: 1,
      myBnB: 1,
    );
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    //iniciamos myBnB(bottomNavigationBar) trayendo BNavigator

    //cargarTema();

    personalizaFirebase();

    // ####### GUARDA EL TOKEN PARA ENVIOS DE NOTIFICACIONES
    messangingFirebase();

    myBnB = BNavigator(
      currentIndex: (i) {
        setState(() {
          widget.index = i;
        });
      },
      index: widget.myBnB,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //FirebaseAuth.instance.signOut();

    themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
        scaffoldMessengerKey: scaffoldKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Agenda de citas',
        themeMode: themeProvider.themeMode,
        theme: temaDefecto
            ? ThemeData(
                useMaterial3: true,
                primarySwatch: Colors.teal,
              )
            : ThemeData(
                useMaterial3: true,
                primaryColor: themeProvider.mitemalight.primaryColor,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: themeProvider.mitemalight.primaryColor),
              ),
        darkTheme: MyTheme.darkTheme,
        home: WillPopScope(
          onWillPop: () async {
            // Mostrar alerta antes de salir
            return await tarjetaSalirAplicacion() ?? false;
          },
          child: Scaffold(
              bottomNavigationBar: myBnB,
              body: RutasNav(
                index: widget.index,
              )),
        ),
        routes: {
          'PaginaNotificacionesScreen': (context) =>
              const PaginaNotificacionesScreen(),
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
          'ConfigPerfilAdminstrador': (context) =>
              const ConfigPerfilAdministrador(),
          'ConfigPerfilUsuario': (context) => ConfigPerfilUsuario(),
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
          'ModificacionCitaScreen': (context) => const DetallesCitaWidget(
                fechaCorta: '',
                citaconfirmada: false,
                // personaliza: personaliza,
                emailUsuario: '',
                iniciadaSesionUsuario: true,
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
          'empleadosScreen': (context) => const EmpleadosScreen(),
          'empleadosEdicionScreen': (context) => const EmpleadoEdicion(),
          'empleadosRegistroConfirmacion': (context) =>
              const EmpleadoRevisaConfirma(),
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

  void personalizaFirebase() async {
    /*  Map<String, dynamic> data = await PersonalizaProviderFirebase()
        .cargarPersonaliza(_emailSesionUsuario);

    if (data.isNotEmpty) {
      //contextoPersonalizaFirebase.setPersonaliza( data['mensaje']);

      ;

      //
    } else {
      //await PersonalizaProvider().nuevoPersonaliza(0, 34, '', '', '€');
      //personaliza();
    } */
  }

  tarjetaSalirAplicacion() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  )),
              child: Image.asset(
                'assets/icon/power-off.png',
                width: 50,
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 54, 54, 54),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(58.0),
                      child: Text(
                        'Salir',
                        style: tituloEstilo.copyWith(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Text('¿Quieres cerrar la agenda?',
                          style: subTituloEstilo),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.green)),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.blueGrey)),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Sí',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget textoConTituloNegrita(String titulo, String texto) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Poner el título en negrita
            color: Colors
                .black, // Asegúrate de que el color del texto sea el correcto
          ),
        ),
        TextSpan(
          text: '\n$texto', // El texto normal debajo del título
          style: const TextStyle(
            color: Colors.white, // El color del texto
          ),
        ),
      ],
    ),
  );
}
