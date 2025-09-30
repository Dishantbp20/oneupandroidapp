import 'package:flutter/material.dart';

import '../utils/colors.dart';

late final String pHint;
class CustomPasswordField extends StatefulWidget {
  final String hint;
  final TextEditingController textEditingController;
  final  String? Function(String?)? onValidation;
  const CustomPasswordField({super.key, required this.hint, required this.textEditingController,  this.onValidation});
  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
        obscureText: _obscure,
        style: TextStyle(fontSize: 14),
        controller: widget.textEditingController,
        validator: widget.onValidation,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
              color: AppColors.lightGrey.withAlpha(80),
              fontSize: 14
          ),
          prefixIcon: Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.lightGrey.withAlpha(50),),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
