import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/generator/demo_generator_api.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/build/generator_info_dialog.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
import 'package:stelaris/feature/build/parts/branch_selector.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/feature/build/publish/publish_outcome.dart';
import 'package:stelaris/feature/build/tabs/local_build_tab.dart';
import 'package:stelaris/feature/build/tabs/publish_tab.dart';
import 'package:stelaris/feature/build/tabs/published_versions_tab.dart';
import 'package:stelaris/feature/model/model_detail_tab_bar.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The generator page: test the project's generated code locally, publish
/// it as a release or snapshot, and list what it has published.
///
/// Built like a detail page: the [PageHeader] on top, the tabs below it.
/// The vulpes-base branch is a field of "Test locally" and "Publish" and
/// the same selection in both. Everything the tabs show lives in the store,
/// so switching tabs keeps it.
class GeneratorPage extends StatelessWidget {
  const GeneratorPage({this.api, this.saveFile, super.key});

  /// The generator to talk to, [ApiService.generatorApi] when null.
  final GeneratorApi? api;

  /// Saves downloads, the browser download when null.
  final download.FileSaver? saveFile;

  GeneratorApi get _api => api ?? ApiService().generatorApi;

  void _loadProject(Store<AppState> store, Project? project) {
    store.dispatchSync(SyncGeneratorProjectAction(project?.id));
    final String? id = project?.id;
    if (project != null && id != null && id.isNotEmpty) {
      store.dispatch(LoadPublishedVersionsAction(project, api: _api));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BuildViewModel>(
      vm: () => BuildStateFactory(),
      onInit: (store) {
        _loadProject(store, store.state.selectedProject);
        store.dispatch(LoadBranchesAction(api: _api));
      },
      onWillChange: (context, store, previous, next) {
        if (previous.project?.id != next.project?.id) {
          _loadProject(store, next.project);
        }
      },
      builder: _build,
    );
  }

  Widget _build(BuildContext context, BuildViewModel vm) {
    final AppLocalizations l10n = context.l10n;
    final Project? project = vm.usableProject;
    final generator = vm.generator;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: PageHeader(
              title: BuildNavigationEntry.generator.display,
              actions: [
                PageHeaderAction(
                  icon: const Icon(Icons.info_outline),
                  label: l10n.menu_item_info,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) =>
                        GeneratorInfoDialog(demo: _api is DemoGeneratorApi),
                  ),
                ),
                PageHeaderAction(
                  icon: const Icon(Icons.refresh),
                  label: l10n.command_bar_refresh_tooltip,
                  loading:
                      generator.branches.isLoading ||
                      generator.versions.isLoading,
                  onPressed: () => _refresh(context, project),
                ),
              ],
            ),
          ),
          if (_api is DemoGeneratorApi)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GeneratorDemoBanner(),
            ),
          const SizedBox(height: 8),
          ModelDetailTabBar(
            tabs: [
              Tab(text: l10n.generator_tab_local),
              Tab(text: l10n.generator_tab_publish),
              Tab(text: l10n.generator_tab_versions),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: project == null
                  ? List.filled(3, const _NoProject())
                  : [
                      LocalBuildTab(
                        vm: vm,
                        project: project,
                        branchSelector: _branchSelector(context, vm),
                        onDownload: () => _downloadLocalBuild(context, vm),
                      ),
                      PublishTab(
                        vm: vm,
                        branchSelector: _branchSelector(context, vm),
                        onChannel: (channel) => context.dispatch(
                          SelectReleaseChannelAction(channel),
                        ),
                        onBump: (bump) =>
                            context.dispatch(SelectBumpPartAction(bump)),
                        onPublish: () => _publish(context, vm),
                        onReloadVersions: () => _reloadVersions(context, vm),
                        onDownloadVersion: (version) =>
                            _downloadPublished(context, vm, version),
                      ),
                      PublishedVersionsTab(
                        vm: vm,
                        onReload: () => _reloadVersions(context, vm),
                        onDownload: (version) =>
                            _downloadPublished(context, vm, version),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _branchSelector(BuildContext context, BuildViewModel vm) =>
      BranchSelector(
        branches: vm.generator.branches,
        selected: vm.generator.selectedBranch,
        onSelected: (branch) =>
            context.dispatch(SelectBaseBranchAction(branch)),
        onRetry: () => context.dispatch(LoadBranchesAction(api: _api)),
      );

  void _refresh(BuildContext context, Project? project) {
    context.dispatch(LoadBranchesAction(api: _api));
    final String? id = project?.id;
    if (project != null && id != null && id.isNotEmpty) {
      context.dispatch(LoadPublishedVersionsAction(project, api: _api));
    }
  }

  void _downloadLocalBuild(BuildContext context, BuildViewModel vm) {
    final Project? project = vm.usableProject;
    final String? branch = vm.baseBranch;
    if (project == null || branch == null) return;
    context.dispatch(
      DownloadLocalBuildAction(project, branch, api: _api, saveFile: saveFile),
    );
  }

  void _downloadPublished(
    BuildContext context,
    BuildViewModel vm,
    String version,
  ) {
    final Project? project = vm.usableProject;
    if (project == null) return;
    context.dispatch(
      DownloadPublishedVersionAction(
        project,
        version,
        api: _api,
        saveFile: saveFile,
      ),
    );
  }

  void _reloadVersions(BuildContext context, BuildViewModel vm) {
    final Project? project = vm.usableProject;
    if (project == null) return;
    context.dispatch(LoadPublishedVersionsAction(project, api: _api));
  }

  Future<void> _publish(BuildContext context, BuildViewModel vm) async {
    final Project? project = vm.usableProject;
    final String? branch = vm.baseBranch;
    final String? version = vm.publishableVersion;
    if (project == null || branch == null || version == null) return;
    final bool confirmed = await confirmPublish(
      context,
      version: version,
      channel: vm.generator.channel,
      branch: branch,
      replaces: vm.isPublished(version),
    );
    if (!confirmed || !context.mounted) return;
    context.dispatch(PublishReleaseAction(project, version, branch, api: _api));
  }
}

class _NoProject extends StatelessWidget {
  const _NoProject();

  @override
  Widget build(BuildContext context) {
    return EmptyDataWidget.full(
      header: context.l10n.generator_no_project,
      subHeader: context.l10n.generator_no_project_hint,
      icon: Icons.folder_off_outlined,
    );
  }
}
