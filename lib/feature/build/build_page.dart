import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/position_bottom_right.dart';
import 'package:stelaris_ui/feature/build/dialog/download_dialog.dart';
import 'package:stelaris_ui/feature/build/dialog/generate_dialog.dart';
import 'package:stelaris_ui/util/I10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';

class BuildPage extends StatefulWidget {
  const BuildPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BuildPageState();
}

class BuildPageState extends State<BuildPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      onInit: (store) {},
      converter: (store) {
        return store.state;
      },
      builder: (context, vm) {
        return Stack(
          children: [
            const Center(
              child: Text('Nothing to see / WIP'),
            ),
            const Wrap(clipBehavior: Clip.hardEdge, children: [

              /*ExpandableDataCard(
                title: const Text("Version"),
                buttonClick: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return VersionDialog(
                        valueUpdate: (value) => {},
                      );
                    },
                  );
                },
                widgets: List<Widget>.generate(
                  3,
                  (index) {
                    return ListTile(
                      title: Text("a"),
                    );
                  },
                ),
              ),*/
            ]),
            PositionBottomRight(
                child: Row(
                  children: [
                    Padding(
                        padding: horizontalPadding,
                        child: FloatingActionButton.extended(
                          heroTag: UniqueKey(),
                          onPressed: () async {
                            final branches =
                                await ApiService().generateApi.branches();
                            final finalBranches = branches
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text("Branch $e")))
                                .toList();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DownloadDialog(
                                      branches: finalBranches);
                                });
                          },
                          label: Text(context.l10n.button_download),
                          icon: const Icon(Icons.download),
                        )),
                    Padding(
                      padding: horizontalPadding,
                      child: FloatingActionButton.extended(
                        heroTag: UniqueKey(),
                        onPressed: () async {
                          final branches =
                              await ApiService().generateApi.branches();
                          final finalBranches = branches
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text("Branch $e")))
                              .toList();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return GenerateDialog(branches: finalBranches);
                              });
                        },
                        label: Text(context.l10n.button_generate),
                        icon: const Icon(Icons.build),
                      ),
                    )
                  ],
                ))
          ],
        );
      },
    );
  }
}
