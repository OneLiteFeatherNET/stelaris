import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/util/minecraft/enchantment.dart';

class EnchantmentItem extends StatefulWidget {
  const EnchantmentItem({
    required this.enchantment,
    required this.level,
    required this.isDeleteMode,
    required this.onLevelChanged,
    required this.onDelete,
    super.key,
  });

  final Enchantment enchantment;
  final int level;
  final bool isDeleteMode;
  final ValueChanged<int> onLevelChanged;
  final VoidCallback onDelete;

  @override
  State<EnchantmentItem> createState() => _EnchantmentItemState();
}

class _EnchantmentItemState extends State<EnchantmentItem> {
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(text: widget.level.toString());
  }

  @override
  void didUpdateWidget(EnchantmentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _levelController.text = widget.level.toString();
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            widget.enchantment.display,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: widget.isDeleteMode
              ? null
              : Row(
                  children: [
                    const Text('Level: '),
                    SizedBox(
                      width: 64,
                      child: TextField(
                        controller: _levelController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LimitRangeTextInputFormatter(
                              1, widget.enchantment.maxLevel),
                        ],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          final newLevel = int.tryParse(value) ?? 1;
                          if (newLevel != widget.level) {
                            widget.onLevelChanged(newLevel);
                          }
                        },
                      ),
                    ),
                    Text(
                      ' / ${widget.enchantment.maxLevel}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
          trailing: widget.isDeleteMode
              ? IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                )
              : Text(
                  widget.enchantment.minecraftValue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.secondary,
                  ),
                ),
        ),
      ),
    );
  }
}

// Input formatter to limit the value range
class LimitRangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  LimitRangeTextInputFormatter(this.min, this.max);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int? value = int.tryParse(newValue.text);

    if (value == null) {
      return oldValue;
    }

    if (value < min) {
      return TextEditingValue(
        text: min.toString(),
        selection: TextSelection.collapsed(offset: min.toString().length),
      );
    }

    if (value > max) {
      return TextEditingValue(
        text: max.toString(),
        selection: TextSelection.collapsed(offset: max.toString().length),
      );
    }

    return newValue;
  }
}
