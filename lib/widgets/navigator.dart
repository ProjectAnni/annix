import 'package:flutter/material.dart';

class AnnilNavigator extends StatefulWidget {
  const AnnilNavigator({Key? key}) : super(key: key);

  @override
  _AnnilNavigatorState createState() => _AnnilNavigatorState();
}

class _AnnilNavigatorState extends State<AnnilNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.queue_music),
          label: Text('Playlist'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
    );
  }
}
