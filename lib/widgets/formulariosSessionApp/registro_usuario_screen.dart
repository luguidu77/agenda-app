import 'package:agendacitas/widgets/dialogos/dialogo_linealpregessindicator.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  String txtregistroLogin = '';
  bool loginRegistro = false; //true = login,, false = registro
  bool hayEmailUsuario = false;

  bool showModal = true;
  //TextEditingController textControllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    txtregistroLogin = widget.registroLogin;
    loginRegistro = (txtregistroLogin == 'Login') ? true : false;
    hayEmailUsuario = (widget.usuarioAPP == '') ? false : true;
    email = widget.usuarioAPP;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: loginRegistro ? formInicioSesion() : formCrearCuenta()),
        ),
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
          hayEmailUsuario
              ? 'Hola ${widget.usuarioAPP.toString().split('@')[0]}!'
              : 'Hola!, ...',
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

                        dialogoLinealProgressIndicator(
                            context, 'Comprobando credenciales...');

                        Future.delayed(const Duration(milliseconds: 500),
                            () async {
                          Navigator.pop(context);
                        });

                        final res =
                            await validateLoginInput(context, email, password);
                        // print(res);

                        if (res == 'wrong-password') {
                          mensaje('CONTRASEÑA ERRONEA');
                        } else if (res == 'user-not-found') {
                          mensaje('USUARIO NO ENCONTRADO');
                        } else if (res == 'too-many-requests') {
                          mensaje('USUARIO BLOQUEADO TEMPORALMENTE');
                        } else {
                          print(
                              '--------iniciada sesion correctamente --------------------');

                          _irPaginaInicio();
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
                                // GUARDA EN EL PROVIDER Y LIMPIA VARIABLES PARA QUE SE PUEDA INICIAR SESION CON OTRO EMAIL
                                await PagoProvider().guardaPagado(false, '');
                                hayEmailUsuario = false;
                                email = '';

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
                    'https://pages.flycricket.io/agenda-de-citas/privacy.html';
                if (await canLaunch(url)) {
                  await launch(url);
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

        const SizedBox(height: 50),
        Form(
            key: formKeyCrearCuenta,
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
                              validator: (value) =>
                                  EmailValidator.validate(value!)
                                      ? null
                                      : "Introduce un email válido",
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
                //repite pasword ------------------------------------------------
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
                        controller: ctlTextPassword2,
                        decoration: InputDecoration(
                            prefixIcon: IconTheme(
                              data:
                                  IconThemeData(color: Colors.deepPurple[200]),
                              child: const Icon(Icons.password),
                            ),
                            border: InputBorder.none,
                            hintText: 'Repite contraseña'),
                        onSaved: (input) => password = input,
                        validator: (input) {
                          return input!.isEmpty ||
                                  ctlTextPassword1.text != ctlTextPassword2.text
                              ? "Las contraseñas deben coincidir"
                              : null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const SizedBox(height: 10),
                //BOTON CREAR CUENTA ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: () async {
                      // ? INICIO DE SESION , DESCARGA DATOS DE FIREBASE
                    
                      final form = formKeyCrearCuenta.currentState;
                      form!.save();

                      if (form.validate()) {
                        debugPrint('FORMULARIO CREACION CUENTA VALIDO');

                        // CREA EN FIREBASE UNA CUENTA NUEVA
                        final res = await validateRegisterInput(
                            context, email, password);

                        if (res) {
                          // EL RESULTADO DE CREACION DE CUENTA ES CORRECTA
                          debugPrint('CREANDO NUEVA CUENTA');
                          await PagoProvider()
                              .guardaPagado(false, email.toString());
                          configuracionInfoPagoRespaldo(email);

                          _irPaginaInicio();
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
                        'CREAR CUENTA',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                    ),
                  ),
                ),
              ],
            )),

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
                    'https://pages.flycricket.io/agenda-de-citas/privacy.html';
                // ignore: deprecated_member_use
                if (await canLaunch(url)) {
                  // ignore: deprecated_member_use
                  await launch(url);
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

//METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  configuracionInfoPagoRespaldo(email) async {

    try {
      
      //GUARDA PAGO EN DISPOSITIVO
      await PagoProvider().guardaPagado(true, email);

     

      // RESPALDO DATOS EN FIREBASE
      await SincronizarFirebase().sincronizaSubeFB(email);
     
    } catch (e) {
      debugPrint(e.toString());
    }
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
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Prueba durante ',
                  style: TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                ),
                TextSpan(
                  text: '$diasDePrueba días',
                  style: const TextStyle(
                      color: Color.fromARGB(255, 41, 22, 151),
                      fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ', todas las opciones y funcionalidades sin compromiso, sólo necesitas un email y una contraseña, puedes cancelar o suscribirte en cualquier momento. ',
                  style: TextStyle(color: Color.fromARGB(255, 106, 105, 109)),
                )
              ]),
        ));
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





