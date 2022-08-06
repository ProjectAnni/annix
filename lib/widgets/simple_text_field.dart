import 'package:flutter/material.dart';

class SimpleTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool password;

  const SimpleTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.password = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: TextField(
        obscureText: password,
        decoration: InputDecoration(
          labelText: label,
        ),
        controller: controller,
      ),
    );
  }
}
