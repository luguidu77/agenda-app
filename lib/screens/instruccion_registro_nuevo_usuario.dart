import 'package:agendacitas/widgets/formulariosSessionApp/registro_usuario_screen.dart';
import 'package:flutter/material.dart';

class InstruccionRegistroNuevoUsuario extends StatelessWidget {
  const InstruccionRegistroNuevoUsuario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const ListTile(
                leading: Text('1º'),
                title: Text(
                    'Revisa tu email, incluido el buzón no deseado en el cual recibirás las instrucciones para actualizar tu contraseña de usuario'),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegistroUsuarioScreen(
                              registroLogin: 'Registro2', usuarioAPP: '',
                            ))),
                child: const ListTile(
                  leading: Text('2º'),
                  title: Text(
                      'Ve al formulario de registro con tus credenciales 😁'),
                  trailing: Icon(Icons.navigate_next),
                ),
              )
            ],
          ),
        ));
  }
}
