import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/util/dispatch_ext.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/api/state/app_state.dart';

/// Opens the create dialog for [entry]'s kind of model - the one its list's
/// Add button shows - and adds what is submitted to [projectKey]'s project.
///
/// Resolves to whether a model was submitted, so a caller elsewhere in the
/// app can follow up, e.g. by showing the list it went into.
Future<bool> openModelCreateDialog(
  BuildContext context,
  NavigationEntry entry,
  String projectKey,
) async {
  final bool? created = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppLocalizations l10n = context.l10n;
      return ModelCreateDialog(
        title: switch (entry) {
          NavigationEntry.items => l10n.dialog_item_create,
          NavigationEntry.font => l10n.dialog_font_create_title,
          NavigationEntry.sound => l10n.dialog_sound_create,
          NavigationEntry.expression => l10n.dialog_expression_create,
          NavigationEntry.function => l10n.dialog_expression_function_create,
          NavigationEntry.advancements => l10n.dialog_advancement_create,
          NavigationEntry.attributes => l10n.dialog_attribute_create,
        },
        projectNamespace: projectKey,
        // Expressions and functions have no key, so the dialog asks for none.
        askKey:
            entry != NavigationEntry.expression &&
            entry != NavigationEntry.function,
        onSubmit: (name, key) async {
          final ReduxAction<AppState> action = switch (entry) {
            NavigationEntry.items => ItemAddAction(
              ItemModel(uiName: name, key: key),
            ),
            NavigationEntry.font => FontAddAction(
              FontModel(
                uiName: name,
                key: key,
                provider: defaultFontProvider,
                height: defaultFontHeight,
              ),
            ),
            NavigationEntry.sound => SoundAddAction(
              SoundEventModel(uiName: name, key: key),
            ),
            NavigationEntry.expression => ExpressionAddAction(
              ExpressionModel(uiName: name, expression: ''),
            ),
            NavigationEntry.function => ExpressionFunctionAddAction(
              ExpressionFunctionModel(
                uiName: name,
                name: functionIdentifierFor(name),
              ),
            ),
            NavigationEntry.advancements => AdvancementAddAction(
              AdvancementModel(uiName: name, key: key),
            ),
            NavigationEntry.attributes => AttributeAddAction(
              AttributeModel(
                uiName: name,
                key: key,
                maximumValue: defaultAttributeMaximum,
              ),
            ),
          };
          // Closes only once the model exists, a failure keeps what was
          // typed and shows why.
          final (:ok, :error) = await context.dispatchAndCatch(action);
          if (!context.mounted) return;
          if (error != null) {
            context.showErrorSnackBar(error);
            return;
          }
          if (ok) Navigator.pop(context, true);
        },
      );
    },
  );
  return created ?? false;
}
