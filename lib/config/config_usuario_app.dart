import 'package:agendacitas/providers/Firebase/firebase_publicacion_online.dart';
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
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        floatExtended = true;

        // Here you can write your code for open new view
      });
    });

    emailUsuarioApp();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(),
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
              const Divider(),
              ListTile(
                onTap: () async {
                  _alertaCerrado();

                  await PagoProvider().guardaPagado(
                      _iniciadaSesionUsuario!, _emailSesionUsuario!);
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                iconColor: Colors.blue,
                title: const Text('CERRAR SESION'),
                leading: const Icon(Icons.exit_to_app),
              ),
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
        stream:
            FirebaseProvider().cargarPerfilFB(_emailSesionUsuario).asStream(),
        builder: ((context, AsyncSnapshot<PerfilModel> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            //cargo los datos del usuario en esta variable para enviarla a NuevoActualizacionUsuarioApp.dart

            perfilUsuarioApp = snapshot.data;

            return Column(
              children: [
                data!.foto != '' && data.foto != null
                    ? FadeInImage.assetNetwork(
                        width: 250,
                        height: 150,
                        placeholder: './assets/icon/galeria-de-fotos.gif',
                        image: data.foto.toString(),
                      )
                    : SizedBox(
                        child: Image.asset(
                          "./assets/images/nofoto.jpg",
                          width: 250,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  data.denominacion.toString(),
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  child: FutureBuilder(
                    future: FirebasePublicacionOnlineAgendoWeb()
                        .verEstadoPublicacion(perfilUsuarioApp!.email!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      bool estaPublicado =
                          snapshot.data! == 'PUBLICADO' ? true : false;

                      return Container(
                        color: !estaPublicado ? Colors.red : Colors.blue,
                        child: ListTile(
                            onTap: () => launchUrl(!estaPublicado
                                ? Uri.parse(
                                    'https://forms.gle/Rfa17eav1icv37QN6')
                                : Uri.parse('https://agendadecitas.online')),
                            leading: Icon(
                              !estaPublicado ? Icons.public_off : Icons.public,
                              color: Colors.white,
                            ),
                            title: Text(
                              !estaPublicado
                                  ? 'SOLICITUD PUBLICACIÓN EN AGENDADECITAS.ONLINE'
                                  : 'SU ACTIVIDAD ESTÁ PUBLICADA EN:',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                            subtitle: Text(
                              !estaPublicado
                                  ? 'ENVIAR FORMULARIO  📝 '
                                  : 'agendadecitas.online',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                            trailing: SizedBox(
                                height: 65,
                                width: 115,
                                child: Column(
                                  children: [
                                    Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: Switch(
                                          value: estaPublicado,
                                          onChanged: (value) {
                                            setState(() {
                                              publicado = estaPublicado;
                                            });

                                            if (value) {
                                              //* envia el tokenMessaging, imagen,el usuario(email) y publicado == false a  Firebase agendoWeb,
                                              _instruccionesPublicacion(
                                                  context);
                                              FirebasePublicacionOnlineAgendoWeb()
                                                  .creaEstructuraNegocio(
                                                      perfilUsuarioApp!,
                                                      estaPublicado);
                                            } else {
                                              //* pasar la publicado == false en Firebase agendoWeb
                                              _instruccionesDespublicacionPublicacion(
                                                  context);
                                            }
                                          }),
                                    ),
                                  ],
                                ))),
                      );
                    },
                  ),
                ),
                /*  Text(
                  data.descripcion.toString(),
                  style: const TextStyle(fontSize: 12),
                ), */
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    data.telefono.toString(),
                    //   style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(
                    _emailSesionUsuario.toString(),
                    // style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.web),
                  title: Text(
                    data.website.toString(),
                    // style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: Text(
                    data.instagram.toString(),
                    // style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.facebook),
                  title: Text(
                    data.facebook.toString(),
                    //  style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(
                    data.ubicacion.toString(),
                    //style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        }));
  }

  Future<dynamic> _instruccionesPublicacion(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
              textAlign: TextAlign.justify,
              'Cuando su solicitud haya sido completada, publicaremos tu actividad en la web agendadecitas.online.\n\nEnvíanos el formulario y deja esta opción en ON para mantenerla publicada, si la pasas a OFF, tu actividad dejará de estar publicada en la web automáticamente.'),
          actions: [
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

  Future<dynamic> _instruccionesDespublicacionPublicacion(
      BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
              textAlign: TextAlign.justify,
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
    await Future.delayed(const Duration(seconds: 2), (() async {
      await FirebaseAuth.instance.signOut();
      _irHome();
    }));
  }

  void _irHome() {
    Navigator.pushNamed(context, '/');
  }
}
