import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/state/actions/item/item_enchantment_actions.dart';
import 'package:stelaris/feature/base/action/entry_actions.dart';
import 'package:stelaris/feature/dialogs/delete_dialog.dart';
import 'package:stelaris/feature/dialogs/entry_update_dialog.dart';
import 'package:stelaris/util/functions.dart';
import 'package:vulpes_data/api/enchantment.dart';

class EnchantmentItem extends StatefulWidget {
  const EnchantmentItem({
    required this.dto,
    required this.enchantment,
    super.key,
  });

  final ItemEnchantmentDto dto;
  final Enchantment enchantment;

  @override
  State<EnchantmentItem> createState() => _EnchantmentItemState();
}

class _EnchantmentItemState extends State<EnchantmentItem> {
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(text: widget.dto.level.toString());
  }

  @override
  void didUpdateWidget(EnchantmentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dto.level != widget.dto.level) {
      _levelController.text = widget.dto.level.toString();
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            widget.enchantment.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              const Text('Level: '),
              Text(widget.dto.level.toString()),
              Text(
                ' / ${widget.enchantment.maxLevel}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          trailing: EntryActions(
            onEdit: () {},
            onDelete: () => _showDeleteDialog(widget.dto),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(ItemEnchantmentDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDialog<ItemEnchantmentDto>(
          title: const Text('Delete enchantment', textAlign: TextAlign.center),
          header: [
            const TextSpan(
              text: 'Are you sure you want to delete this enchantment?',
            ),
          ],
          value: dto,
          successfully: (value) {
            context.dispatch(ItemEnchantmentDeleteAction(value));
            return true;
          },
        );
      },
    );
  }

  void _showDialog(ItemEnchantmentDto dto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryUpdateDialog(
          title: 'Edit enchantment',
          formKey: GlobalKey<FormState>(),
          valueUpdate: (value) {
            final updatedDto = dto.copyWith(level: int.parse(value));
            //context.dispatch(ItemEnchantmentUpdateAction(updatedDto));
            Navigator.pop(context, false);
          },
          formFieldValidator: (value) {
            final String input = value as String;
            return checkIfEmptyAndReturnErrorString(input, context);
          },
          data: dto.level.toString(),
        );
      },
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
