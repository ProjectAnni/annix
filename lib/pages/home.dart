import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/navigator.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(
        appBar: AppBar(
          title: Text("Annix"),
        ),
      ),
      body: Row(
        children: [
          // TODO: This is Desktop layout, we need another mobile layout
          AnnilNavigator(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                // bottom play bar
                // Use persistentFooterButtons if this issue has been resolved
                // https://github.com/flutter/flutter/issues/46061
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: BottomPlayBar(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
