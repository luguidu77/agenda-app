import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import '../screens/screens.dart';

class ConfigUsuarioApp extends StatefulWidget {
  const ConfigUsuarioApp({Key? key}) : super(key: key);

  @override
  State<ConfigUsuarioApp> createState() => _ConfigUsuarioAppState();
}

class _ConfigUsuarioAppState extends State<ConfigUsuarioApp> {
  String foto = '';
  bool visibleIndicator = false;
  bool? pagado;
  String? usuarioAPP;
  PerfilModel? perfilUsuarioApp;
  bool floatExtended = false;
  emailUsuario() async {
    //traigo email del usuario, para si es de pago, pasarlo como parametro al sincronizar
    final pago = await PagoProvider().cargarPago();
    final p = pago['pago'];
    (p == 'true') ? pagado = true : pagado = false;
    final emailUsuario = pago['email'];
    usuarioAPP = emailUsuario;
    debugPrint('USUARIO APP $usuarioAPP');
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

    emailUsuario();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
                usuarioAPP: usuarioAPP,
              ),
            ),
          );
        },
      ),
      /* */
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _botonCerrar(context),
              const SizedBox(
                height: 20,
              ),
              _fichaPerfilUsuario(),
              const SizedBox(
                height: 50,
              ),
              const Divider(),
              ListTile(
                onTap: () async {
                  _alertaCerrado();
                  await PagoProvider().guardaPagado(pagado!, usuarioAPP!);

                  await FirebaseAuth.instance.signOut();
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
        stream: FirebaseProvider().cargarPerfilFB(usuarioAPP).asStream(),
        builder: ((context, AsyncSnapshot<PerfilModel> snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            //cargo los datos del usuario en esta variable para enviarla a NuevoActualizacionUsuarioApp.dart

            perfilUsuarioApp = snapshot.data;

            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: data!.foto != '' && data.foto != null
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
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  data.denominacion.toString(),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  data.descripcion.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
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
                    usuarioAPP.toString(),
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
    await SincronizarFirebase().sincronizaDescargaDispositivo(usuarioAPP);
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
    await mensajeSuccess(context, 'SESION CERRADA, HASTA PRONTO!');
  }
}
