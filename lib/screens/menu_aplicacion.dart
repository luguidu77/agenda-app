import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/screens/comprar_aplicacion.dart';
import 'package:agendacitas/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/providers.dart';

class MenuAplicacion extends StatefulWidget {
  const MenuAplicacion({
    Key? key,
  }) : super(key: key);
  @override
  State<MenuAplicacion> createState() => _MenuAplicacionState();
}

class _MenuAplicacionState extends State<MenuAplicacion> {
  String _emailSesionUsuario = '';
  String _estadopago = '';
  TextStyle estilo = const TextStyle(color: Colors.blueGrey);
  bool _iniciadaSesionUsuario = false;
  String versionApp = '';
  bool versionPlayS = false;
  String comentarioVersion = '';
  bool enviosugerencia = false;
  bool necesitaActualizar = false;

  version() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    versionApp = packageInfo.version;

    double verApp = double.parse(versionApp);

//? COMPRUEBA VERSION EN FIREBASE(PLAYSTORE)

    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final db = FirebaseFirestore.instance;

// creo una referencia al documento que contiene la version
    final docRefVersion =
        db.collection("versionPlayStore").doc("Izdf1IB8WIfq3s8GbYuK");

    var data = await docRefVersion.get().then(
          (doc) => doc.data(),
        );

    versionPlayS = data!['version'];
    comentarioVersion = data['comentario'];

    debugPrint(
        'La version de la app en PlaStore es: ${versionPlayS.toString()}');
    debugPrint('comentario de version: ${comentarioVersion.toString()}');

    debugPrint('La version de la app instalada es: ${verApp.toString()}');

//? COMPARO VERSION EN FIREBASE(PLAYSTORE) CON LA INSTALADA EN EL MOVIL
    if (versionPlayS) {
      necesitaActualizar = true;
    }

    setState(() {});
  }

  emailUsuario() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;
    _estadopago = estadoPagoProvider.estadoPagoApp;
  }

  @override
  void initState() {
    // leerBasedatos();
    emailUsuario();
    version();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        _iniciadaSesionUsuario
            // CABECERA CUAN HAY UNA SESION INICIADA
            ? _cabeceraConSesion(context)

            // CABECERA CUANDO ES APP GRATUITA
            : _cabeceraGratuita(),

        // CONFIGURA LOS SERVICIOS QUE OFRECEN A CLIENTES
        _serviciosQueOfrece(context),

        //CONFIGURACION DE LA APP
        _configuracion(context),

        // DISPONIBILIDAD SEMANAL
        _disponiblidadSemanal(context),

        const Divider(),

        // REPORTES Y SUGERENCIAS
        _reportes(),

        // COMPRAR LA APLICACION
        _estadopago == 'COMPRADA' ? const Text('') : _comprarAPP(context),

        // PLAN AMIGO
        _iniciadaSesionUsuario ? const Text('') : _planAmigo(context),

        //VALORAR LA APLICACION Y LA VERSION DISPONIBLE
        _valoracionApp(),
      ],
    );
  }

  UserAccountsDrawerHeader _cabeceraConSesion(BuildContext context) {
    return UserAccountsDrawerHeader(
        decoration: BoxDecoration(
            color: Theme.of(context)
                .primaryColor), // Color.fromARGB(255, 122, 121, 197)),
        currentAccountPicture: fotoPerfil(_emailSesionUsuario),
        otherAccountsPictures: [
          IconButton(
              color: Colors.white,
              icon: const Icon(Icons.edit_square),
              onPressed: () =>
                  {Navigator.pushNamed(context, 'ConfigUsuarioApp')}),
        ],
        accountEmail: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(_emailSesionUsuario),
            _estadopago == 'PRUEBA_ACTIVA'
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'versión de prueba',
                        style: TextStyle(
                            color: Color.fromARGB(255, 99, 11, 23),
                            fontSize: 12),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
        accountName: const Text(''));
  }

  DrawerHeader _cabeceraGratuita() {
    return DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
            child: SingleChildScrollView(
          child: Column(children: [
            const Image(
              image: AssetImage('assets/icon/icon.png'),
              width: 100,
            ),
            Text('Agenda de citas', style: estilo),
            _iniciadaSesionUsuario
                ? Text('PRO $versionApp', style: estilo)
                : Text('versión gratuita $versionApp', style: estilo),
          ]),
        )));
  }

  ListTile _serviciosQueOfrece(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.home_repair_service_outlined),
      title: Text('Tus servicios', style: estilo),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiciosScreen(),
            ));
      },
    );
  }

  ListTile _configuracion(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: Text(
        'Configuración',
        style: estilo,
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConfigPersonalizar(),
            ));
      },
    );
  }

  ListTile _disponiblidadSemanal(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.beach_access),
      title: Text(
        'Disponibilidad Semanal',
        style: estilo,
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DisponibilidadSemanalScreen(),
            ));
      },
    );
  }

  ListTile _reportes() {
    return ListTile(
      leading: const Icon(Icons.email),
      title: Text(
        'Reportes y sugerencias',
        style: estilo,
      ),
      onTap: () {
        _sendMail('Tengo sugerencias para Agenda de Citas: ');
      },
    );
  }

  ListTile _comprarAPP(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.monetization_on),
      title: Text(
        'Quitar anuncios y más',
        style: estilo,
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ComprarAplicacion(
                  // usuarioAPP: email,
                  )),
        );
        //  _quitarPublicidad(context, enviosugerencia);
      },
    );
  }

  ListTile _planAmigo(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.face_retouching_natural),
      title: Text(
        ' Plan amigo 🎁',
        style: estilo,
      ),
      onTap: () {
        Navigator.pushNamed(context, 'PlanAmigo');
        //  _quitarPublicidad(context, enviosugerencia);
      },
    );
  }

  ListTile _valoracionApp() {
    return ListTile(
        textColor: Colors.red,
        leading: const Icon(Icons.update),
        title: Column(
          children: [
            // const Text('Actualización disponible en PlayStore'),
            Text(
              comentarioVersion.toString(),
              style: const TextStyle(fontSize: 12),
            )
          ],
        ),
        // link a play store
        onTap: () async {
          const url =
              'https://play.google.com/store/apps/details?id=agendadecitas.app';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        });
  }
}

_sendMail(String subject) async {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'agendadecitaspro@gmail.com',
    query: encodeQueryParameters(<String, String>{
      'subject': subject,
    }),
  );

  await launchUrl(emailLaunchUri);
}
