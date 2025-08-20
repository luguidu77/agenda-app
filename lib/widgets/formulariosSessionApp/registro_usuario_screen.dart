import 'package:agendacitas/providers/creacion_cuenta/cuenta_nueva_provider.dart';
import 'package:agendacitas/widgets/dialogos/dialogo_linealpregessindicator.dart';
import 'package:agendacitas/screens/pagina_creacion_cuenta_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/providers.dart';
import '../../screens/screens.dart';

import '../../utils/utils.dart';
import '../widgets.dart';

// ignore: must_be_immutable
class RegistroUsuarioScreen extends StatefulWidget {
  String registroLogin;
  String usuarioAPP;

  RegistroUsuarioScreen(
      {Key? key, required this.registroLogin, required this.usuarioAPP})
      : super(key: key);

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final formKeyInicioSesion = GlobalKey<FormState>();
  final formKeyCrearCuenta = GlobalKey<FormState>();
  double? valorindicator;
  bool configuracionFinalizada = false;

  bool visibleBotonGPAY = false;
  bool visibleIndicator = false;
  bool visibleFormulario = true;
  bool visiblePagoRealizado = false;
  bool visibleGuardarPagoRealizado = false;
  bool visibleRespaldoRealizado = false;

  String? email;
  String? password;
  String? nombreUsuario;

  bool loginRegistro = false; //true = login,, false = registro
  bool hayEmailUsuario = false;

  bool showModal = true;
  final ctlTextPassword1 = TextEditingController();

  @override
  void initState() {
    super.initState();

    loginRegistro = (widget.registroLogin == 'Login') ? true : false;
    hayEmailUsuario = (widget.usuarioAPP == '') ? false : true;

    sesionGardadoSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
            //  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: loginRegistro ? formInicioSesion() : formCrearCuenta()),
      ),
    );
  }

  formInicioSesion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          './assets/icon/icon.png',
          height: 120,
        ),
        // hello again!
        Text(
          hayEmailUsuario ? 'Hola $nombreUsuario' : 'Hola!, ...',
          style: GoogleFonts.bebasNeue(fontSize: 40),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            hayEmailUsuario
                ? 'te echabamos de menos!'
                : 'No te conozco, ¿quién eres?',
            style: const TextStyle(fontSize: 20),
          ),
        ),

        const SizedBox(height: 50),
        Form(
            key: formKeyInicioSesion,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                //email----------------------------------------------------
                hayEmailUsuario
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  prefixIcon: IconTheme(
                                    data: IconThemeData(
                                        color: Colors.deepPurple[200]),
                                    child: const Icon(Icons.email),
                                  ),
                                  border: InputBorder.none,
                                  hintText: 'Email'),
                              onSaved: (input) => email = input,
                              validator: (value) {
                                return EmailValidator.validate(value!)
                                    ? null
                                    : "Introduce un email válido";
                              },
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 10),
                //pasword ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        obscureText: true,
                        controller: ctlTextPassword1,
                        decoration: InputDecoration(
                            prefixIcon: IconTheme(
                              data:
                                  IconThemeData(color: Colors.deepPurple[200]),
                              child: const Icon(Icons.password),
                            ),
                            border: InputBorder.none,
                            hintText: 'Contraseña'),
                        onSaved: (input) => password = input,
                        validator: (input) => input!.isEmpty || input.length < 6
                            ? "6 caracteres como minimo"
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // NO RECUERDO LA CONTRASEÑA--------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return const ForgotPasswordPage();
                          }));
                        },
                        child: const Text(
                          'No recuerdo la contraseña',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                //BOTON INICIAR SESION ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: () async {
                      // ? INICIO DE SESION , DESCARGA DATOS DE FIREBASE

                      final form = formKeyInicioSesion.currentState;
                      form!.save();

                      if (form.validate()) {
                        debugPrint('FORMULARIO LOGIN VALIDO');
                        // ACTUALIZA EL PROVIDER DE CUENTA NUEVA para que en inicio_config_app.dart  acceda a la pantalla home
                        context
                            .read<CuentaNuevaProvider>()
                            .setCuentaNueva(false);

                        dialogoLinealProgressIndicator(
                            context, 'Comprobando credenciales');

                        /*  Future.delayed(const Duration(milliseconds: 2000),
                            () async {
                          Navigator.pop(context);
                        }); */

                        var res = await validateLoginInput(
                            context, email!, password!);

                        if (res == 'wrong-password') {
                          _cierraDialogo();
                          mensaje('CONTRASEÑA ERRONEA');
                        } else if (res == 'user-not-found') {
                          _cierraDialogo();
                          mensaje('USUARIO NO ENCONTRADO');
                        } else if (res == 'too-many-requests') {
                          _cierraDialogo();
                          mensaje('USUARIO BLOQUEADO TEMPORALMENTE');
                        } else {
                          debugPrint(
                              '--------iniciada sesion correctamente --------------------');
                          //_irPaginaIconoAnimacion();
                          _cierraDialogo();
                          _irPaginaInicio();
                          gardarSesion(email, password);
                        }
                      } else {
                        mensajeError(context, 'FORMULARIO NO VALIDO');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.deepPurple[300],
                          borderRadius: BorderRadius.circular(22)),
                      child: const Center(
                          child: Text(
                        'ACCEDER',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ACCEDER CON OTRA CUENTA--------------------------------

                hayEmailUsuario
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                /*   // GUARDA EN EL PROVIDER Y LIMPIA VARIABLES PARA QUE SE PUEDA INICIAR SESION CON OTRO EMAIL
                                await PagoProvider().guardaPagado(false, ''); */
                                hayEmailUsuario = false;
                                email = '';
                                ctlTextPassword1.text = '';
                                limpiaSesionGuardada();

                                await FirebaseAuth.instance.signOut();

                                setState(() {});
                              },
                              child: const Text(
                                'Acceder con otra cuenta',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container()
              ],
            )), // email texfield

        const SizedBox(height: 25),

        //https://pages.flycricket.io/agenda-de-citas/privacy.html

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Accediendo das tu consentimiento a la ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
            GestureDetector(
              onTap: () async {
                const url =
                    'https://agendadecitas.cloud/politica-de-privacidad-de-la-agenda-de-citas';
                if (await launchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'política de privacidad ',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
            )
          ],
        ),
      ],
    );
  }

  formCrearCuenta() {
    String diasDePrueba = DiasDePrueba.getTexto();

    final ctlTextPassword1 = TextEditingController();
    final ctlTextPassword2 = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          './assets/icon/icon.png',
          height: 120,
        ),
        // hello again!
        Text(
          'nuev@ por aquí?',
          style: GoogleFonts.bebasNeue(fontSize: 40),
        ),
        const SizedBox(height: 10),

        //TEXTO QUE INFORMA DE LOS DIAS DE PRUEBA
        TextoDiasDePrueba(diasDePrueba: diasDePrueba),

        const SizedBox(height: 10),
        Form(
          key: formKeyCrearCuenta,
          autovalidateMode: AutovalidateMode
              .onUserInteraction, // Valida cuando interactúas con los campos.
          child: Column(
            children: [
              // Email
              if (!hayEmailUsuario)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: _buildTextField(
                    hintText: 'Email',
                    icon: Icons.email,
                    validator: (value) {
                      return EmailValidator.validate(value!)
                          ? null
                          : "Introduce un email válido";
                    },
                    onSaved: (value) => email = value,
                  ),
                ),
              const SizedBox(height: 10),

              // Contraseña
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: _buildTextField(
                  controller: ctlTextPassword1,
                  hintText: 'Contraseña',
                  icon: Icons.password,
                  obscureText: false, // Esconde el texto
                  validator: (input) => input != null && input.length >= 6
                      ? null
                      : "6 caracteres como mínimo",
                ),
              ),
              const SizedBox(height: 10),

              // Repetir contraseña
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: _buildTextField(
                  controller: ctlTextPassword2,
                  hintText: 'Repite contraseña',
                  icon: Icons.password,
                  obscureText: false,
                  validator: (input) {
                    return input == ctlTextPassword1.text
                        ? null
                        : "Las contraseñas deben coincidir";
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Política de privacidad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Accediendo das tu consentimiento a la ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                  GestureDetector(
                    onTap: () async {
                      const url =
                          'https://agendadecitas.cloud/politica-de-privacidad-de-la-agenda-de-citas';
                      try {
                        await launchUrl(Uri.parse(url));
                      } catch (e) {
                        throw 'No se pudo abrir la URL: $url';
                      }
                    },
                    child: const Text(
                      'política de privacidad ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              // Botón CREAR CUENTA
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GestureDetector(
                  onTap: () {
                    final form = formKeyCrearCuenta.currentState;
                    if (form != null && form.validate()) {
                      form.save();
                      debugPrint('FORMULARIO CREACIÓN CUENTA VÁLIDO');
                      _irPaginaCreacionCuenta(email!, ctlTextPassword1.text);
                    } else {
                      mensajeError(context, 'FORMULARIO NO VÁLIDO');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[300],
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        'CREAR CUENTA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        //https://pages.flycricket.io/agenda-de-citas/privacy.html
      ],
    );
  }

  void _irPaginaCreacionCuenta(String email, String password) {
    FocusScope.of(context).unfocus();

    Navigator.pushNamed(context, 'paginaIconoAnimacion', arguments: email);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaginaIconoAnimado(email: email, password: password),
      ),
    );
  }

  void _irPaginaInicio() {
    FocusScope.of(context).unfocus();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => InicioConfigApp(
                  usuarioAPP: email!,
                )),
        ModalRoute.withName('home'));
  }

  void mensaje(String s) {
    mensajeError(context, s);
  }

  void _cierraDialogo() {
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: IconTheme(
              data: IconThemeData(color: Colors.deepPurple[200]),
              child: Icon(icon),
            ),
            border: InputBorder.none,
            hintText: hintText,
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ),
    );
  }

  void gardarSesion(String? email, String? password) async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('email', email!);
      prefs.setString('password', password!);
    });
  }

  sesionGardadoSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final emailguardado = prefs.getString('email');
    final password = prefs.getString('password');

    if (emailguardado != null) {
      email = emailguardado; //no hay sesion
      ctlTextPassword1.text = password!;
      nombreUsuario = prefs.getString('nombreUsuarioApp');
      setState(() {});
    }
  }

  limpiaSesionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('nombreUsuarioApp');
  }
}

class TextoDiasDePrueba extends StatelessWidget {
  const TextoDiasDePrueba({
    super.key,
    required this.diasDePrueba,
  });

  final String diasDePrueba;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Prueba durante ',
                      style:
                          TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                    ),
                    TextSpan(
                      text: '$diasDePrueba días',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 41, 22, 151),
                          fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          ', todas las opciones y funcionalidades sin publicidad, sólo necesitas un email y una contraseña, puedes cancelar en cualquier momento. ',
                      style:
                          TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                    ),
                    const TextSpan(
                      text:
                          'Una vez finalizado el periodo de prueba, tendrás la opción de continuar por ',
                      style:
                          TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                    ),
                    const TextSpan(
                      text: ' un sólo pago sin suscripción ',
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 22, 151),
                          fontWeight: FontWeight.bold),
                    ),
                    /*  const TextSpan(
                      text: '(precio de lanzamiento)',
                      style: TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                    ), */
                  ]),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                const url = 'https://agendadecitas.online/comoeliminarcuenta';
                if (await launchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'CÓMO ELIMINAR SU CUENTA Y/O SUS DATOS',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// BOTON DE REGISTRO O DE INICIO DE SESION CUSTOMIZADO
Widget filledButton(String text, Color splashColor, Color highlightColor,
    Color fillColor, Color textColor, void Function() function, bool loading) {
  return ElevatedButton(
    child: loading
        ? const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              color: Colors.white,
            ))
        : Text(
            (text == 'Registro2' ? 'Vincula tu cuenta' : text),
            style: TextStyle(
                fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
          ),
    onPressed: () => function(),
  );
}
