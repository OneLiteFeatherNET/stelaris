import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/font/selected_font_state.dart';
import 'package:stelaris/feature/base/unsaved/detail_forms.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/formatter/formatters.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

class FontGeneralPage extends StatefulWidget {
  const FontGeneralPage({super.key});

  @override
  State<FontGeneralPage> createState() => _FontGeneralPageState();
}

class _FontGeneralPageState extends State<FontGeneralPage> {
  /// Scroll controller for the scrollable content
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedFontView>(
      vm: () => SelectedFontFactory(),
      builder: (context, vm) {
        return FocusScope(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Form(
              key: _key,
              onChanged: () => context.dispatch(
                MarkUnsavedChangesAction(NavigationEntry.font),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                TextInputCard<String>(
                                  display: context.l10n.card_font_provider,
                                  currentValue:
                                      vm.selected.provider ?? emptyString,
                                  formatter: [stringPatternFormatter],
                                  valueUpdate: (value) => _updateFont(
                                    context,
                                    value,
                                    vm.selected.provider,
                                    (newValue) => vm.selected.copyWith(
                                      provider: newValue,
                                    ),
                                  ),
                                  focusOrder: const NumericFocusOrder(1),
                                ),
                                TextInputCard<String>(
                                  display: context.l10n.card_comment,
                                  currentValue:
                                      vm.selected.comment ?? emptyString,
                                  formatter: [withSpacesFormatter],
                                  valueUpdate: (value) => _updateFont(
                                    context,
                                    value,
                                    vm.selected.comment,
                                    (newValue) =>
                                        vm.selected.copyWith(comment: newValue),
                                  ),
                                  focusOrder: const NumericFocusOrder(2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              RegisterDetailForm(formKey: _key),
            ],
          ),
        ),
      ),
    );
  },
);
  }

  void _updateFont(
    BuildContext context,
    String value,
    String? currentValue,
    dynamic Function(String) createNewModel,
  ) {
    if (value == currentValue) {
      return;
    }

    final newEntry = createNewModel(value);
    context.dispatch(UpdateFontAction(newEntry));
  }
}
