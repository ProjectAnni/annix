import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Annix"),
      ),
      // On wide-screen devices we should apply this style
      // https://github.com/flutter/flutter/issues/50276
      drawer: AnniDrawer(),
      body: Column(
        children: [
          // bottom play bar
          // Use persistentFooterButtons if this issue has been resolved
          // https://github.com/flutter/flutter/issues/46061
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                elevation: 8.0,
                child: BottomPlayBar(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
