import 'package:flutter/material.dart';

class MyLogicNoPlanAmigo {
  MyLogicNoPlanAmigo(this.tuEmail, this.amigoEmail);
  final String tuEmail;
  final String amigoEmail;

  final textControllertuEmail = TextEditingController();
  final textControlleramigoEmail = TextEditingController();

  void save() {}

  void init() {
    if (tuEmail == '') {
      textControllertuEmail.text = '';
      textControlleramigoEmail.text = '';
    } else {
      textControllertuEmail.text = tuEmail.toString();
      textControlleramigoEmail.text = amigoEmail.toString();
    }
  }
}
