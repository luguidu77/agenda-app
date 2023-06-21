import 'package:agendacitas/.env.dart';

import 'package:agendacitas/screens/pagina_creacion_cuenta_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; 
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'widgets/formulariosSessionApp/registro_usuario_screen.dart'; //utilizado para anular la rotación de pantalla

//! DESPLEGAR EN PLAY STORE :

//?   flutter clean
//?   CAMBIAR  Version EN Android/app/build.gradle  ingrementa versionCode y versionName
//?            version base de datos DB Provider.
//?            quitar PAGADO DEL home.dart -->> PagoProvider().guardaPagado(true);
//?            comprobar pago STRIPE en PRODUCTION google_pay_payment_profile.json y variables en wallet/ tarjetaPago.dart
//?     flutter build appbundle
//?             C:\ProyectosFutter\agenda3\build\app\outputs\bundle\release
//      VER SOLUCIONES DE ERRORES README.md
//! GITHUB :
/* 
git add . 
git commit -m "modificando splash"  
git push
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // initializeDateFormatting().then((_) {

  MobileAds.instance.initialize();
  Stripe.publishableKey = stripePublishableKey;

  //});
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
    reseteoprueba();
    inicializacion();
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
      ],
      builder: (context, _) {
        return MaterialApp(
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
              'finalizacionPruebaScreen': (context) => FinalizacionPrueba(),
            });
      },
    );
  }
}
