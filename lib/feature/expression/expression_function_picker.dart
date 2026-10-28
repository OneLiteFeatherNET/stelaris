import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_catalog_model.dart';
import 'package:stelaris/feature/expression/expression_function_sidebar.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Below this width the picker fills the screen instead of floating over it.
const double expressionFunctionPickerFullScreenWidth = 600;

/// The widest the floating picker gets, and the share of the height it takes.
const double _maxPickerWidth = 560;
const double _pickerHeightFactor = 0.7;

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
      final size = MediaQuery.sizeOf(dialogContext);
      return Dialog(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: _maxPickerWidth,
          height: size.height * _pickerHeightFactor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(dialogContext).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.button_close,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: content(dialogContext)),
              ],
            ),
          ),
        ),
      );
    },
  );
}
