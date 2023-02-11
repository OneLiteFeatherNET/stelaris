import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/typedefs.dart';

class LevelEditDialog extends StatelessWidget {

  final String? currentValue;
  final ValueUpdate<String> newLevel;

  final TextEditingController _controller = TextEditingController();

  LevelEditDialog({Key? key, required this.currentValue, required this.newLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.text = currentValue ?? empty;
    return SimpleDialog(
      title: Text(context.l10n.dialog_level_title, textAlign: TextAlign.center,),
      contentPadding: dialogPadding,
      children: [
        spaceTenBox,
        TextFormField(
          controller: _controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: [FilteringTextInputFormatter.allow(numberPattern)],
          validator: ((value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.dialog_level_validation;
            }
            return null;
          }),
        ),
        spaceTwentyFiveHeightBox,
        TextButton(
            onPressed: () {
              newLevel.call(_controller.text);
              context.pop();
            },
            child: Text(context.l10n.button_save)
        )
      ],
    );
  }
}
