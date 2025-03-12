import 'dart:async';

import 'package:agendacitas/providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import 'package:agendacitas/providers/buttom_nav_notificaciones_provider.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/providers/creacion_cuenta/inicio_sesion_forzada.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';

import 'package:agendacitas/providers/tab_notificaciones_screen_provider.dart';
import 'package:agendacitas/registro_empleados/empleado_revisa_confirma.dart';
import 'package:agendacitas/registro_empleados/registro_empleados.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';

import 'package:agendacitas/screens/not_found_page.dart';

import 'package:agendacitas/screens/pagina_creacion_cuenta_screen.dart';
import 'package:agendacitas/screens/pantalla_de_carga.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/.configuraciones.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'widgets/formulariosSessionApp/registro_usuario_screen.dart'; //utilizado para anular la rotación de pantalla
import 'package:app_links/app_links.dart';
/*  flutter_timezone te dice cuál es la zona horaria del dispositivo, y timezone te permite trabajar con esa información para manipular fechas y horarios 
latest_all.dart es parte del paquete timezone y contiene la información completa y actualizada de todas las zonas horarias.*/
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

//! DESPLEGAR EN PLAY STORE :

//?
//?   CAMBIAR  Version EN Android/app/build.gradle  ingrementa versionCode y versionName

//?
//?   flutter build appbundle
//?            - C:\PROYECTOS_FLUTTER\agenda_app\build\app\outputs\bundle\release

//      VER SOLUCIONES DE ERRORES README.md
//! GITHUB :
/* 
git add . 
git commit -m "version 10.00"  
git push
*/

//https://help.syncfusion.com/common/essential-studio/licensing/how-to-register-in-an-application

////////////////·······························································///////
///
//***********ESCUCHANDO NOTIFICACIONES Y ACTUACION *************************************/
// Este es el manejador de mensajes en background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Payload recibido en segundo plano: ${message.data}");

  if (message.data.isEmpty) {
    print("El payload no contiene datos.");
    return;
  }

  //guardaNotificacionAdministrador(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // initializeDateFormatting().then((_) {

  // MobileAds.instance.initialize();

  //});
  // Registra el background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // verifica si hay un usuario gardado en el dispositivo para iniciar la app
  // o ir a inicio de sesion con el usuario guardado
  final usuarioAPP = await sesionGardadoSharedPreferences();
  runApp(MyApp(usuarioAPP: usuarioAPP));
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<String> sesionGardadoSharedPreferences() async {
  String usuarioApp = '';
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  if (email == null) {
    return ''; //no hay sesion
  }

  usuarioApp = email;
  return usuarioApp;
}

class MyApp extends StatefulWidget {
  final String usuarioAPP;
  const MyApp({Key? key, required this.usuarioAPP}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _esperandoDeepLink = true; // Por defecto, esperamos un enlace

  // Agrega estas variables a nivel de clase

  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  bool inicioConfigApp = false;
  List hayServicios = [];

  bool hayEmailPrueba = false;

  bool variablePago = false;

  @override
  void initState() {
    // reseteoprueba();

    initDeepLinks();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (BuildContext context) => CitaListProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => RecordatoriosProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => PagoProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ComprobacionReasignacionCitas()),
        ChangeNotifierProvider(
            create: (BuildContext context) => DispoSemanalProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CalendarioProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => EstadoPagoAppProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CreacionCitaProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => PersonalizaProviderFirebase()),
        ChangeNotifierProvider(
            create: (BuildContext context) => FormularioBusqueda()),
        ChangeNotifierProvider(
            create: (BuildContext context) =>
                ButtomNavNotificacionesProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) =>
                BotonAgregarIndisponibilidadProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => FechaElegida()),
        ChangeNotifierProvider(
            create: (BuildContext context) => HorarioElegidoCarrusel()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ControladorTarjetasAsuntos()),
        ChangeNotifierProvider(
            create: (BuildContext context) =>
                BotonGuardarAgregarNoDisponible()),
        ChangeNotifierProvider(
            create: (BuildContext context) => TextoTituloIndispuesto()),
        ChangeNotifierProvider(
            create: (BuildContext context) => TabNotifiacionesScreenProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => EstadoConfirmacionCita()),
        ChangeNotifierProvider(
            create: (BuildContext context) => EmpleadosProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => VistaProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CitasProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => RolUsuarioProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => EmailUsuarioAppProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => EmailAdministradorAppProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => CuentaNuevaProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => PaginacionProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => PrimeraConfiguracionProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => ServiciosOfrecidosProvider()),
        ChangeNotifierProvider(
            create: (BuildContext context) => InicioSesionForzada()),
      ],
      builder: (context, _) {
        return MaterialApp(
            initialRoute: "/",
            navigatorKey: _navigatorKey,
            onGenerateRoute: (RouteSettings settings) {
              // Pantalla por defecto mientras esperas el enlace profundo
              if (_esperandoDeepLink) {
                return MaterialPageRoute(
                  builder: (_) => const PantallaDeCarga(),
                );
              }

              // Procesa la ruta recibida
              final routeName = settings.name ?? '';
              print('Ruta recibida: $routeName');

              Widget routeWidget;

              if (routeName.startsWith('/invitacion')) {
                routeWidget = RegistroEmpleados(dataPorLink: routeName);
              } else if (routeName == '/empleadoRevisaConfirma') {
                routeWidget = const EmpleadoRevisaConfirma();
              } else {
                routeWidget = const NotFoundPage();
              }

              return MaterialPageRoute(builder: (_) => routeWidget);
            },
            navigatorObservers: [mRouteObserver],
            theme: ThemeData(
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('es'), // Spanish
            ],
            debugShowCheckedModeBanner: false,
            title: 'Agenda de citas',
            /*  initialRoute: variablePago
                ? 'Login'
                : inicioConfigApp
                    ? 'clientesScreen'
                    : 'clientesScreen', */
            home:
                /* 
            // SI QUIERO PONER UN EL ICONO CON ALGUNA ANIMACION
            SplashScreen.navigate(
                width: 200,
                height: 200,
                fit: BoxFit.fitWidth,
                until: () => Future.delayed(const Duration(seconds: 2)),
                startAnimation: 'start',
                loopAnimation: 'start',
                backgroundColor: Colors.white,
                name: 'assets/icon/splash.riv',
                next: (context) =>  */
                InicioConfigApp(usuarioAPP: widget.usuarioAPP),

            /*  */

            routes: {
              //home
              'Login': (context) =>
                  RegistroUsuarioScreen(registroLogin: 'Login', usuarioAPP: ''),
              'Bienvenida': (context) => const Bienvenida(),
              'home': (BuildContext context) => HomeScreen(
                    index: 0,
                    myBnB: 0,
                  ),
              'InicioConfigApp': (context) =>
                  const InicioConfigApp(usuarioAPP: ''),

              'clientesScreen': (_) => const ClientesScreen(),

              //citasStep
              /* 'clientaStep': (BuildContext context) => ClientaStep(
                    clienteParametro: ClienteModel(nombre: '', telefono: ''),
                  ), */
              'servicioStep': (BuildContext context) => const ServicioStep(),
              'citaStep': (BuildContext context) => const CitaStep(),
              'confirmarStep': (context) => const ConfirmarStep(),
              //
              'informesScreen': (_) => const InformesScreen(),
              'fichacliente': (_) => FichaClienteScreen(
                    clienteParametro: ClienteModel(nombre: '', telefono: ''),
                  ),

              'paginaIconoAnimacion': (context) => const PaginaIconoAnimado(
                    email: '',
                    password: '',
                  ),
              'finalizacionPruebaScreen': (context) =>
                  const FinalizacionPrueba(),
            });
      },
    );
  }

  void initDeepLinks() async {
    _appLinks = AppLinks();

    // Manejar enlace inicial
    Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _esperandoDeepLink = false;
      _navigatorKey.currentState?.pushNamed(initialUri.fragment);
    } else {
      _esperandoDeepLink = false;
    }

    // Escuchar nuevos enlaces
    _appLinks.uriLinkStream.listen((uri) {
      _esperandoDeepLink = false;
      _navigatorKey.currentState?.pushNamed(uri.fragment);
    });
  }
}
