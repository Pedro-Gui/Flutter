import 'package:flutter/material.dart';

class SizeSpinner extends StatelessWidget {
  final int value;
  final int maxValue;
  final int step;
  final ValueChanged<int> onSubmitted;

  const SizeSpinner({
    super.key,
    required this.value,
    required this.maxValue,
    this.step = 100,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: value.toString());

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted(step),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted(value - step),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(border: InputBorder.none),
              onEditingComplete: () => onSubmitted(int.tryParse(controller.text) ?? step),
              onChanged: (val) => onSubmitted(int.tryParse(val) ?? step),
              onSubmitted: (val) => onSubmitted(int.tryParse(val) ?? step),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted((value + step)),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_up_rounded),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted(maxValue),
          ),
        ],
      ),
    );
  }
}
