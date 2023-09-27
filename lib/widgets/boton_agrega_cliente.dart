import 'package:flutter/material.dart';

class BotonAgregaCliente extends StatelessWidget {
  const BotonAgregaCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          radius: 25,
          // backgroundImage: NetworkImage(                      'https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/agendadecitas%2Fritagiove%40hotmail.com%2Fclientes%2F607545402%2Ffoto?alt=media&token=af2065c0-861d-4a3a-b0bc-a690a7ba063e'),
          child: Icon(
            Icons.add, // Icono de suma
            size: 40, // Tamaño del icono
            color: Colors.white, // Color del icono
          ),
        ),
        Text(
          'Añade un nuevo cliente',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}
