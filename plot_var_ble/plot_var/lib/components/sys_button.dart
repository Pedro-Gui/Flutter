import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const MyButton({
    super.key, 
    required this.onTap, 
    required this.text,
    this.color,
    this.textColor,
    this.icon
    });

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? Theme.of(context).colorScheme.onSurface;
    final finalTextColor = textColor ?? Theme.of(context).colorScheme.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Row(
            children: [
              icon == null ? const SizedBox.shrink() : 
              Icon(icon),
              Text(
                text,
                style: TextStyle(
                  color: finalTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
