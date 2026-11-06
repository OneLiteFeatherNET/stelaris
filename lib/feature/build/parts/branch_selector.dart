import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The vulpes-base branch that "Test locally" and "Publish" build against.
class BranchSelector extends StatelessWidget {
  const BranchSelector({
    required this.branches,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
    super.key,
  });

  final RequestState<List<String>> branches;
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GeneratorSection(child: _content(context));
  }

  Widget _content(BuildContext context) {
    final failure = branches.failure;
    if (failure != null) {
      return GeneratorError(
        title: context.l10n.generator_branches_failed,
        failure: failure,
        onRetry: onRetry,
      );
    }
    final List<String>? names = branches.value;
    if (names == null) {
      return GeneratorLoading(context.l10n.generator_branches_loading);
    }
    if (names.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: GeneratorNote(
              context.l10n.generator_branches_empty,
              icon: Icons.warning_amber_rounded,
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.generator_retry,
          ),
        ],
      );
    }
    return DropdownButtonFormField<String>(
      // A new selection from outside (a reload) must show, which the
      // field's own state would otherwise keep from it.
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: context.l10n.generator_branch_label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final name in names)
          DropdownMenuItem(value: name, child: Text(name)),
      ],
      onChanged: branches.isLoading
          ? null
          : (value) {
              if (value != null) onSelected(value);
            },
    );
  }
}
