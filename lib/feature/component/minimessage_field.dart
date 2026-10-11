import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/minimessage_parser.dart';

/// A component is a single line, any run of line breaks becomes a space.
final RegExp _lineBreaks = RegExp(r'[\r\n]+');

/// The tags Minecraft understands, small and pale next to the text.
const TextStyle _tagStyle = TextStyle(
  color: previewPlaceholderColor,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
  decoration: TextDecoration.none,
);

/// Tags Minecraft prints as text, e.g. a typo or a gradient without colors.
const TextStyle _unknownTagStyle = TextStyle(
  decoration: TextDecoration.underline,
  decorationStyle: TextDecorationStyle.wavy,
  decorationColor: Color(0xFFFF5555),
);

/// Shows the MiniMessage source in its own formatting: the text the way
/// Minecraft draws it in [componentContext], the tags around it pale.
class MiniMessageController extends TextEditingController {
  MiniMessageController({required this.componentContext, super.text});

  final ComponentContext componentContext;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    // The keyboard underlines the word it is still composing, which the
    // highlighting would hide. It's only for that moment.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return withTextShadow(
      MiniMessageParser.highlight(
        text,
        componentContext: componentContext,
        fontWeight: previewFontWeight,
        tagStyle: _tagStyle,
        unknownTagStyle: _unknownTagStyle,
      ),
    );
  }
}

/// The input for one MiniMessage component, on the same dark background as
/// the previews, so the colors in it are the ones in game.
class MiniMessageField extends StatelessWidget {
  const MiniMessageField({
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.validator,
    this.onSubmitted,
    super.key,
  });

  final MiniMessageController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      minLines: 1,
      maxLines: 3,
      // A text keyboard, not a multiline one, so Enter submits.
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.deny(_lineBreaks, replacementString: ' '),
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      cursorColor: Colors.white,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: previewBackground,
        enabledBorder: border(previewBorder),
        focusedBorder: border(colorScheme.primary, 2),
        errorBorder: border(colorScheme.error),
        focusedErrorBorder: border(colorScheme.error, 2),
      ),
    );
  }
}
