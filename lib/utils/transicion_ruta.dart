import 'package:flutter/material.dart';



class StepsCitaTransition extends PageRouteBuilder {
  final Widget page;
  StepsCitaTransition({required this.page})
      : super(
            // transitionDuration: const Duration(milliseconds: 1000),
            pageBuilder: (context, animation1, animation2) => page,
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            });
}
