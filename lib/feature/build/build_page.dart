import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/base/cards/expandable_data_card.dart';
import 'package:stelaris_ui/feature/build/dialog/download_dialog.dart';
import 'package:stelaris_ui/feature/build/dialog/version_dialog.dart';

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
            Wrap(clipBehavior: Clip.hardEdge, children: [
              ExpandableDataCard(
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
              ),
            ]),
            Positioned(
                bottom: 25,
                right: 25,
                child: Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                          label: const Text("Download"),
                          icon: const Icon(Icons.download),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
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
                                return DownloadDialog(branches: finalBranches);
                              });
                        },
                        label: const Text("Generate"),
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
