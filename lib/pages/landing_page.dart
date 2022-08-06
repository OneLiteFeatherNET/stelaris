import 'package:flutter/material.dart';
import '/util/constants.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        elevation: 0,
        title: const Text('S T E L A R I S'),
        centerTitle: true,
        /*leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),*/
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              buildMenuItems(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
    ),
  );

  Widget buildMenuItems(BuildContext context) => SafeArea(
    top: false,
    child: Wrap(
      runSpacing: 16,
      children: [
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Dashboard'),
          onTap: () {},
        ),
        const Divider(color: Colors.black12),
        ListTile(
          leading: const Icon(Icons.interpreter_mode),
          title: const Text('Items'),
          onTap: () {},
        ),
        const Divider(height: 0.05, color: Colors.black12),
        ListTile(
          leading: const Icon(Icons.energy_savings_leaf),
          title: const Text('Mobs'),
          onTap: () {},
        )
      ],
    )
  );
}


        /*body: Row(
          children: [
            NavigationRail(
              extended: true,
              backgroundColor: Colors.grey[900],
              labelType: NavigationRailLabelType.none,
              selectedIndex: 0,
              selectedIconTheme:
                  const IconThemeData(color: Colors.white, size: 20),
              destinations: const [
                NavigationRailDestination(
                    icon: SizedBox.shrink(), label: Text("data")),
                NavigationRailDestination(
                    icon: Icon(Icons.abc_rounded), label: Text("test"))
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: Colors.white)
          ],
       ));*/

