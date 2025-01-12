import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMessage; // Mensaje opcional para describir el error

  const ErrorPage({Key? key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 100.0,
              ),
              const SizedBox(height: 16.0),
              Text(
                errorMessage ?? 'Ha ocurrido un error inesperado.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
