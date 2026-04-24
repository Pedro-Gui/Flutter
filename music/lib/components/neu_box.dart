import 'package:flutter/material.dart';

class NeuBox extends StatelessWidget {
  final Widget? child;
  const NeuBox({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            offset: const Offset(4, 4), 
            blurRadius: 8,
            ),

            BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            offset: const Offset(-4, -4), 
            blurRadius: 8,
            ),
        ]
      ),
      child: child,
    );
  }
}