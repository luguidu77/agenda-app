import 'package:flutter/material.dart';

class PaginaNotificacionesScreen extends StatefulWidget {
  const PaginaNotificacionesScreen({super.key});

  @override
  State<PaginaNotificacionesScreen> createState() =>
      _PaginaNotificacionesScreenState();
}

class _PaginaNotificacionesScreenState
    extends State<PaginaNotificacionesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
    );
  }
}
