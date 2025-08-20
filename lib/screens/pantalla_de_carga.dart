import 'package:flutter/material.dart';

class PantallaDeCarga extends StatelessWidget {
  const PantallaDeCarga({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
