import 'package:agendacitas/mylogic_formularios/my_logic_planAmigo.dart';
import 'package:agendacitas/providers/Firebase/firebase_plan_amigo.dart';
import 'package:agendacitas/utils/comprueba_pago.dart';

import 'package:agendacitas/screens/plan_amigo/plan_amigo.dart';
import 'package:agendacitas/widgets/botones/floating_action_buton_widget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class PlanAmigoVinculaCuenta extends StatefulWidget {
  const PlanAmigoVinculaCuenta({Key? key}) : super(key: key);

  @override
  State<PlanAmigoVinculaCuenta> createState() => _PlanAmigoVinculaCuentaState();
}

class _PlanAmigoVinculaCuentaState extends State<PlanAmigoVinculaCuenta> {
  final _formKey = GlobalKey<FormState>();
  TextStyle estilotextoErrorValidacion = const TextStyle(color: Colors.red);
  String textoErrorValidacionFecha = '';
  String textoErrorValidacionHora = '';
  String textoErrorValidacionAsunto = '';
  String alertaHora = '';
  late MyLogicNoPlanAmigo myLogic;
  String tuEmail = '';
  String amigoEmail = '';

  @override
  void initState() {
    myLogic = MyLogicNoPlanAmigo(tuEmail, amigoEmail);
    myLogic.init();

    traeTuEmail();
    super.initState();
  }

  traeTuEmail() async {
    final pago = await CompruebaPago().compruebaPago();

    setState(() {
      tuEmail = pago['email'];
    });
    debugPrint(
        'datos gardados en tabla Pago (PlanAmigoVinculaCuenta.dart) $pago');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //todo : traer desde firebase respuesta VINCULADOS CON EXITO, para salir de esta pagina
      floatingActionButton: FloatingActionButonWidget(
          icono: const Icon(Icons.check),
          texto: 'ENVIAR AMIGO',
          funcion: () async {
            if (_formKey.currentState!.validate()) {
              //SI EL FORMULARIO ES VALIDO
              debugPrint('formulario valido');
              agregarAmigo(tuEmail, myLogic.textControlleramigoEmail.text);

              // mensaje(context);
            } else {
              debugPrint('formulario NO valido');
            }
          }),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _botonCerrar(context),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('./assets/images/agregaAmigo.png'),
                    const SizedBox(
                      height: 20,
                    ),
                    //const Text('TU EMAIL DE USUARIO'),
                    _tuEmail(),
                    const SizedBox(height: 50),

                    //todo : hacerlo visible cuando se introduce por primera vez un email en TuEmail
                    //       si la app detecta que ya ha agregado un amigoEmai  , hacerlo no visible
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '¿Quién te recomendó la aplicación?',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    _amigoEmail(),

                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
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

  _tuEmail() {
    return Text(
      tuEmail,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  _amigoEmail() {
    return Column(
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
                  controller: myLogic.textControlleramigoEmail,
                  decoration: const InputDecoration(
                      labelText: 'email de usuario de tu amigo',
                      border:
                          UnderlineInputBorder(borderSide: BorderSide.none)),
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

  _validacion(value) {
    debugPrint(value.isEmpty.toString());
    if (value.isEmpty) {
      textoErrorValidacionAsunto = 'Este campo no puede quedar vacío';
      setState(() {});
      return 'Este campo no puede quedar vacío';
    } else {
      final bool isValid = EmailValidator.validate(value);
      setState(() {});
      return isValid
          ? (value.toString() == tuEmail)
              ? 'No pueden ser tu mismo usuario 🤥😡'
              : null
          : 'Debe ser un email';
    }
  }

  void agregarAmigo(String tuEmail, String amigoEmail) async {
    final res =
        await PlanAmigoFirebase().vinculaAmigos(context, tuEmail, amigoEmail);

    if (res) irPantallaPrincipal();
  }

  irPantallaPrincipal() {
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const PlanAmigo())));
  }
}
