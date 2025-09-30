import 'package:flutter/material.dart';
import 'package:one_up_app/utils/colors.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const StyledButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.getGradientColor(),begin:  Alignment.centerLeft, end:Alignment.centerRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,fontFamily: 'Lato',
            ),
          ),
        ),
      ),
    );
  }
}