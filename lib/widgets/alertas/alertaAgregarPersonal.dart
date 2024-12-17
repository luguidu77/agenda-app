import 'package:flutter/material.dart';

class Alertas {
  static Widget agregarEmpleadoAlerta(context, {bool enableOnTap = true}) {
    return InkWell(
      onTap: () =>
          enableOnTap ? Navigator.pushNamed(context, 'empleadosScreen') : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12), // Espaciado interno
        margin: const EdgeInsets.all(16), // Margen alrededor
        decoration: BoxDecoration(
          color: Colors.orange, // Color de fondo llamativo
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Sombra ligera
              blurRadius: 4, // Difusión de la sombra
              offset: const Offset(0, 2), // Desplazamiento de la sombra
            ),
          ],
        ),
        child: const Row(
          spacing: 12,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white, // Ícono en blanco
              size: 20,
            ),
            Expanded(
              child: Text(
                'Debe haber al menos, un empleado con rol "personal" para asignarle citas',
                style: TextStyle(
                  fontSize:
                      14, // Texto más grande que el original para mejor legibilidad
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Texto en blanco
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
