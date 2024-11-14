import 'package:flutter/material.dart';

class NoNotificationsContainer extends StatelessWidget {
  const NoNotificationsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0), // Margen horizontal
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.grey[300]!, width: 1), // Borde gris tenue
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 50, child: Image.asset('assets/images/caja-vacia.png')),
            const SizedBox(height: 16),
            const Text(
              "No hay notificaciones",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
