import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySwitch extends StatelessWidget {
  final bool private;
  final Function(bool) onChanged;
  final String label;

  const MySwitch({
    super.key,
    required this.private,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 55,
      child: InputDecorator(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface,
              //color: Theme.of(context).colorScheme.tertiary,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(18),
          ),
          //fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
      
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      
        child: CupertinoSwitch(value: private, onChanged: onChanged),
      ),
    );
  }
}
