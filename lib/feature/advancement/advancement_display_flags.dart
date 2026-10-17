import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A row of toggle buttons to set how the [selected] advancement is shown: as
/// a toast, in the chat and whether it is hidden.
///
/// Each flag is its own button, so any combination can be selected.
class AdvancementDisplayFlags extends StatelessWidget {
  /// The advancement whose flags are shown.
  final AdvancementModel selected;

  const AdvancementDisplayFlags({required this.selected, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget toggle(
      String label,
      bool value,
      AdvancementModel Function(bool value) change, {
      String? tooltip,
    }) {
      return SegmentedButton<bool>(
        emptySelectionAllowed: true,
        segments: [
          ButtonSegment(value: true, label: Text(label), tooltip: tooltip),
        ],
        selected: {if (value) true},
        onSelectionChanged: (flags) => context.dispatch(
          UpdateAdvancementAction(change(flags.contains(true))),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        toggle(
          l10n.card_advancement_show_toast,
          selected.showToast,
          (value) => selected.copyWith(showToast: value),
        ),
        toggle(
          l10n.card_advancement_announce_to_chat,
          selected.announceToChat,
          (value) => selected.copyWith(announceToChat: value),
        ),
        toggle(
          l10n.card_advancement_hidden,
          selected.hidden,
          (value) => selected.copyWith(hidden: value),
          tooltip: l10n.tooltip_advancement_hidden,
        ),
      ],
    );
  }
}
