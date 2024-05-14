import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/model/item_model.dart';
import 'package:stelaris_ui/api/util/minecraft/item_flag.dart';

import 'package:stelaris_ui/api/state/actions/item_actions.dart';

class SingleFlagCard extends StatelessWidget {
  const SingleFlagCard({
    required this.flag,
    required this.model,
    super.key,
  });

  final ItemFlag flag;
  final ItemModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(flag.display),
        trailing: Checkbox(
          value: model.flags?.contains(flag.minestomValue) ?? false,
          onChanged: (value) {
            if (value == null) return;
            final oldEntry = model;
            final Set<String> flags = Set.of(oldEntry.flags ?? {});
            if (value) {
              flags.add(flag.minestomValue);
            } else {
              flags.remove(flag.minestomValue);
            }
            final newEntry = oldEntry.copyWith(flags: flags);
            context.dispatch(UpdateItemAction(newEntry));
          },
        ),
      ),
    );
  }
}
