import 'package:async_redux/async_redux.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/item_page.dart';

class ItemVmFactory extends VmFactory<AppState, ItemPage, ItemViewModel> {
  ItemVmFactory();

  @override
  ItemViewModel fromStore() => ItemViewModel(
    itemModels: state.items.items,
    hasNextPage: state.items.hasNextPage,
    projectKey: state.selectedProject!.key,
  );
}

class ItemViewModel extends Vm {
  final List<ItemModel> itemModels;
  final bool hasNextPage;
  final String projectKey;

  ItemViewModel({
    required this.itemModels,
    required this.hasNextPage,
    required this.projectKey,
  }) : super(
         equals: [
           itemModels,
           hasNextPage,
           projectKey,
         ],
       );
}
