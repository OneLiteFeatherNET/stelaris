import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/expression/expression_function_sidebar.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Below this width the picker fills the screen instead of floating over it.
const double expressionFunctionPickerFullScreenWidth = 600;

/// The size of the floating picker, the same as the component picker's.
const double _maxPickerWidth = 560;
const double _contentHeight = 480;

/// Opens the picker of the catalog's functions and constants, to search and
/// tap one. A tap closes the picker, then calls [onFunction] or [onConstant]
/// with the entry, so the caller inserts it where the formula's caret is.
///
/// On a wide screen the picker floats over the page; on a narrow one it fills
/// the screen. With no [catalog] yet, it says the functions are unavailable.
Future<void> showExpressionFunctionPicker(
  BuildContext context, {
  required ExpressionCatalog? catalog,
  required ValueChanged<CatalogFunction> onFunction,
  required ValueChanged<CatalogConstant> onConstant,
}) {
  final fullScreen =
      MediaQuery.sizeOf(context).width <
      expressionFunctionPickerFullScreenWidth;
  // Built from the dialog's own context: a tap pops the dialog, not the page.
  ExpressionFunctionSidebar content(BuildContext dialogContext) =>
      ExpressionFunctionSidebar(
        catalog: catalog,
        onFunction: (function) {
          Navigator.of(dialogContext).pop();
          onFunction(function);
        },
        onConstant: (constant) {
          Navigator.of(dialogContext).pop();
          onConstant(constant);
        },
      );

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;
      final title = l10n.expression_functions_title;
      if (fullScreen) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: l10n.button_close,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              title: Text(title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: content(dialogContext),
            ),
          ),
        );
      }
      return FormDialog(
        title: title,
        actionLabel: l10n.button_close,
        onSubmit: null,
        showActions: false,
        maxWidth: _maxPickerWidth,
        // Fixed, so the dialog keeps its size while the user types.
        content: SizedBox(
          height: _contentHeight,
          child: content(dialogContext),
        ),
      );
    },
  );
}
