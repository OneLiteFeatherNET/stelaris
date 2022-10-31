import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

class BuildPage extends StatefulWidget {

  const BuildPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuildPageState();
  }
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
          return Container();
        });
  }

  Widget getCreateWidget() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget openTemplateDialog() {
    return Stepper(steps: [],);
  }
}