import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/branch_selector.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// "Test locally": downloads the project's local build for the selected
/// branch, and next to it the steps to use it.
class LocalBuildTab extends StatelessWidget {
  const LocalBuildTab({
    required this.vm,
    required this.project,
    required this.branchSelector,
    required this.onDownload,
    super.key,
  });

  final BuildViewModel vm;
  final Project project;

  /// The shared branch field, at the top of the section.
  final Widget branchSelector;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final RequestState<String> download = vm.generator.localBuild;
    final failure = download.failure;
    final String? saved = download.isDone ? download.value : null;

    return GeneratorTabBody(
      children: [
        GeneratorColumns(
          start: [
            GeneratorSection(
              title: l10n.generator_local_title,
              spacing: 24,
              children: [
                GeneratorText(l10n.generator_local_description),
                // The branch and the download on one line while they fit.
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: BranchSelector.maxWidth,
                      child: branchSelector,
                    ),
                    GeneratorActionButton(
                      icon: Icons.download,
                      label: l10n.generator_local_download(
                        '${project.key}-local.zip',
                      ),
                      busy: download.isLoading,
                      onPressed: vm.canBuild ? onDownload : null,
                      standalone: false,
                    ),
                  ],
                ),
                if (failure != null)
                  GeneratorError(
                    title: l10n.generator_download_failed,
                    failure: failure,
                    onRetry: vm.canBuild ? onDownload : null,
                  ),
                if (saved != null)
                  GeneratorNote(
                    l10n.generator_local_saved(saved),
                    icon: Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ],
          end: [
            GeneratorSection(
              title: l10n.generator_local_howto_title,
              children: [
                _Steps(
                  steps: [
                    l10n.generator_local_step_download,
                    l10n.generator_local_step_unzip(project.key),
                    l10n.generator_local_step_build(project.key),
                    l10n.generator_local_step_remove(project.key),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Numbered steps, each behind a small tonal number.
class _Steps extends StatelessWidget {
  const _Steps({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colors.secondaryContainer,
                foregroundColor: colors.onSecondaryContainer,
                child: Text('${index + 1}', style: theme.textTheme.labelMedium),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(step, style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
