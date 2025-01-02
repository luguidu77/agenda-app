import 'package:agendacitas/firebase_options.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/models/models.dart';
import 'package:agendacitas/models/perfil_usuarioapp_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_publicacion_online.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/creacion_citas/empleados_screen.dart';
import 'package:agendacitas/screens/servicios_screen.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class MenuAplicacion extends StatefulWidget {
  const MenuAplicacion({
    Key? key,
  }) : super(key: key);
  @override
  State<MenuAplicacion> createState() => _MenuAplicacionState();
}

class _MenuAplicacionState extends State<MenuAplicacion> {
  String _emailSesionUsuario = '';
  String _emailAdministrador = '';
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
    final estadoPagoProvider = context.read<EmailUsuarioAppProvider>();
    _emailSesionUsuario =
        estadoPagoProvider.emailUsuarioApp; // emailUsuarioApp;

    final contextoEmailAdmin = context.read<EmailAdministradorAppProvider>();
    _emailAdministrador =
        contextoEmailAdmin.emailAdministradorApp; // emailAdministradorApp;
  }

  String imageUrl = '';

  Future<String> obtenerImagenDesdeFirebase() async {
    final contextoRoles = context.read<RolUsuarioProvider>();
    if (contextoRoles.rol == RolEmpleado.administrador) {
      final perfil =
          await FirebaseProvider().cargarPerfilFB(_emailAdministrador);

      PerfilAdministradorModel perfilModel =
          PerfilAdministradorModel(foto: perfil.foto);

      setState(() {});
      return perfilModel.foto.toString();
    } else {
      print(_emailSesionUsuario);
      final perfil = await FirebaseProvider()
          .cargarPerfilEmpleado(_emailAdministrador, _emailSesionUsuario);

      PerfilEmpleadoModel perfilModel = PerfilEmpleadoModel(foto: perfil.foto);
      setState(() {});
      return perfilModel.foto.toString();
    }
  }

  imagenUrl() async {
    imageUrl = await obtenerImagenDesdeFirebase();
  }

  @override
  void initState() {
    // leerBasedatos();
    emailUsuario();
    imagenUrl();
    version();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextoRoles = context.read<RolUsuarioProvider>();

    return Container(
      color: colorFondo,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          // CABECERA CUAN HAY UNA SESION INICIADA
          _cabeceraConSesion(context),

          // MENSAJE PARA LA PUBLICACION EN AGENDADECITAS.ONLINE
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador,
            child: _iniciadaSesionUsuario
                ? _mensajePublicacionOnline(context, _emailSesionUsuario)
                : Container(),
          ),

          // CONFIGURA LOS SERVICIOS QUE OFRECEN A CLIENTES
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador ||
                contextoRoles.rol == RolEmpleado.gerente,
            child: _serviciosQueOfrece(context),
          ),

          // EMPLEADOS
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador ||
                contextoRoles.rol == RolEmpleado.gerente,
            child: _empleados(context),
          ),

          //CONFIGURACION DE LA APP
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador ||
                contextoRoles.rol == RolEmpleado.gerente,
            child: _configuracion(context),
          ),

          // DISPONIBILIDAD SEMANAL
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador ||
                contextoRoles.rol == RolEmpleado.gerente,
            child: _disponiblidadSemanal(context),
          ),

          // INFORMES GANANCIAS
          Visibility(
            visible: contextoRoles.rol == RolEmpleado.administrador,
            child: _informes(context),
          ),

          const Divider(),

          /*  _estadopago == 'INITIAL' || _estadopago == 'GRATUITA'
              ? _creaCuentaPruebas()
              : const Text(''), */

          // COMPRAR LA APLICACION
          // _estadopago == 'COMPRADA' ? const Text('') : _comprarAPP(context),

          // PLAN AMIGO
          // _estadopago == 'COMPRADA' ? const Text('') : _planAmigo(context),

          //NOTIFICACIONES
          _notificaciones(),

          //BLOG AGENDADECITAS.CLOUD
          _blog(),

          // REPORTES Y SUGERENCIAS
          _reportes(),

          //_pruebaEnvioEmail(context),

          //VALORAR LA APLICACION Y LA VERSION DISPONIBLE
          // _valoracionApp(),
        ],
      ),
    );
  }

  _cabeceraConSesion(BuildContext context) {
    final contextoRoles = context.read<RolUsuarioProvider>();

    return Stack(
      children: [
        // Imagen de fondo
        Container(
          height: 200.0, // Altura del header
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl) // Cargar la imagen desde URL
                  : const AssetImage("assets/images/nofoto.jpg")
                      as ImageProvider, // Imagen local por defectofondo
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Degradado encima de la imagen
        Container(
          height: 200.0, // La misma altura que el Container de la imagen
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Colors.white.withOpacity(0.6), // Negro semi-transparente arriba
                Colors.white, // Transparente abajo
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // UserAccountsDrawerHeader
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.transparent, // Para que el fondo sea transparente
          ),
          // currentAccountPicture: fotoPerfil(_emailSesionUsuario),
          //currentAccountPictureSize: const Size.square(95.0),
          otherAccountsPictures: [
            // light/dark
            //  const ChangeThemeButtonWidget(),

            // editar perfil
            IconButton(
              color: Colors.black,
              icon: const Icon(Icons.edit_square),
              onPressed: () => contextoRoles.rol == RolEmpleado.administrador
                  ? Navigator.pushNamed(context, 'ConfigPerfilAdminstrador')
                  : Navigator.pushNamed(context, 'ConfigPerfilUsuario'),
            ),
          ],
          accountEmail: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                denominacionNegocio(_emailAdministrador),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _estadopago == 'PRUEBA_ACTIVA'
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  'versión de prueba',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 99, 11, 23),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Text(
                        'versión $versionApp',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 99, 11, 23),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          accountName: const Text(''),
        ),
      ],
    );
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
              width: 80,
            ),
            Text('Agenda de citas', style: estilo),
            Text('versión gratuita $versionApp', style: estilo),
          ]),
        )));
  }

  _mensajePublicacionOnline(BuildContext context, String emailUsuario) {
    return FutureBuilder(
        future: FirebasePublicacionOnlineAgendoWeb()
            .verEstadoPublicacion(emailUsuario),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data != 'NO PUBLICADO') {
            return Container();
          }
          return Container(
            color: Colors.blue,
            child: ListTile(
              leading: const Icon(Icons.edit_square),
              subtitle: const Text(
                  style: TextStyle(color: Colors.white),
                  'En tu perfil hemos agreado un enlace que te lleva al formulario de solicitud para publicar tu actividad en la web agendadecitas.online'),
              onTap: () =>
                  {Navigator.pushNamed(context, 'ConfigPerfilAdminstrador')},
            ),
          );
        });
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

  ListTile _notificaciones() {
    return ListTile(
      leading: const Icon(Icons.notification_important_outlined),
      title: Text(
        'Notificaciones',
        style: estilo,
      ),
      onTap: _iniciadaSesionUsuario
          ? () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      index: 1,
                      myBnB: 1,
                    ),
                  ));
            }
          : () => mensajeError(context, 'Necesita iniciar sesión'),
    );
  }

  ListTile _blog() {
    return ListTile(
      leading: const Icon(Icons.wordpress),
      title: Text(
        'Blog',
        style: estilo,
      ),
      onTap: () async {
        const url = 'https://agendadecitas.cloud';
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'No se pudo lanzar $url';
        }
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
        Comunicaciones.enviaEmailConAsunto(
            'Reporte y/o sugerencias para Agenda de Citas');
      },
    );
  }

  /*  ListTile _comprarAPP(BuildContext context) {
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
  } */

  ListTile _informes(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.bar_chart_rounded),
      title: Text(
        'Informes',
        style: estilo,
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InformesScreen(),
            ));
        //  _quitarPublicidad(context, enviosugerencia);
      },
    );
  }

/*   ListTile _planAmigo(BuildContext context) {
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
  } */

  ListTile _pruebaEnvioEmail(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.face_retouching_natural),
      title: Text(
        ' prueba envio automatico email',
        style: estilo,
      ),
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EnvioSensinblue()));
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
          if (await launchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        });
  }

  _creaCuentaPruebas() {
    return Container(
      color: const Color.fromARGB(255, 101, 176, 238),
      child: ListTile(
        leading: const Icon(Icons.face_retouching_natural),
        title: Text(
          'Crea cuenta de prueba online',
          style: textoEstilo,
        ),
        subtitle: const Text('Pública tu actividad en la placemarket'),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => RegistroUsuarioScreen(
                      registroLogin: 'Registro',
                      usuarioAPP: '',
                    )),
          );
        },
      ),
    );
  }

  ListTile _empleados(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text('Gestión de personal', style: estilo),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmpleadosScreen(),
            ));
      },
    );
  }
}
