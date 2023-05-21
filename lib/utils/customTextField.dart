import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  // final TextEditingController textControllerEmail;

  const CustomTextField({Key? key, 
    required this.icon,
    required this.hint,
    this.obsecure = false,
    required this.validator,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          onSaved: onSaved,
          validator: validator,
          autofocus: true,
          obscureText: obsecure,
          style: const TextStyle(
            fontSize: 14,
          ),
          decoration: InputDecoration(
              hintStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 30, right: 10),
                child: IconTheme(
                  data: IconThemeData(color: Theme.of(context).primaryColor),
                  child: icon,
                ),
              )),
        ),
      ),
    );
  }
}
