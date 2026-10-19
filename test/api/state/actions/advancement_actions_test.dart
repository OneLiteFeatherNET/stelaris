import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/list_actions.dart';

void main() {
  listActionTests<AdvancementModel>(
    model: (id, {projectId}) =>
        AdvancementModel(uiName: id, id: id, projectId: projectId),
    listOf: (state) => state.advancements,
    withList: (state, list) => state.copyWith(advancements: list),
    init: InitAdvancementAction.new,
    refresh: RefreshAdvancementAction.new,
    add: AdvancementAddAction.new,
    remove: AdvancementRemoveAction.new,
    copy: AdvancementCopyAction.new,
  );
}
