import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// "Test locally": downloads the project's local build for the selected
/// branch and says where it goes.
class LocalBuildTab extends StatelessWidget {
  const LocalBuildTab({required this.vm, required this.onDownload, super.key});

  final BuildViewModel vm;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final project = vm.usableProject;
    final RequestState<String> download = vm.generator.localBuild;
    final failure = download.failure;
    final String? saved = download.isDone ? download.value : null;

    return GeneratorSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.generator_local_description),
          const SizedBox(height: 16),
          if (project == null)
            GeneratorNote(context.l10n.generator_no_project)
          else ...[
            Text(
              context.l10n.generator_local_instructions(project.key),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: GeneratorActionButton(
                icon: Icons.download,
                label: context.l10n.generator_local_download(
                  '${project.key}-local.zip',
                ),
                busy: download.isLoading,
                onPressed: vm.canBuild ? onDownload : null,
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: 16),
              GeneratorError(
                title: context.l10n.generator_download_failed,
                failure: failure,
                onRetry: vm.canBuild ? onDownload : null,
              ),
            ],
            if (saved != null) ...[
              const SizedBox(height: 16),
              GeneratorNote(
                context.l10n.generator_local_saved(saved),
                icon: Icons.check_circle_outline,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
