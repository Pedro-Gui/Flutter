import 'package:flutter/material.dart';

class SizeSpinner extends StatelessWidget {
  final int value;
  final int maxValue;
  final ValueChanged<int> onSubmitted;

  const SizeSpinner({
    super.key,
    required this.value,
    required this.maxValue,
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
            onPressed: () => onSubmitted(100),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted(value - 100),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(border: InputBorder.none),
              onEditingComplete: () => onSubmitted(int.tryParse(controller.text) ?? 100),
              onChanged: (val) => onSubmitted(int.tryParse(val) ?? 100),
              onSubmitted: (val) => onSubmitted(int.tryParse(val) ?? 100),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: theme.colorScheme.primary,
            onPressed: () => onSubmitted((value + 100)),
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
