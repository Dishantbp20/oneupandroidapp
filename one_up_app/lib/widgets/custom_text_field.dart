import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextInputType textInputType;
  final TextEditingController controller;
  final  String? Function(String?)? onValidation;
  final bool isReadOnly;

  const CustomTextField({super.key, required this.hint, required this.icon, required this.textInputType, required this.controller, required this.isReadOnly, this.onValidation});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        readOnly: isReadOnly,
        validator: onValidation,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.lightGrey.withAlpha(80),
              fontSize: 14
          ),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}