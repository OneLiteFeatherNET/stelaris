import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/model/notification_model.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/notification/selected_notification_state.dart';
import 'package:stelaris/api/util/minecraft/frame_type.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/dropdown_card.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

/// A widget that represents the general notification management page.
///
/// The [NotificationGeneralPage] allows users to view and edit the details
/// of a selected notification, including its name, material, title, description,
/// and frame type. It provides a form for input and a save button to commit changes.
class NotificationGeneralPage extends StatefulWidget {
  /// Creates an instance of [NotificationGeneralPage].
  const NotificationGeneralPage({super.key});

  @override
  State<NotificationGeneralPage> createState() =>
      _NotificationGeneralPageState();
}

class _NotificationGeneralPageState extends State<NotificationGeneralPage> {
  /// A global key for the form to manage its state and validation.
  final _key = GlobalKey<FormState>();

  /// Scroll controller for the scrollable content
  final ScrollController _scrollController = ScrollController();

  /// A list of dropdown menu items for frame types.
  static const List<FrameType> types = FrameType.values;
  static final List<DropdownMenuItem<FrameType>> items = List.generate(
    types.length,
    (index) =>
        DropdownMenuItem(value: types[index], child: Text(types[index].value)),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedNotificationView>(
      vm: () => SelectedNotificationFactory(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectNotificationAction(), notify: false),
      builder: (context, vm) {
        return Expanded(
          child: Form(
            key: _key,
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
                                    display: context.l10n.card_name,
                                    currentValue: vm.name,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(stringPattern),
                                    ],
                                    valueUpdate: (value) {
                                      if (value != vm.name) {
                                        final oldModel = vm.selected;
                                        final newEntry =
                                            oldModel.copyWith(name: value);
                                        context.dispatch(
                                            UpdateNotificationAction(newEntry));
                                      }
                                    },
                                    formValidator: (value) {
                                      if (value.trim().isEmpty) {
                                        return context.l10n.error_card_empty;
                                      }
                                      return null;
                                    },
                                  ),
                                  TextInputCard<String>(
                                    display: context.l10n.card_material,
                                    currentValue:
                                        vm.selected.material ?? emptyString,
                                    hintText: defaultMaterial,
                                    valueUpdate: (value) {
                                      if (value != vm.selected.material) {
                                        final oldModel = vm.selected;
                                        final newEntry =
                                            oldModel.copyWith(material: value);
                                        context.dispatch(
                                            UpdateNotificationAction(newEntry));
                                      }
                                    },
                                    formValidator: (value) {
                                      if (value == null) return null;
                                      if (!minecraftPattern.hasMatch(value)) {
                                        return context
                                            .l10n.input_validation_material;
                                      }
                                      return null;
                                    },
                                    maxLength: 30,
                                  ),
                                  TextInputCard<String>(
                                    display: context.l10n.card_title,
                                    currentValue:
                                        vm.selected.title ?? emptyString,
                                    valueUpdate: (value) {
                                      if (value != vm.selected.title) {
                                        final oldModel = vm.selected;
                                        final newEntry =
                                            oldModel.copyWith(title: value);
                                        context.dispatch(
                                            UpdateNotificationAction(newEntry));
                                      }
                                    },
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                          stringWithSpacePattern
                                      ),
                                    ],
                                  ),
                                  TextInputCard<String>(
                                    display: context.l10n.card_description,
                                    currentValue:
                                        vm.selected.description ?? emptyString,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                          stringWithSpacePattern
                                      ),
                                    ],
                                    valueUpdate: (value) {
                                      if (value != vm.selected.description) {
                                        final oldModel = vm.selected;
                                        final newEntry = oldModel.copyWith(
                                            description: value);
                                        context.dispatch(
                                            UpdateNotificationAction(newEntry));
                                      }
                                    },
                                  ),
                                  DropdownCard<FrameType, NotificationModel>(
                                    display: context.l10n.card_frame_type,
                                    currentValue: vm.selected,
                                    items: items,
                                    valueUpdate: (value) {
                                      if (value == null) return;
                                      if (value != vm.selected.frameType) {
                                        final oldModel = vm.selected;
                                        final newEntry =
                                            oldModel.copyWith(frameType: value);
                                        context.dispatch(
                                            UpdateNotificationAction(newEntry));
                                      }
                                    },
                                    defaultValue: (value) => value.frameType,
                                    matchTextInputHeight: true,
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
                PositionedSaveButton.standard(
                  callback: () {
                    if (_key.currentState?.validate() ?? false) {
                      context.dispatch(NotificationDatabaseUpdate());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
