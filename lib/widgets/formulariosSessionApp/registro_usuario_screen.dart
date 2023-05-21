
import 'package:agendacitas/screens/inicio_config_app.dart';
import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/olvido_password.dart';
import 'package:flutter/material.dart';
import 'package:agendacitas/providers/Firebase/sincronizar_firebase.dart';
import 'package:agendacitas/providers/pago_provider.dart';

import 'package:agendacitas/widgets/formulariosSessionApp/validaciones_form_inicio_session_registro.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool loading = false;

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
          widget.usuarioAPP != ''
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
                      setState(() {
                        loading = true;
                      });
                      final form = formKeyInicioSesion.currentState;
                      form!.save();

                      if (form.validate()) {
                        debugPrint('FORMULARIO LOGIN VALIDO');
                        final res =
                            await validateLoginInput(context, email, password);

                        if (res) {
                          debugPrint('SESION INICIADA');
                          /* await Future.delayed(
                                      const Duration(seconds: 3)); */
                          await PagoProvider()
                              .guardaPagado(true, email.toString());

                          _irPaginaInicio();
                          //Restart.restartApp();
                        }
                        setState(() {
                          loading = false;
                        });
                      } else {
                        mensajeError(context, 'FORMULARIO NO VALIDO');
                        setState(() {
                          loading = false;
                        });
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
        // no tienes cuenta? , registrate ahora
        /*   Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text(
                      'No tienes cuenta?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        mensajeInfo(context, 'texto');
                      },
                      child: const Text(
                        'Registrate ahora',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ), */

        //sign in button
      ],
    );
  }

  formCrearCuenta() {
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
          'Hola!, nuev@ por aquí?',
          style: GoogleFonts.bebasNeue(fontSize: 40),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Necesitamos un email y una contraseña',
            style: TextStyle(fontSize: 14),
          ),
        ),

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
                      setState(() {
                        loading = true;
                      });
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
                              .guardaPagado(true, email.toString());
                          configuracionInfoPagoRespaldo(email);
                          _irPaginaInicio();
                          /*  /* await Future.delayed(
                                      const Duration(seconds: 3)); */
                          await PagoProvider()
                              .guardaPagado(true, email.toString());

                          _irPaginaInicio();
                          //Restart.restartApp(); */
                        }
                        setState(() {
                          loading = false;
                        });
                      } else {
                        mensajeError(context, 'FORMULARIO NO VALIDO');
                        setState(() {
                          loading = false;
                        });
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
        // no tienes cuenta? , registrate ahora
        /*   Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Text(
                      'No tienes cuenta?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        mensajeInfo(context, 'texto');
                      },
                      child: const Text(
                        'Registrate ahora',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ), */

        //sign in button
      ],
    );
  }

//METODO PARA GUARDADO DE PAGO Y RESPALDO EN FIREBASE Y PRESENTAR INFORMACION AL USUARIO EN PANTALLA
  configuracionInfoPagoRespaldo(email) async {
    visibleFormulario = false;
    visibleIndicator = true;
    visiblePagoRealizado = true;
    try {
      setState(() {});
      //GUARDA PAGO EN DISPOSITIVO
      await PagoProvider().guardaPagado(true, email);

      visibleGuardarPagoRealizado = true;

      // RESPALDO DATOS EN FIREBASE
      await SincronizarFirebase().sincronizaSubeFB(email);
      setState(() {});
      visibleRespaldoRealizado = true;
      configuracionFinalizada = true;
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

_cabeceraPagina(txtregistroLogin) {
  switch (txtregistroLogin) {
    case 'Registro':
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                './assets/images/cheque.png',
                width: 30,
              ),
              const Text('Pago realizado con éxito')
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Image.asset(
                './assets/icon/acceso.png',
                width: 30,
              ),
              const Text('Vincula tu cuenta con la nube*:'),
            ],
          ),
          const Text(
              '* Los datos registrados en esta aplicación serán subidos a Cloud Firestore de Google, que podrás solicitar su eliminación cuando lo consideres oportuno escribiendo a agendadecitaspro@gmail.com. En ningún caso, el administrador de esta aplicación utilizará dichos datos fuera de este ámbito ni los cederá a terceros.',
              style: TextStyle(fontSize: 10)),
        ],
      );

    case 'Registro2':
      return const Text(
        'VINCULA LA CUENTA CON TU USUARIO FACILITADO',
      );

    case 'Login':
      return const Text('INICIA SESION');

    default:
  }
}

_piePagina(context, txtregistroLogin) {
  return (txtregistroLogin == 'Registro2')
      ? Container()
      : Padding(
          padding: const EdgeInsets.all(18.0),
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, 'InstruccionRegistroNuevoUsuario'),
            child: const ListTile(
                trailing: Icon(Icons.navigate_next),
                title: Text(
                  'Si compraste la app con la segunda opción, sigue las instruciones',
                  style: TextStyle(fontSize: 14),
                )),
          ),
        );
}

/* appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text('Versión PRO'),
      ),
      body: Column(children: [
        const SizedBox(height: 50),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: _cabeceraPagina(txtregistroLogin)),
        Image.asset(
          './assets/icon/acceso.png',
          height: 120,
        ),
        visibleFormulario
            ? Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: <Widget>[
                    CustomTextField(
                      //   textControllerEmail: textControllerEmail,
                      onSaved: (input) => email = input
                      //    _email = textControllerEmail.text;

                      ,
                      validator: (value) => EmailValidator.validate(value!)
                          ? null
                          : "Introduce un email válido",
                      icon: const Icon(Icons.email),
                      hint: "EMAIL",
                    ),
                    CustomTextField(
                      //     textControllerEmail: textControllerEmail,
                      icon: const Icon(Icons.lock),
                      //  obsecure: true,
                      onSaved: (input) => password = input,
                      validator: (input) => input!.isEmpty || input.length < 6
                          ? "6 caracteres como minimo"
                          : null,
                      hint: "CONTRASEÑA",
                    ),

                    // EL BOTON DE CONFIRMAR FORMULARIO EJECUTA LA FUNCION DEPENDIENDO DE txtregistroLogin
                    // REGISTRO (_validateRegisterInput)
                    // LOGIN (_validateLoginInput).

                    filledButton(txtregistroLogin, Colors.white, Colors.blue,
                        Colors.blue, Colors.white, (() async {
                      switch (txtregistroLogin) {
                        case 'Registro':
                          // ? LOS NUEVOS USUARIOS PAGO 1ª OPCION , SUBIR DATOS A FIREBASE Y REALIZAR REGISTRO
                          final res = await validateRegisterInput(
                              context, formKey, email, password);
                          if (res) {
                            debugPrint(
                                'EL FORMULARIO PAGO 1ª OPCION ES VALIDO, REALIZA ACCIONES');
                            configuracionInfoPagoRespaldo(email);
                          }
                          setState(() {
                            _loading = false;
                          });
                          break;
                        case 'Registro2':
                          // ? LOS NUEVOS USUARIOS PAGO 2ª OPCION , SUBIR DATOS A FIREBASE SIN REALIZAR REGISTRO
                          final res = await validateRegisterInput2(
                              context, formKey, email, password);
                          if (res) {
                            debugPrint(
                                'EL FORMULARIO PAGO 2ª OPCION ES VALIDO, REALIZA ACCIONES');
                            configuracionInfoPagoRespaldo(email);
                          }
                          setState(() {
                            _loading = false;
                          });
                          break;
                        case 'Login':
                          // ? INICIO DE SESION , DESCARGA DATOS DE FIREBASE
                          setState(() {
                            _loading = true;
                          });
                          final form = formKey.currentState;
                          form!.save();

                          if (form.validate()) {
                            debugPrint('FORMULARIO LOGIN VALIDO');
                            final res = await validateLoginInput(
                                context, form, email, password);

                            print(res);
                            if (res) {
                              debugPrint('SESION INICIADA');
                              await Future.delayed(const Duration(seconds: 3));
                              await PagoProvider().guardaPagado(true, email!);

                              _irPaginaInicio();
                              //Restart.restartApp();
                            }
                            setState(() {
                              _loading = false;
                            });
                          } else {
                            mensajeError(context, 'FORMULARIO NO VALIDO');
                            setState(() {
                              _loading = false;
                            });
                          }

                          break;
                      }
                    }), _loading),
                    /*  (txtregistroLogin == 'Registro')
                            ? _validateRegisterInput
                            : _validateLoginInput,
                        _loading */
                    _piePagina(context, txtregistroLogin),
                    const SizedBox(height: 200)
                  ],
                ),
              )
            : Container(),
        //? INDICATOR ESPERA...
        //? pantalla informacion para el usuario de pago y respaldo realizado
        visibleIndicator
            ? Column(
                children: [
                  configuracionFinalizada
                      ? Container()
                      : LinearProgressIndicator(
                          value: valorindicator,
                          color: Colors.greenAccent,
                          backgroundColor: Colors.green,
                        ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        visiblePagoRealizado
                            ? const Icon(Icons.check)
                            : const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator()),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Pago app Pro')
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        visibleGuardarPagoRealizado
                            ? const Icon(Icons.check)
                            : const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator()),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Guardado de pago')
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        visibleRespaldoRealizado
                            ? const Icon(Icons.check)
                            : const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator()),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text('Respaldo en la nube')
                      ],
                    ),
                  ),
                  configuracionFinalizada
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: const Color.fromARGB(255, 172, 240, 174),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: const [
                                  Text('¡ Configuración realizada con exito !'),
                                  Text('Reinicia la App e inicia sesión')
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.red,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('NO CIERRE LA APLICACIÓN',
                                style: TextStyle(color: Colors.white)),
                          ))
                ],
              )
            : Container(),
      ]), */
