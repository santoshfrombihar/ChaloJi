import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator; // ✅ proper type + optional

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator, // optional — purane screens break nahi honge
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField( // ✅ TextField → TextFormField
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator, // ✅ connected
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B)),
      ),
    );
  }
}