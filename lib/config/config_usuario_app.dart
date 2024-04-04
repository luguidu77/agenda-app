import 'package:agendacitas/providers/Firebase/firebase_publicacion_online.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';

class ConfigUsuarioApp extends StatefulWidget {
  const ConfigUsuarioApp({Key? key}) : super(key: key);

  @override
  State<ConfigUsuarioApp> createState() => _ConfigUsuarioAppState();
}

class _ConfigUsuarioAppState extends State<ConfigUsuarioApp> {
  String foto = '';
  bool visibleIndicator = false;
  bool? _iniciadaSesionUsuario;
  String? _emailSesionUsuario;
  PerfilModel? perfilUsuarioApp;
  bool floatExtended = false;
  late bool publicado = false;

  emailUsuarioApp() async {
    final estadoPagoProvider = context.read<EstadoPagoAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;
    _iniciadaSesionUsuario = estadoPagoProvider.iniciadaSesionUsuario;

    debugPrint('USUARIO APP $_emailSesionUsuario');
    setState(() {});
  }

  @override
  void initState() {
    /*  Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        floatExtended = true;

        // Here you can write your code for open new view
      });
    }); */

    emailUsuarioApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      // appBar: AppBar(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'EDITAR PERFIL',
        ),
        isExtended: floatExtended,
        icon: const Icon(Icons.edit),
        onPressed: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoAcutalizacionUsuarioApp(
                perfilUsuarioApp: perfilUsuarioApp,
                usuarioAPP: _emailSesionUsuario,
              ),
            ),
          );
        },
      ),
      /* */
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  _botonCerrar(context),
              /* const SizedBox(
                height: 20,
              ), */
              _fichaPerfilUsuario(),
              const SizedBox(
                height: 10,
              ),
              // const Divider(),

              const SizedBox(
                height: 20,
              ),
              //################ BOTON PARA RESTABLECER LOS DATOS DEL DISPOSITIVO CON LOS DE FIREBASE
              /*       ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 241, 59, 59),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _restablecerApp();

                    setState(() {
                      visibleIndicator = false;
                    });
                    _snackBarFinalizado(context);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text(
                      'Restablece los datos de tu dispositivo con los guardados en la nube')), */
              visibleIndicator ? const LinearProgressIndicator() : Container(),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    ));
  }

/*   void _irPaginaInicio() {
    FocusScope.of(context).unfocus();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  } */

  StreamBuilder<PerfilModel> _fichaPerfilUsuario() {
    return StreamBuilder(
      stream: FirebaseProvider().cargarPerfilFB(_emailSesionUsuario).asStream(),
      builder: (context, AsyncSnapshot<PerfilModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LinearProgressIndicator(), // Indicador de carga centrado
          );
        }
        if (snapshot.hasData) {
          final data = snapshot.data;
          perfilUsuarioApp = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _fotoEncabezado(data),
                const SizedBox(height: 10),
                _etiquetaPublicacionWeb(),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    data!.denominacion.toString(),
                    style: tituloEstilo,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    data.telefono.toString(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(
                    _emailSesionUsuario.toString(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.web),
                  title: Text(
                    data.website.toString(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text(
                    data.instagram.toString(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.facebook),
                  title: Text(
                    data.facebook.toString(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(
                    data.ubicacion.toString(),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () async {
                    _alertaCerrado();
                    await PagoProvider().guardaPagado(
                        _iniciadaSesionUsuario!, _emailSesionUsuario!);
                    await FirebaseAuth.instance.signOut();
                    _irHome();
                  },
                  /* shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ), */
                  iconColor: Colors.blue,
                  title: const Text('CERRAR SESION'),
                  leading: const Icon(Icons.exit_to_app),
                ),
              ],
            ),
          );
        }
        return SizedBox(); // Retornar un SizedBox si no hay datos
      },
    );
  }

  SizedBox _fotoEncabezado(PerfilModel? data) {
    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        children: [
          data!.foto != '' && data.foto != null
              ? Image.network(
                  data.foto.toString(),
                  width: double.infinity, // Para que ocupe todo el ancho
                  height: 150,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  "./assets/images/nofoto.jpg",
                  width: double.infinity, // Para que ocupe todo el ancho
                  height: 150,
                  fit: BoxFit.cover,
                ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _etiquetaPublicacionWeb() {
    Color color = Colors.red;
    bool publicado = false;

    return SizedBox(
      height: 80,
      child: FutureBuilder(
        future: FirebasePublicacionOnlineAgendoWeb()
            .verEstadoPublicacion(perfilUsuarioApp!.email!),
        builder: (context, snapshot) {
          // comprueba que hay datos del estado de la publicacion
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          // bool estaPublicado = snapshot.data! == 'PUBLICADO' ? true : false;
          String estadoPublicado = snapshot.data!;
          switch (estadoPublicado) {
            case 'NO PUBLICADO':
              color = Colors.red;
              publicado = false;

            case 'PROCESANDO':
              color = Colors.green;
              publicado = false;
            default:
              color = Colors.blue;
              publicado = true;
          }

          return Container(
              color: color,
              child: ListTile(
                  onTap: () {
                    !publicado
                        ? estadoPublicado != 'PROCESANDO'
                            ? _instruccionesPublicacion(context)
                            : null
                        : launchUrl(Uri.parse(
                            'https://agendadecitas.online/negocio/$estadoPublicado'));
                  },
                  /*  leading: Icon(
                    !estaPublicado ? Icons.public_off : Icons.public,
                    color: Colors.white,
                  ), */
                  title: Text(
                    !publicado
                        ? estadoPublicado == 'PROCESANDO'
                            ? 'ESTADO: EN ESTUDIO'
                            : 'PUBLICA MI ACTIVIDAD'
                        : 'ESTADO: PUBLICADO',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  subtitle: !publicado
                      ? Text(
                          estadoPublicado == 'PROCESANDO'
                              ? '✔️ FORMULARIO ENVIADO '
                              : '➡️ ENVIAR FORMULARIO  ',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        )
                      : Text('Id: $estadoPublicado',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white)),
                  trailing: SizedBox(
                      height: 65,
                      width: 115,
                      child: Column(
                        children: [
                          Text(
                            (estadoPublicado == 'PROCESANDO' ||
                                    estadoPublicado == 'NO PUBLICADO')
                                ? estadoPublicado
                                : 'ONLINE',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                          SizedBox(
                              height: 35,
                              child: Switch(
                                  value: publicado,
                                  onChanged: (value) {
                                    setState(() {
                                      publicado = publicado;
                                    });

                                    if (value) {
                                      //* envia el tokenMessaging, imagen,el usuario(email) y publicado == false a  Firebase agendoWeb,
                                    } else {
                                      //* pasar la publicado == false en Firebase agendoWeb
                                      _instruccionesDespublicacionPublicacion(
                                          context);
                                    }
                                  })),
                        ],
                      ))));
        },
      ),
    );
  }

  Future<dynamic> _instruccionesPublicacion(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Column(
            children: [
              Text(
                'Proceso de publicación en agendadecitas.online :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  textAlign: TextAlign.start,
                  '\n\n📝 Cumplimenta el formulario.\n\n🖥️ Una vez lo hayamos recibido, lo procesaremos para adecuarlo a la web.\n\n💲La publicación de tu actividad es gratuita'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                FirebasePublicacionOnlineAgendoWeb()
                    .creaEstructuraNegocio(perfilUsuarioApp!);
                // Cerrar el diálogo

                launchUrl(Uri.parse('https://forms.gle/Rfa17eav1icv37QN6'));
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/');
              },
              child: const Text('Ir al formulario'),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _instruccionesDespublicacionPublicacion(
      BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
              textAlign: TextAlign.start,
              'Su actividad dejará de estar publicada en agendadecitas.online.\n\nPara volver a publicar tu actividad contacta con soporte.'),
          actions: [
            TextButton(
              onPressed: () async {
                //* pasar la publicado == false en Firebase agendoWeb
                await FirebasePublicacionOnlineAgendoWeb()
                    .swicthPublicado(perfilUsuarioApp!, false);

                setState(() {
                  // Cerrar el diálogo

                  Navigator.of(context).pop();
                });
              },
              child: const Text('Despublicar mi actividad'),
            ),
            TextButton(
              onPressed: () {
                // Cerrar el diálogo
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _snackBarFinalizado(BuildContext context) {
    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: 'Restablecido los datos con exito',
      ),
    );
  }

  void _restablecerApp() async {
    setState(() {
      visibleIndicator = true;
    });
    await SincronizarFirebase()
        .sincronizaDescargaDispositivo(_emailSesionUsuario);
  }

  _botonCerrar(context) {
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
                Navigator.pop(context);
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

  void _alertaCerrado() async {
    mensajeInfo(context, 'CERRANDO SESION...');
    await Future.delayed(const Duration(seconds: 4));
  }

  void _irHome() {
    Navigator.pushNamed(context, '/');
  }
}
