import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/constants.dart';

/// A widget that represents the general sound event management page.
///
/// The [SoundGeneralPage] allows users to view and edit the details
/// of a selected sound event, including its name, material, title, description,
/// and frame type. It provides a form for input and a save button to commit changes.
class SoundGeneralPage extends StatefulWidget {
  /// Creates an instance of [SoundGeneralPage].
  const SoundGeneralPage({super.key});

  @override
  State<SoundGeneralPage> createState() => _SoundGeneralPageState();
}

class _SoundGeneralPageState extends State<SoundGeneralPage> {
  /// A global key for the form to manage its state and validation.
  final _key = GlobalKey<FormState>();

  /// Scroll controller for the scrollable content
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SelectedSoundView>(
      vm: () => SelectedSoundState(),
      onDispose: (store) =>
          store.dispatch(RemoveSelectedSoundEvent(), notify: false),
      /*builder: (context, vm) {
        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 2, // Example: 10 items
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SoundFileCard(),
              );
            },
          ),
        );
      },*/
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
                                    currentValue:
                                        vm.selected.variableName ?? emptyString,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                        stringPattern,
                                      ),
                                    ],
                                    valueUpdate: (value) {
                                      if (value != vm.selected.variableName) {
                                        final oldModel = vm.selected;
                                        final newEntry = oldModel.copyWith(
                                          variableName: value,
                                        );
                                        context.dispatch(
                                          UpdateSoundAction(newEntry),
                                        );
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
                                    display: 'Key',
                                    currentValue:
                                    vm.selected.keyName ?? emptyString,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                        stringPattern,
                                      ),
                                    ],
                                    valueUpdate: (value) {
                                      if (value != vm.selected.keyName) {
                                        final oldModel = vm.selected;
                                        final newEntry = oldModel.copyWith(
                                          keyName: value,
                                        );
                                        context.dispatch(
                                          UpdateSoundAction(newEntry),
                                        );
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
                                    display: 'Key',
                                    currentValue:
                                    vm.selected.subTitle ?? emptyString,
                                    formatter: [
                                      FilteringTextInputFormatter.allow(
                                        stringPattern,
                                      ),
                                    ],
                                    valueUpdate: (value) {
                                      if (value != vm.selected.subTitle) {
                                        final oldModel = vm.selected;
                                        final newEntry = oldModel.copyWith(
                                          subTitle: value,
                                        );
                                        context.dispatch(
                                          UpdateSoundAction(newEntry),
                                        );
                                      }
                                    },
                                    formValidator: (value) {
                                      if (value.trim().isEmpty) {
                                        return context.l10n.error_card_empty;
                                      }
                                      return null;
                                    },
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
                      context.dispatch(SoundDatabaseUpdate());
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
