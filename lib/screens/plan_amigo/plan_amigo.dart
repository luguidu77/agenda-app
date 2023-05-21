


import 'package:agendacitas/providers/plan_amigo_provider.dart';
import 'package:agendacitas/utils/publicidad.dart';
import 'package:agendacitas/widgets/botones/floating_action_buton_widget.dart';
import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../providers/providers.dart';

class PlanAmigo extends StatefulWidget {
  const PlanAmigo({Key? key}) : super(key: key);

  @override
  State<PlanAmigo> createState() => _PlanAmigoState();
}

class _PlanAmigoState extends State<PlanAmigo> {
  final _formKey = GlobalKey<FormState>();
  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);
  String textoErrorValidacionFecha = '';
  String textoErrorValidacionHora = '';
  String textoErrorValidacionAsunto = '';
  String alertaHora = '';
  late MyLogicNoPlanAmigo myLogic;
  String tuEmail = '';
  String amigoEmail = '';
  bool visibleBotonAmigo = false;
  bool hayUnAmigoViculado = false;
  int numAmigos = 0;
  bool cargando = true;
  String identificacionTerminal = '';

  @override
  void initState() {
    Publicidad().publicidad();
    myLogic = MyLogicNoPlanAmigo(tuEmail, amigoEmail);
    myLogic.init();
    traeTuEmail();
    verificaIdentificacion();

    super.initState();
  }

  verificaIdentificacion() async {
    debugPrint('IDENTIFICANDO DISPOSITIVO FISICO');
  }

  traeTuEmail() async {
    //traigo el email de usuario (tuEmail) registrado en el dispositivo

    final planAmigo = await PlanAmigoProvider().cargarPlanAmigo();
    tuEmail = planAmigo['email'];
    myLogic.textControllertuEmail.text = tuEmail;
    if (tuEmail != '') visibleBotonAmigo = true;

    // compruebo si tiene primer amigo ,si verdadero: no visible boton para añadir ni el de modificar
    //  y  ver numero de amigos
    if (tuEmail != '') {
      final amigos = await compruebaSiTieneAmigo(tuEmail);
      debugPrint(amigos.toString());
      if (amigos['primerAmigo']) {
        hayUnAmigoViculado = true;
      }
      numAmigos = amigos['numAmigos'];
    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !hayUnAmigoViculado && !visibleBotonAmigo
          ? FloatingActionButonWidget(
              icono: const Icon(Icons.forward),
              texto: 'REGISTRA EMAIL AMIGO',
              funcion: () async {
                if (_formKey.currentState!.validate()) {
                  //SI EL FORMULARIO ES VALIDO
                  debugPrint('formulario valido');
                  //REGISTRAMOS EL EMAIL EN FIREBASE
                  registrarTuEmail(
                    myLogic.textControllertuEmail.text,
                  );

                  // REGISTRAMOS EL EMAIL EN DISPOSITIVO
                  //todo: esto da error posteriormente: si guardo email en dispositivo, al reiniciar se irá a la pantalla 2 login y la aplicacion fallara ya que intentara leer de firebase con el email que no existe en firestore.
                  //? quizas deberia guardar el email en otro provider para rescatarlo al reiniciar app y que conste en plan amigo
                  await PlanAmigoProvider()
                      .guardaEmailPlanAmigo(myLogic.textControllertuEmail.text);

                  setState(() {
                    visibleBotonAmigo = true;
                  });
                } else {
                  debugPrint('formulario NO valido');
                }
              })
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _botonCerrar(context),
              const Text(
                'PLAN AMIGO',
                style: TextStyle(fontSize: 28),
              ),
              hayUnAmigoViculado
                  ? _amigosVinculados()
                  : cargando
                      ? const CircularProgressIndicator()
                      : _formRegistroTuEmail(),
            ],
          ),
        ),
      ),
    );
  }

  Form _formRegistroTuEmail() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  ' Con plan amigo puedes disfrutar de todas las opciones de la aplicación de manera gratuita y sin anuncios.',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  ' Necesitarás tener 5 amig@s vinculados con la aplicación instalada.',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Image.asset('./assets/images/amigos2.png'),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '1º Registra tu email, el cual será tu futuro usuario con el que iniciarás sesión en la aplicación.',
              style: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          _tuEmail(),
          const SizedBox(height: 5),
          //visible cuando se introduce por primera vez un email en TuEmail
          //       si la app detecta que ya ha agregado un amigoEmail  , hacerlo no visible

          if (visibleBotonAmigo) _amigoEmail(),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  _botonCerrar(context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 50,
          ),
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
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

  _tuEmail() {
    return visibleBotonAmigo
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                myLogic.textControllertuEmail.text,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          )
        : Column(
            children: [
              Container(
                width: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.blue)),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: TextFormField(
                        validator: (value) => _validacion(value),
                        keyboardType: TextInputType.emailAddress,
                        enabled: true,
                        controller: myLogic.textControllertuEmail,
                        decoration: const InputDecoration(
                            labelText: 'email que será tu usuario',
                            border: UnderlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                    ),
                    TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.email),
                        label: const Text(''))
                  ],
                ),
              ),
              //? hago esta validación porque no se ve TEXTO VALIDATOR si está inabilitado a la escritura
              Text(
                textoErrorValidacionHora,
                style: estilotextoErrorValidacion,
              )
            ],
          );
  }

  _amigoEmail() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '2º Añade el email del amig@ que te recomendó la aplicación. YA TIENES UN AMIGO, BIEN !! 😁',
            style: TextStyle(fontSize: 15),
          ),
        ),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () =>
                Navigator.pushNamed(context, 'PlanAmigoVinculaCuenta'),
            icon: const Icon(Icons.person_add),
            label: const Text('Email de tu amigo')),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '3º Ya estas activ@ en plan amigo para recomendar la aplicación en redes sociales, o como prefieras, dejando tu email para que ellos te vinculen como amig@. AMBOS SUMAIS UN AMIG@, BIEEEEEEN !! 🎁 ',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }

  _validacion(value) {
    debugPrint(value.isEmpty.toString());
    if (value.isEmpty) {
      textoErrorValidacionAsunto = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      final bool isValid = EmailValidator.validate(value);
      setState(() {});
      return isValid ? null : 'Debe ser un email';
    }
  }

  void registrarTuEmail(String tuEmail) async {
    final bool res = await PlanAmigoFirebase().crearUsuario(context, tuEmail);
    // si res es true, actulizar pagina comprobando si tiene primerAmigo registrado

    if (res) {
      myLogic.textControllertuEmail.text = tuEmail;
      initState();
    }
  }

  Future<Map<String, dynamic>> compruebaSiTieneAmigo(String tuEmail) async {
    return await PlanAmigoFirebase().compruebaSiTienePrimerAmigo(tuEmail);
  }

  _amigosVinculados() {
    int metaNumAmigos = 5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image.asset('./assets/images/amigos.png'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tuEmail.toString(),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: numAmigos >= metaNumAmigos
              ? Image.asset(
                  './assets/icon/enhorabuena.png',
                  width: 50,
                )
              : Text(
                  'Tienes ${numAmigos.toString()} de $metaNumAmigos amigos vinculados para disponer de tu cuenta gratuita',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
        ),
        numAmigos >= metaNumAmigos
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    './assets/icon/desbloquear.png',
                    width: 30,
                  ),
                  TextButton(
                      onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegistroUsuarioScreen(
                                          registroLogin: 'Registro',
                                          usuarioAPP: '',
                                        )))
                          },
                      child: const Text(
                        'REGISTRO ',
                        style: TextStyle(fontSize: 20),
                      )),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    './assets/icon/cerrar-con-llave.png',
                    width: 30,
                  ),
                  TextButton(
                      onPressed: () => {
                            PlanAmigoFirebase().mensajeNoMetaNumeroAmigo(
                                context, metaNumAmigos)
                          },
                      child: const Text(
                        'REGISTRO ',
                        style: TextStyle(fontSize: 20),
                      )),
                ],
              )
      ],
    );
  }
}
