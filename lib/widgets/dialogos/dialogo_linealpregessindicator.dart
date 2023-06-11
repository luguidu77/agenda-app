import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

Future<void> dialogoLinealProgressIndicator(context, String texto) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(texto),
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
              const MyAnimatedWidget()
            ],
          ),
        ),
      );
    },
  );
}

class MyAnimatedWidget extends StatelessWidget {
  const MyAnimatedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 80,
        height: 80,
        child: RiveAnimation.asset(
          'assets/icon/splash.riv',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
