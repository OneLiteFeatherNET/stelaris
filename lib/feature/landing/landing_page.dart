import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/state/app_state_actions.dart';
import 'package:stelaris_ui/api/util/navigation.dart';
import 'package:stelaris_ui/feature/search/search.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

const double maxXOffset = 180;
const double minXOffset = 50;

class _LandingPageState extends State<LandingPage> {
  bool navOpen = true;

  double xOffset = maxXOffset;
  double yOffset = 0;

  void setSidebarState() {
    setState(() {
      xOffset = navOpen ? maxXOffset : minXOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      onInit: (store) {
        store.dispatch(InitAction());
      },
      converter: (store) {
        return store.state;
      },
      builder: (context, vm) {
        print(vm.blocks.length);

        var items = vm.blocks.isNotEmpty ? vm.blocks.map((e) => e.name ?? 'X').toList() : List<String>.generate(1, (index) => "1");
        var selected = 0;
        return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  navOpen = !navOpen;
                  setSidebarState();
                },
              ),
              backgroundColor: Colors.deepPurple[300],
              elevation: 0,
              title: const Text('S T E L A R I S'),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                Row(
                  children: [
                    buildNavigation(),
                    ItemList(items),
                    ItemContent(items[selected]),
                  ],
                ),
                Align(
                  alignment: const Alignment(0.99, 0.98),
                  child: FloatingActionButton(
                    backgroundColor: Colors.lightGreen,
                    child: const Icon(Icons.add),
                    onPressed: () {},
                  ),
                )
              ],
            ));
      },
    );
  }

  Widget buildNavigation() {
    var items = buildListView();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.fastOutSlowIn,
      width: navOpen ? 180 : 60,
      child: Container(child: items),
    );
  }

  ListView buildListView() {
    var values = NavigationEntry.values;
    return ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                GoRouter.of(context).go(values[index].route); // Navigation
              },
              title: xOffset == maxXOffset
                  ? Text(
                      values[index].display,
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
              leading: Icon(values[index].data),
            ));
  }
}

class ItemContent extends StatefulWidget {
  String item;

  ItemContent(this.item);

  @override
  State<StatefulWidget> createState() {
    return ItemContentState();
  }
}

class ItemContentState extends State<ItemContent> {
  @override
  Widget build(BuildContext context) {
    final views = List.generate(
        3,
        (index) => Scaffold(
              appBar: AppBar(
                title: Text("View ${index + 1}"),
              ),
              body: Center(
                  child: Column(children: [
                if (index == 0) ...[
                  _attributes(),
                ] else if (index == 1) ...[
                  _meta(),
                ] else ...[
                  Text("Test"),
                ]
              ])),
            ));
    return DefaultTabController(
      length: views.length,
      child: tabBarView(views),
    );
  }

  Widget _meta() {
    return Column(
      children: [
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Name"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "ID"),
          ),
        )
      ],
    );
  }

  Widget _attributes() {
    return Column(
      children: [
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Name"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Namespace"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Display name"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Flags"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Lore"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Amount"),
          ),
        ),
        Card(
          color: Colors.purple[50],
          child: TextField(
            decoration: InputDecoration(labelText: "Enchantments"),
          ),
        )
      ],
    );
  }

  Widget tabBarView(List<Widget> views) {
    return Expanded(
      child: Scaffold(
        body: TabBarView(
          children: views,
        ),
        appBar: AppBar(
          title: const Text("Ich bin ein Item von Steffen!"),
          bottom: _tabBar(),
        ),
      ),
    );
  }

  TabBar _tabBar() {
    return const TabBar(
      tabs: [
        Tab(
          child: Text("1"),
        ),
        Tab(
          child: Text("2"),
        ),
        Tab(
          child: Text("3"),
        )
      ],
    );
  }
}

class ItemList extends StatefulWidget {
  List<String> items;

  ItemList(this.items);

  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {
  List<String> filterList = List.empty();
  final _formKey = GlobalKey<FormState>();
  final _searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    filterList = widget.items;
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: SearchWidget(),
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
            width: 250,
            child: ListView(
                children: filterList
                    .map((e) => TextButton(
                          onPressed: () {},
                          child: Dismissible(
                              direction: DismissDirection.endToStart,
                              movementDuration:
                                  const Duration(milliseconds: 500),
                              background: Container(color: Colors.green),
                              confirmDismiss: (direction) {
                                if (direction == DismissDirection.endToStart) {
                                  return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Are you sure?'),
                                          content: Text(
                                              'Do you want to remove this article?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Remove'),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                } else {
                                  var dismiss = Future.value(true);
                                  return dismiss;
                                }
                              },
                              secondaryBackground: Container(
                                padding: const EdgeInsets.only(right: 15),
                                alignment: Alignment.centerRight,
                                color: Colors.red,
                                child: const Icon(Icons.cancel,
                                    color: Colors.white),
                              ),
                              key: const Key("test"),
                              child: Card(
                                  child: ListTile(
                                title: Text(e),
                              ))),
                        ))
                    .toList()),
          )),
        ],
      ),
    );
  }
}
