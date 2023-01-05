import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/api_service.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/build/dialog/download_dialog.dart';

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
          return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {},
                        child: const Text("Build")
                    ),
                    TextButton(
                        onPressed: () {
                          showDialog(context: context, builder: (BuildContext context) {
                            List<DropdownMenuItem<String>> branches = List.generate(3, (index) => DropdownMenuItem(
                                value: "Branch $index",
                                child: Text("Branch $index")));
                              return DownloadDialog(branches: branches);
                          });
                        },
                        child: const Text("Download")
                    )
                  ],
          );
        });
  }

  Drawer getDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Container(
        child: Text("Test"),
      ),
    );
  }
}