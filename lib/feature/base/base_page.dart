import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stelaris_ui/api/state/actions/block_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/api/util/navigation.dart';

const double maxXOffset = 180;
const double minXOffset = 50;
const navigationEntries = NavigationEntry.values;
const navigationEntryTextStyle = TextStyle(fontSize: 16);

class BasePage extends StatefulWidget {
  final Widget child;

  const BasePage({Key? key, required this.child}) : super(key: key);

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool _navOpen = true;

  double _xOffset = maxXOffset;
  double _yOffset = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(onInit: (store) {
      store.dispatch(InitBlockAction());
    }, converter: (store) {
      return store.state;
    }, builder: (context, vm) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _navOpen = !_navOpen;
              _toggleSidebarState();
            },
          ),
          backgroundColor: Colors.deepPurple[300],
          elevation: 0,
          title: const Text('S T E L A R I S'),
          centerTitle: true,
        ),
        body: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavigationContainer(),
            Expanded(child: widget.child)
          ],
        ),
      );
    });
  }

  void _toggleSidebarState() {
    setState(() {
      _xOffset = _navOpen ? maxXOffset : minXOffset;
    });
  }

  Widget _buildNavigationContainer() {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: minXOffset, maxWidth: maxXOffset),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.fastOutSlowIn,
        width: _navOpen ? maxXOffset : minXOffset,
        child: Expanded(
          child: _buildNavigationView(),
        ),
      ),
    );
  }

  ListView _buildNavigationView() {
    final router = GoRouter.of(context);
    return ListView.builder(
      itemCount: navigationEntries.length,
      itemBuilder: (context, index) {
        var display = navigationEntries[index].display;
        var leadingIcon = Icon(navigationEntries[index].data);
        var title = (_xOffset == maxXOffset
            ? Text(
                display,
                style: navigationEntryTextStyle,
              )
            : Text(""));
        var selected = router.location == navigationEntries[index].route;
        return ListTile(
          title: title,
          dense: true,
          leading: leadingIcon,
          selected: selected,
        );
      },
    );
  }
}
