import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/app_state.dart';

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
          return Expanded(
              child: Scaffold(
                endDrawer: getDrawer(),
                appBar: ,
                actions: <Widget>[
                  Builder(
                    builder: (context){
                      return IconButton(
                        icon: Icon(Icons.person),
                        onPressed: (){
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  )
                ],
                body: Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Hallo")
                  ],
                ),
              )
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