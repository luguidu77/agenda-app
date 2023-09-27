import 'package:flutter/material.dart';

import '../providers/personaliza_provider.dart';

Future tarjetaModificarMsm(context, contextoPersonalizaFirebase, emailUsuario,
    textoActual, String valor) {
  TextEditingController ctrl_1 = TextEditingController();
  final formKey = GlobalKey<FormState>();
  // rescat el texto par enviar a los clientes desde firebase

  final personalizaprovider = contextoPersonalizaFirebase.getPersonaliza;
  textoActual = personalizaprovider['MENSAJE_CITA'].toString();
  late String textoInput, hintText, simbolo;
  late TextInputType textInputType;
  // late Function modificaDato;

  switch (valor) {
    case 'texto':
      textoInput = 'Mensaje: ';
      hintText = 'Texto de confirmación de cita para enviar a tus clientes';
      simbolo = '';
      textInputType = TextInputType.text;
      ctrl_1.text = textoActual.toString();
      //  modificaDato = () => personaliza.mensaje = int.parse(ctrl_1.text);
      break;
    // dejo abierto a la posibilidad de cambiar mas opciones de la aplicacion
    case 'otra':
      textoInput = 'otra: ';
      hintText = '';
      simbolo = '';
      textInputType = TextInputType.text;

      //  modificaDato = () => personaliza.moneda = ctrl_1.text;
      break;
    default:
  }

  return showModalBottomSheet(
    isDismissible: false,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () async => {
                            if (formKey.currentState!.validate())
                              {
                                contextoPersonalizaFirebase.setPersonaliza = {
                                  'MENSAJE_CITA': ctrl_1.text,
                                },
                                // modificaDato(),
                                await PersonalizaProviderFirebase()
                                    .actualizarPersonaliza(
                                        emailUsuario, ctrl_1.text),
                                Navigator.pop(context)
                              },
                          },
                      icon: const Icon(Icons.check),
                      label: const Text('Validar')),
                  ElevatedButton.icon(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                      onPressed: () async => {
                            if (formKey.currentState!.validate())
                              {Navigator.pop(context)},
                          },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton.icon(
                  onPressed: () => instrucciones(context),
                  icon: const Icon(Icons.info),
                  label: const Text('Instrucciones')),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(textoInput),
                  const SizedBox(width: 10),
                  Text(simbolo),
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        // The validator receives the text that the user has entered.
                        maxLines: 15,
                        controller: ctrl_1,
                        decoration: InputDecoration(hintText: hintText),
                        keyboardType: textInputType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No puede estar vacío';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );
    },
  );
}

instrucciones(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
            //  key: key ?? Key('picker-dialog'),
            title: Text('Instrucciones'),

            ///  backgroundColor: backgroundColor,
            // actions: actions,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'El texto puede ir interpolado por las variables relacionadas a continuación según convenga:\n\n',
                      style: TextStyle(fontSize: 14)),
                  Text(
                    'Palabras claves:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Nombre del cliente: \$cliente \n'
                    'Fecha de la cita: \$fecha \n'
                    'Servicio a realizar: \$servicio \n'
                    'Denominación de tu negocio: \$denominacion \n'
                    'Teléfono de tu negocio: \$telefono \n'
                    'Facebook de tu negocio: \$facebook \n'
                    'Instagram de tu negocio: \$instagram \n'
                    'Web de tu negocio: \$web \n'
                    'Ubicación de tu negocio: \$ubicacion \n'
                    'Nombre del cliente: \$cliente \n',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Para agregar saltos de líneas escribe el signo: %',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ));
      });
}
