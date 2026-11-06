import 'package:async_redux/async_redux.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/generator/demo_generator_api.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/feature/build/download/download_helper.dart'
    as download;
import 'package:stelaris/feature/build/parts/branch_selector.dart';
import 'package:stelaris/feature/build/parts/generator_parts.dart';
import 'package:stelaris/feature/build/publish/publish_outcome.dart';
import 'package:stelaris/feature/build/tabs/local_build_tab.dart';
import 'package:stelaris/feature/build/tabs/publish_tab.dart';
import 'package:stelaris/feature/build/tabs/published_versions_tab.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// The generator page: test the project's generated code locally, publish
/// it as a release or snapshot, and list what it has published.
///
/// The vulpes-base branch above the tabs is shared by "Test locally" and
/// "Publish". Everything the tabs show lives in the store, so switching
/// tabs keeps it.
class GeneratorPage extends StatefulWidget {
  const GeneratorPage({this.api, this.saveFile, super.key});

  /// The generator to talk to, [ApiService.generatorApi] when null.
  final GeneratorApi? api;

  /// Saves downloads, the browser download when null.
  final download.FileSaver? saveFile;

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage>
    with SingleTickerProviderStateMixin {
  /// The tab without the branch selector.
  static const int _versionsTab = 2;

  /// The width of the page's column, as wide as the forms elsewhere.
  static const double _maxWidth = 928;

  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(_onTabChanged);

  GeneratorApi get _api => widget.api ?? ApiService().generatorApi;

  void _onTabChanged() {
    if (!_tabs.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
      builder: (context, vm) => _build(context, vm),
    );
  }

  Widget _build(BuildContext context, BuildViewModel vm) {
    final bool showBranch = _tabs.index != _versionsTab;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_api is DemoGeneratorApi) ...[
                const GeneratorDemoBanner(),
                const SizedBox(height: 16),
              ],
              if (showBranch) ...[
                BranchSelector(
                  branches: vm.generator.branches,
                  selected: vm.generator.selectedBranch,
                  onSelected: (branch) =>
                      context.dispatch(SelectBaseBranchAction(branch)),
                  onRetry: () =>
                      context.dispatch(LoadBranchesAction(api: _api)),
                ),
                const SizedBox(height: 16),
              ],
              TabBar(
                controller: _tabs,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.download),
                    text: context.l10n.generator_tab_local,
                  ),
                  Tab(
                    icon: const Icon(Icons.publish),
                    text: context.l10n.generator_tab_publish,
                  ),
                  Tab(
                    icon: const Icon(Icons.history),
                    text: context.l10n.generator_tab_versions,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              switch (_tabs.index) {
                0 => LocalBuildTab(
                  vm: vm,
                  onDownload: () => _downloadLocalBuild(context, vm),
                ),
                1 => PublishTab(
                  vm: vm,
                  onChannel: (channel) =>
                      context.dispatch(SelectReleaseChannelAction(channel)),
                  onBump: (bump) =>
                      context.dispatch(SelectBumpPartAction(bump)),
                  onPublish: () => _publish(context, vm),
                  onReloadVersions: () => _reloadVersions(context, vm),
                ),
                _ => PublishedVersionsTab(
                  vm: vm,
                  onReload: () => _reloadVersions(context, vm),
                  onDownload: (version) =>
                      _downloadPublished(context, vm, version),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  void _downloadLocalBuild(BuildContext context, BuildViewModel vm) {
    final Project? project = vm.usableProject;
    final String? branch = vm.baseBranch;
    if (project == null || branch == null) return;
    context.dispatch(
      DownloadLocalBuildAction(
        project,
        branch,
        api: _api,
        saveFile: widget.saveFile,
      ),
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
        saveFile: widget.saveFile,
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
