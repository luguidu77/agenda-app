import 'package:agendacitas/models/cita_model.dart';
import 'package:agendacitas/providers/citas_provider.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final CitaModelFirebase reserva;
  final String emailUsuario;
  final CitasProvider contextoCitaProvider;

  const ActionButtons({
    required this.reserva,
    required this.emailUsuario,
    required this.contextoCitaProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildShareButton(),
          const SizedBox(width: 10),
          _buildReassignButton(),
          const SizedBox(width: 10),
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    // Implementar lógica de compartir
    return const Icon(Icons.share, color: Colors.white);
  }

  Widget _buildReassignButton() {
    // Implementar lógica de reasignación
    return const Icon(Icons.swap_horiz, color: Colors.white);
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () => _confirmDelete(context),
    );
  }

  void _confirmDelete(BuildContext context) {
    // Implementar lógica de eliminación
  }
}
