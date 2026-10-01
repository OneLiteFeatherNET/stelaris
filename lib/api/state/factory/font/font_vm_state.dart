import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/font/font_page.dart';

class FontVmFactory extends VmFactory<AppState, FontPage, FontViewModel> {
  FontVmFactory();

  @override
  FontViewModel fromStore() => FontViewModel(
    models: state.fonts.items,
    hasNextPage: state.fonts.hasNextPage,
    isLoadingMore: state.isLoadingMoreFonts,
    projectKey: state.selectedProject!.key,
  );
}

class FontViewModel extends Vm {
  final List<FontModel> models;
  final bool hasNextPage;
  final bool isLoadingMore;
  final String projectKey;

  FontViewModel({
    required this.models,
    required this.hasNextPage,
    required this.isLoadingMore,
    required this.projectKey,
  }) : super(
         equals: [
           models,
           hasNextPage,
           isLoadingMore,
           projectKey,
         ],
       );
}
