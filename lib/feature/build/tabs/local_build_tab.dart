import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/state/generator_state.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// "Test locally": downloads the project's local build for the selected
/// branch and says where it goes.
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
        GeneratorSection(
          title: l10n.generator_local_title,
          children: [
            GeneratorText(l10n.generator_local_description),
            branchSelector,
            GeneratorText(
              l10n.generator_local_instructions(project.key),
              emphasized: true,
            ),
            GeneratorActionButton(
              icon: Icons.download,
              label: l10n.generator_local_download('${project.key}-local.zip'),
              busy: download.isLoading,
              onPressed: vm.canBuild ? onDownload : null,
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
    );
  }
}
