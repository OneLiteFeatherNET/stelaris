import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/sound/selected_sound_state.dart';
import 'package:stelaris/feature/base/button/positioned_save_button.dart';
import 'package:stelaris/feature/base/cards/text_input_card.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A widget that represents the general sound event management page.
///
/// The [SoundGeneralPage] allows users to view and edit the details
/// of a selected sound event, including its name, material, title, description,
/// and frame type. It provides a form for input and a save button to commit changes.
class SoundGeneralPage extends StatefulWidget {
  const SoundGeneralPage({super.key});

  @override
  State<SoundGeneralPage> createState() => _SoundGeneralPageState();
}

class _SoundGeneralPageState extends State<SoundGeneralPage> {
  final _formKey = GlobalKey<FormState>();
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
      builder: (context, vm) {
        final selected = vm.selected;

        return Form(
          key: _formKey,
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
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildTextField(
                                label: context.l10n.card_name,
                                currentValue: selected.variableName,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return context.l10n.error_card_empty;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final newEntry = selected.copyWith(
                                    variableName: value,
                                  );
                                  context.dispatch(UpdateSoundAction(newEntry));
                                },
                              ),
                              _buildTextField(
                                label: 'Key',
                                currentValue: selected.keyName,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return context.l10n.error_card_empty;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final newEntry = selected.copyWith(
                                    keyName: value,
                                  );
                                  context.dispatch(UpdateSoundAction(newEntry));
                                },
                              ),
                              _buildTextField(
                                label: 'Subtitle',
                                currentValue: selected.subTitle,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return context.l10n.error_card_empty;
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  final newEntry = selected.copyWith(
                                    subTitle: value,
                                  );
                                  context.dispatch(UpdateSoundAction(newEntry));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              PositionedSaveButton.standard(
                callback: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.dispatch(SoundDatabaseUpdate());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// The method builds a reusable text input card for updating string values.
  /// It takes different parameters to customize different aspects of the text field.
  Widget _buildTextField({
    required String label,
    required String? currentValue,
    required void Function(String) onChanged,
    String? Function(dynamic)? validator,
  }) {
    return TextInputCard<String>(
      display: label,
      currentValue: currentValue ?? emptyString,
      formatter: [FilteringTextInputFormatter.allow(stringPattern)],
      formValidator: validator,
      valueUpdate: (value) {
        if (value != currentValue) {
          onChanged(value);
        }
      },
    );
  }
}
