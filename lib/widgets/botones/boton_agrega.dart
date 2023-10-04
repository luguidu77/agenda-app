import 'package:flutter/material.dart';

class BotonAgrega extends StatelessWidget {
  const BotonAgrega({super.key, required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
          radius: 15,
          // backgroundImage: NetworkImage(                      'https://firebasestorage.googleapis.com/v0/b/flutter-varios-576e6.appspot.com/o/agendadecitas%2Fritagiove%40hotmail.com%2Fclientes%2F607545402%2Ffoto?alt=media&token=af2065c0-861d-4a3a-b0bc-a690a7ba063e'),
          child: const Icon(
            Icons.add, // Icono de suma
            size: 25, // Tamaño del icono
            color: Colors.white, // Color del icono
          ),
        ),
        const SizedBox(width: 10),
        Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          texto,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
      ],
    );
  }
}
