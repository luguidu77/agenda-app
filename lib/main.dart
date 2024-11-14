import 'dart:async';

import 'package:agendacitas/providers/FormularioBusqueda/formulario_busqueda_provider.dart';
import 'package:agendacitas/providers/buttom_nav_notificaciones_provider.dart';
import 'package:agendacitas/providers/tab_notificaciones_screen_provider.dart';
import 'package:agendacitas/screens/creacion_citas/provider/creacion_cita_provider.dart';

import 'package:agendacitas/screens/pagina_creacion_cuenta_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

import 'config/.configuraciones.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'widgets/formulariosSessionApp/registro_usuario_screen.dart'; //utilizado para anular la rotación de pantalla

//! DESPLEGAR EN PLAY STORE :

//?
//?   CAMBIAR  Version EN Android/app/build.gradle  ingrementa versionCode y versionName
//?            version base de datos DB Provider.
//?            quitar PAGADO DEL home.dart -->> PagoProvider().guardaPagado(true);
//?
//?   flutter build appbundle
//?            - C:\PROYECTOS FLUTTER\agenda_app\build\app\outputs\bundle\release

//      VER SOLUCIONES DE ERRORES README.md
//! GITHUB :
/* 
git add . 
git commit -m "modificando splash"  
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
  await Firebase.initializeApp();

  // initializeDateFormatting().then((_) {

  MobileAds.instance.initialize();

  //});
  // Registra el background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool inicioConfigApp = false;
  List hayServicios = [];
  String usuarioAPP = '';
  bool hayEmailPrueba = false;

  bool variablePago = false;

  reseteoprueba() async {
    //todo quitar , es solo pruebas para guadado en dispositivo de pago
    // await PagoProvider().guardaPagado(false, '');
    // FirebaseAuth.instance.signOut();

    /* 
      ?LOGICA DE INICIO:
      DISPOSITIVO

      PAGO    EMAIL                    CARGAR EN PERFILPROVIDER:
     
      FALSE    ''            ---------->  'GRATUITO'                 ----> FORMULARIO 1 (INICIO DE SESION / CREAR CUENTA)
      FALSE    'EMAIL@EMAIL' ---------->  'PRUEBA_ACTIVA'            ----> INCIA SESION CON EMAIL, FORMULARIO 2 'login'
      TRUE     'EMAIL@EMAIL' ---------->  'PROPIETARIO'              ----> INCIA SESION CON EMAIL, FORMULARIO 2 'login' O VER LA POSIBILIDAD DE INICIAR SESION AUTOMATICAMENTE 
                                           
      AL INICIAR SESION                     COMPROBACION EN FIREBASE            
       
       CARGAR EN PERFILPROVIDER:              <15 DIAS DESDE REGISTRO                    'PRUEBA_ACTIVA'        -----> GUARDA EN DISPOSITIVO -> PAGO:FALSE , EMAIL'EMAIL@EMAIL'
        'PRUEBA_ACTIVA'                       >15 DIAS DESDE REGISTRO                    ' GRATUITA    '        -----> GUARDA EN DISPOSITIVO -> PAGO:FALSE , EMAIL'' , MENSAJE DE ELIMINACION DE CUENTA Y BORRAR REGISTRO AUTENTIFICACION USUARIO EN FIREBASE(DEJAR DATOS EN FIRESTORE)
    
        'PROPIETARIO'                 (YA SE HA REALIZADO AL COMPROBAR EN DISPOSITIVO = NO HACER NADA EN PERFILPROVIDER )  --> CALENDARIOSCREEN  
    
    
    
      AL CREAR  CUENTA PRUEBA 15 DIAS  -----> GUARDAR EN DISPOSITIVO ->  PAGO: FALSE ,'EMAIL@EMAIL'  -> CARGA EN PERFILPROVIDER: 'PRUEBA_ACTIVA'   ----> INCIA SESION CON EMAIL, FORMULARIO 2 'login'
             
       

     
     */
  }

  inicializacion() async {
    FlutterNativeSplash.remove();
    //?comprueba pago en dispositivo
    final pago = await CompruebaPago.getPagoEmailDispositivo();
    debugPrint('datos gardados en tabla Pago (main.dart) $pago');

    if (mounted) {
      setState(() {
        //? guardo en variables los datos de pago->  email
        usuarioAPP = pago['email'];
      });
    }
  }

  @override
  void initState() {
    // reseteoprueba();
    //inicializacion();

    super.initState();
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
            create: (BuildContext context) => DetectChangeActivateService()),
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
      ],
      builder: (context, _) {
        return MaterialApp(
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
            home: /*  SplashScreen.navigate(
                 width: 200,
              height: 200,
                fit: BoxFit.fitWidth,
                until: () => Future.delayed(const Duration(seconds: 2)),
                startAnimation: 'start',
                loopAnimation: 'start',
                backgroundColor: Colors.white,
                name: 'assets/icon/splash.riv',
                next: (context) => */
                InicioConfigApp(usuarioAPP: usuarioAPP),
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
}
