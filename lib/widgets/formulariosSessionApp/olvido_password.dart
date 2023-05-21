import 'package:agendacitas/utils/alertasSnackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future reseteoPassword() async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );
        // ignore: use_build_context_synchronously
        mensajeSuccess(context, 'Enviado correctamente!, revisa tu email');
      } on FirebaseAuthException catch (e) {
        debugPrint(e.toString());
        mensajeError(context, 'Algo falló');
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text(
                    'El email no existe como usuario, si crees que hay un error, contacta con el desarrollador de la aplicación'),
              );
            });
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Introduce tu email y te enviaremos un link para resetear tu contraseña',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const Text('(verifica también el corre no deseado)'),
          const SizedBox(height: 10),
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
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      prefixIcon: const IconTheme(
                        data: IconThemeData(color: Colors.deepPurple),
                        child: Icon(Icons.email),
                      ),
                      border: InputBorder.none,
                      hintText: 'Email',
                      fillColor: Colors.grey[200]),
                ),
              ),
            ),
          ),
          MaterialButton(
            color: Colors.deepPurple[200],
            onPressed: reseteoPassword,
            child: const Text('Resetea contraseña'),
          )
        ],
      ),
    );
  }
}
