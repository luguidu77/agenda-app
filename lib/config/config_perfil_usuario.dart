import 'package:agendacitas/config/config.dart';
import 'package:agendacitas/models/empleado_model.dart';
import 'package:agendacitas/providers/Firebase/firebase_publicacion_online.dart';
import 'package:agendacitas/providers/rol_usuario_provider.dart';
import 'package:agendacitas/screens/style/estilo_pantalla.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../screens/screens.dart';
import '../utils/utils.dart';

class ConfigPerfilUsuario extends StatefulWidget {
  ConfigPerfilUsuario({Key? key}) : super(key: key);

  @override
  State<ConfigPerfilUsuario> createState() => _ConfigPerfilUsuarioState();
}

class _ConfigPerfilUsuarioState extends State<ConfigPerfilUsuario>
    with RouteAware {
  String foto = '';
  bool visibleIndicator = false;
  bool? _iniciadaSesionUsuario;
  String? _emailSesionUsuario;
  String? _emailAdministrador;
  PerfilEmpleadoModel? perfilUsuarioApp;
  bool floatExtended = false;
  late bool publicado = false;

  bool _comprobando = false;

  emailUsuarioApp() async {
    final estadoPagoProvider = context.read<EmailUsuarioAppProvider>();
    _emailSesionUsuario = estadoPagoProvider.emailUsuarioApp;

    final contextoEmailAdmin = context.read<EmailAdministradorAppProvider>();
    _emailAdministrador = contextoEmailAdmin.emailAdministradorApp;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    mRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    mRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {});
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton.icon(
            label: const Text('EDITAR'),
            style: ButtonStyle(
                foregroundColor: const WidgetStatePropertyAll(
                  Colors.white,
                ),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor,
                )),
            onPressed: () async {
              mensajeInfo(context, 'Estamos trabajando, disculpa');
              /*  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NuevoAcutalizacionUsuarioApp(
                    perfilUsuarioApp: perfilUsuarioApp,
                    usuarioAPP: _emailSesionUsuario,
                  ),
                ),
              ); */
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          )
        ],
      ),

      /* */
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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

  StreamBuilder<PerfilEmpleadoModel> _fichaPerfilUsuario() {
    final contextoRoles = context.read<RolUsuarioProvider>();
    final textControllerDenominacion = TextEditingController();

    return StreamBuilder(
      stream: _perfil(),
      builder: (context, AsyncSnapshot<PerfilEmpleadoModel> snapshot) {
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
                const SizedBox(height: 40),
                // veficacion de usuario
                Visibility(
                  visible: data!.codVerif != 'verificado' ? true : false,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.red[500],
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          title: Text(
                            'Cuenta no verificada',
                            style: estiloHorariosResaltado,
                          ),
                          leading:
                              const Icon(Icons.verified, color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: textControllerDenominacion,
                              decoration: InputDecoration(
                                errorText:
                                    _comprobando ? 'Código incorrecto' : null,
                                labelText: 'Código verificación',
                                prefixIcon: Icon(Icons.password,
                                    color: Theme.of(context).primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _verificarEmpleado(
                                context,
                                textControllerDenominacion.text,
                                data.codVerif!),
                            child: SizedBox(
                              width: 150,
                              height: 80,
                              child: Card(
                                color: Colors.blue[500],
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  title: Text(
                                    'Verificar',
                                    style: subTituloEstilo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Denominación del negocio
                Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(
                      data!.nombre.toString(),
                      style: tituloEstilo,
                    ),
                    leading: const Icon(Icons.person, color: Colors.blue),
                  ),
                ),

                // Teléfono de contacto
                Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: Text(data.telefono.toString()),
                  ),
                ),

                // Email
                Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.red),
                    title: Text(data.email.toString()),
                  ),
                ),

                // Website
                /*  Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                        const Icon(Icons.language, color: Colors.blueAccent),
                    title: Text(data.website.toString()),
                  ),
                ), */

                // Instagram
                /*   Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.photo, color: Colors.pink),
                    title: Text(data.instagram.toString()),
                  ),
                ), */

                // Facebook
                /*  Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const Icon(Icons.facebook, color: Colors.blue),
                    title: Text(data.facebook.toString()),
                  ),
                ), */

                // Ubicación
                /*  Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading:
                        const Icon(Icons.location_city, color: Colors.orange),
                    title: Text(data.ubicacion.toString()),
                  ),
                ), */

                const Divider(),

                // Botón de Cerrar Sesión
                Card(
                  color: Colors.red[100],
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () async {
                      _alertaCerrado();
                      /*  await PagoProvider().guardaPagado(
                          _iniciadaSesionUsuario!, _emailSesionUsuario!); */

                      await FirebaseAuth.instance.signOut();

                      _irHome();
                    },
                    iconColor: Colors.blue,
                    title: const Text(
                      'CERRAR SESIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  ),
                )
              ],
            ),
          );
        }
        return const SizedBox(); // Retornar un SizedBox si no hay datos
      },
    );
  }

  // Encabezado de la Foto del Perfil
  SizedBox _fotoEncabezado(PerfilEmpleadoModel? data) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip
            .antiAlias, // Asegura que la imagen respete los bordes redondeados
        child: Stack(
          children: [
            data!.foto != '' && data.foto != null
                ? Image.network(
                    data.foto.toString(),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "./assets/images/nofoto.jpg",
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
          ],
        ),
      ),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const Bienvenida(
              // usuarioAPP: email,
              )),
    );
  }

  Stream<PerfilEmpleadoModel> _perfil() {
    final contextoEmpleado = context.read<EmailUsuarioAppProvider>();
    String contextEmail = contextoEmpleado.emailUsuarioApp;
    return FirebaseProvider()
        .cargarPerfilEmpleado(_emailAdministrador!, contextEmail)
        .asStream();
  }

  Future<void> _verificarEmpleado(BuildContext context, String codigoIngresado,
      String codVerficacion) async {
    if (codigoIngresado == codVerficacion) {
      await _dialogo(context);
      setState(() {});
    } else {
      // showdialog que diga codigo incorrecto
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Código Incorrecto'),
            content: const Text(
                'El código ingresado no es correcto. Por favor, inténtalo de nuevo.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }

  _dialogo(BuildContext context) async {
    BuildContext? dialogContext; // Contexto para cerrar el primer diálogo
    // Mostrar diálogo inicial de verificación
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogBuilderContext) {
        dialogContext = dialogBuilderContext; // Guardar el contexto del diálogo
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Borde redondeado
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blueAccent), // Icono informativo
              SizedBox(width: 8),
              Text(
                'Verificando...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const SizedBox(
            height: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 4,
                ),
                SizedBox(height: 12),
                Text(
                  'Por favor, espera un momento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // realizar la verificación

      bool verificacionExitosa = await FirebaseProvider()
          .editaCodigoVerificacion(
              _emailAdministrador!, _emailSesionUsuario!, 'verificado');

      // Cerrar el diálogo de carga (verificar que dialogContext no sea nulo)
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }

      // Mostrar mensaje según el resultado
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(verificacionExitosa
                ? 'Verificación Exitosa'
                : 'Error al Verificar'),
            content: Text(verificacionExitosa
                ? 'El proceso de verificación se completó con éxito.'
                : 'Hubo un error al intentar verificar. Por favor, inténtalo de nuevo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        index: 0,
                        myBnB: 0,
                      ), // Pantalla de configuración
                    ),
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // En caso de error inesperado, cerrar el diálogo de carga y mostrar error
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Ocurrió un error: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }
  }
}
