import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/advancement/selected_advancement_state.dart';
import 'package:stelaris/feature/advancement/advancement_display_flags.dart';
import 'package:stelaris/feature/advancement/text_component.dart';
import 'package:stelaris/feature/base/unsaved/detail_forms.dart';
import 'package:stelaris/feature/base/cards/dropdown_card.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';
import 'package:vulpes_data/advancement.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/util/navigation.dart';

/// The value of the parent dropdown for a root advancement.
const String _noParent = emptyString;

/// Allows a signed decimal number while it is typed.
final RegExp _decimalPattern = RegExp(r'^-?\d*\.?\d*');

const TextInputType _decimalInput = TextInputType.numberWithOptions(
  signed: true,
  decimal: true,
);

/// A widget that represents the general advancement management page.
///
/// The [AdvancementGeneralPage] allows users to view and edit the details
/// of a selected advancement: how it is shown, its icon, title, description,
/// frame type and its place in the advancement tree.
/// The title and description are edited as plain text and stored as JSON
/// text components.
class AdvancementGeneralPage extends StatefulWidget {
  /// Creates an instance of [AdvancementGeneralPage].
  const AdvancementGeneralPage({super.key});

  @override
  State<AdvancementGeneralPage> createState() => _AdvancementGeneralPageState();
}

class _AdvancementGeneralPageState extends State<AdvancementGeneralPage> {
  /// A global key for the form to manage its state and validation.
  final _key = GlobalKey<FormState>();

  /// Scroll controller for the scrollable content
  final ScrollController _scrollController = ScrollController();

  /// A list of dropdown menu items for frame types.
  static const List<FrameType> types = FrameType.values;
  static final List<DropdownMenuItem<FrameType>> items = List.generate(
    types.length,
    (index) => DropdownMenuItem(
      value: types[index],
      child: Text(types[index].displayName),
    ),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Dispatches the selected advancement changed by [change], unless nothing
  /// changed.
  void _update(
    BuildContext context,
    AdvancementModel selected,
    AdvancementModel Function(AdvancementModel model) change,
  ) {
    final newEntry = change(selected);
    if (newEntry == selected) return;
    context.dispatch(UpdateAdvancementAction(newEntry));
  }

  /// Builds the parent options: a root entry, the loaded [parents] and the
  /// current parent, if it is not loaded yet.
  List<DropdownMenuItem<String>> _parentItems(
    BuildContext context,
    SelectedAdvancementView vm,
  ) {
    final parentId = vm.selected.parentId;
    final isLoaded =
        parentId == null || vm.parents.any((model) => model.id == parentId);
    return [
      DropdownMenuItem(
        value: _noParent,
        child: Text(context.l10n.advancement_parent_none),
      ),
      for (final model in vm.parents)
        DropdownMenuItem(value: model.id!, child: Text(model.uiName)),
      if (!isLoaded) DropdownMenuItem(value: parentId, child: Text(parentId)),
    ];
  }

  TextInputCard<double> _positionCard(
    BuildContext context, {
    required String display,
    required double value,
    required AdvancementModel Function(double value) change,
    required int order,
    required SelectedAdvancementView vm,
  }) {
    return TextInputCard<double>(
      display: display,
      tooltipMessage: context.l10n.tooltip_advancement_position,
      currentValue: value.toString(),
      valueUpdate: (input) {
        final parsed = double.tryParse(input) ?? 0;
        _update(context, vm.selected, (_) => change(parsed));
      },
      inputType: _decimalInput,
      formatter: [FilteringTextInputFormatter.allow(_decimalPattern)],
      isNumber: true,
      focusOrder: NumericFocusOrder(order.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedAdvancementView>(
      vm: () => SelectedAdvancementFactory(),
      builder: (context, vm) {
        final selected = vm.selected;
        return FocusScope(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Form(
              key: _key,
              onChanged: () => context.dispatch(
                MarkUnsavedChangesAction(NavigationEntry.advancements),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AdvancementDisplayFlags(selected: selected),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        TextInputCard<String>(
                                          display: context.l10n.card_material,
                                          currentValue:
                                              selected.material ?? emptyString,
                                          hintText: defaultMaterial,
                                          valueUpdate: (value) => _update(
                                            context,
                                            selected,
                                            (model) =>
                                                model.copyWith(material: value),
                                          ),
                                          formValidator: (value) {
                                            if (value == null) return null;
                                            if (!minecraftPattern.hasMatch(
                                              value,
                                            )) {
                                              return context
                                                  .l10n
                                                  .input_validation_material;
                                            }
                                            return null;
                                          },
                                          maxLength: 30,
                                          focusOrder: const NumericFocusOrder(
                                            1,
                                          ),
                                        ),
                                        TextInputCard<String>(
                                          display: context.l10n.card_title,
                                          currentValue: plainTextOf(
                                            selected.title,
                                          ),
                                          valueUpdate: (value) => _update(
                                            context,
                                            selected,
                                            (model) => model.copyWith(
                                              title: textComponentOf(
                                                value,
                                                previous: model.title,
                                              ),
                                            ),
                                          ),
                                          focusOrder: const NumericFocusOrder(
                                            2,
                                          ),
                                        ),
                                        TextInputCard<String>(
                                          display:
                                              context.l10n.card_description,
                                          currentValue: plainTextOf(
                                            selected.description,
                                          ),
                                          valueUpdate: (value) => _update(
                                            context,
                                            selected,
                                            (model) => model.copyWith(
                                              description: textComponentOf(
                                                value,
                                                previous: model.description,
                                              ),
                                            ),
                                          ),
                                          maxLength: 120,
                                          focusOrder: const NumericFocusOrder(
                                            3,
                                          ),
                                        ),
                                        DropdownCard<
                                          FrameType,
                                          AdvancementModel
                                        >(
                                          display: context.l10n.card_frame_type,
                                          currentValue: selected,
                                          items: items,
                                          valueUpdate: (value) => _update(
                                            context,
                                            selected,
                                            (model) => model.copyWith(
                                              frameType: value,
                                            ),
                                          ),
                                          defaultValue: (value) =>
                                              value.frameType,
                                          matchTextInputHeight: true,
                                          focusOrder: const NumericFocusOrder(
                                            4,
                                          ),
                                        ),
                                        DropdownCard<String, AdvancementModel>(
                                          display: context
                                              .l10n
                                              .card_advancement_parent,
                                          tooltipMessage: context
                                              .l10n
                                              .tooltip_advancement_parent,
                                          currentValue: selected,
                                          items: _parentItems(context, vm),
                                          valueUpdate: (value) => _update(
                                            context,
                                            selected,
                                            (model) => model.copyWith(
                                              parentId: value == _noParent
                                                  ? null
                                                  : value,
                                            ),
                                          ),
                                          defaultValue: (value) =>
                                              value.parentId ?? _noParent,
                                          matchTextInputHeight: true,
                                          focusOrder: const NumericFocusOrder(
                                            5,
                                          ),
                                        ),
                                        if (selected.isRoot)
                                          TextInputCard<String>(
                                            display: context
                                                .l10n
                                                .card_advancement_background,
                                            tooltipMessage: context
                                                .l10n
                                                .tooltip_advancement_background,
                                            currentValue:
                                                selected.background ??
                                                emptyString,
                                            hintText: 'minecraft:gui/advancements/backgrounds/stone',
                                            valueUpdate: (value) => _update(
                                              context,
                                              selected,
                                              (model) => model.copyWith(
                                                background: value.isEmpty
                                                    ? null
                                                    : value,
                                              ),
                                            ),
                                            maxLength: 100,
                                            focusOrder: const NumericFocusOrder(
                                              6,
                                            ),
                                          ),
                                        _positionCard(
                                          context,
                                          display:
                                              context.l10n.card_advancement_x,
                                          value: selected.x,
                                          change: (x) =>
                                              selected.copyWith(x: x),
                                          order: 7,
                                          vm: vm,
                                        ),
                                        _positionCard(
                                          context,
                                          display:
                                              context.l10n.card_advancement_y,
                                          value: selected.y,
                                          change: (y) =>
                                              selected.copyWith(y: y),
                                          order: 8,
                                          vm: vm,
                                        ),
                                      ],
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
}
