import 'package:flutter/material.dart';

/// Um spinner que aceita `int` ou `double`.
class SysSpinner<T extends num> extends StatefulWidget {
  final T value;
  final T maxValue;
  final T step;
  final ValueChanged<T> onSubmitted;
  final String? title;
  
  /// 0 = Nenhum botão
  /// 1 = Apenas Remover (-) e Adicionar (+)
  /// 2 = Todos os botões (Início, -, +, Fim)
  final int showAllButton;

  const SysSpinner({
    super.key,
    required this.value,
    required this.maxValue,
    required this.step,
    required this.onSubmitted,
    this.title,
    this.showAllButton = 2,
  });

  @override
  State<SysSpinner<T>> createState() => _SysSpinnerState<T>();
}

class _SysSpinnerState<T extends num> extends State<SysSpinner<T>> {
  late T _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void didUpdateWidget(SysSpinner<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
      _controller.text = _value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  T? _parseValue(String text) {
    if (T == int) return int.tryParse(text) as T?;
    if (T == double) return double.tryParse(text) as T?;
    return num.tryParse(text) as T?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget spinnerBody = Container(
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
          if (widget.showAllButton == 2)
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_down_rounded),
              color: theme.colorScheme.primary,
              onPressed: () => widget.onSubmitted(widget.step),
            ),
            
          // Botão: Subtrair Step
          if (widget.showAllButton >= 1)
            IconButton(
              icon: const Icon(Icons.remove),
              color: theme.colorScheme.primary,
              onPressed: () => widget.onSubmitted((_value - widget.step) as T),
            ),

          // Campo de Texto
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, textValue, _) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 60),
                child: IntrinsicWidth(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    // Habilita ponto/vírgula no teclado se o tipo genérico for double
                    keyboardType: TextInputType.numberWithOptions(decimal: T == double),
                    maxLines: 1,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      widget.onSubmitted(_parseValue(_controller.text) ?? widget.step);
                    },
                    onChanged: (val) {
                      final T? aux = _parseValue(val);
                      widget.onSubmitted(aux ?? widget.step);
                      setState(() {
                        _value = aux ?? _value;
                      });
                    },
                    onSubmitted: (val) => widget.onSubmitted(_parseValue(val) ?? widget.step),
                  ),
                ),
              );
            },
          ),

          // Botão: Adicionar Step
          if (widget.showAllButton >= 1)
            IconButton(
              icon: const Icon(Icons.add),
              color: theme.colorScheme.primary,
              onPressed: () => widget.onSubmitted((_value + widget.step) as T),
            ),
            
          // Botão: Ir para o Máximo
          if (widget.showAllButton == 2)
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_up_rounded),
              color: theme.colorScheme.primary,
              onPressed: () => widget.onSubmitted(widget.maxValue),
            ),
        ],
      ),
    );

    if (widget.title != null && widget.title!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
            child: Text(
              widget.title!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          spinnerBody,
        ],
      );
    }

    return spinnerBody;
  }
}