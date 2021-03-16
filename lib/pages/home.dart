import 'package:annix/models/playlist.dart';
import 'package:annix/widgets/drawer.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Alignment: left
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              // TODO: cover
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Music Title'),
                              Text('Artist', textScaleFactor: 0.8)
                            ],
                          )
                        ],
                      ),
                      // Alignment: right
                      Consumer<ActivePlaylist>(
                        builder: (context, playlist, child) {
                          return Row(
                            children: [
                              RepeatButton(
                                initial: playlist.mode,
                                onRepeatModeChange: (mode) {
                                  // TODO: do not listen here
                                  playlist.setMode(mode);
                                },
                              ),
                              SquareIconButton(
                                child: Icon(Icons.play_arrow_rounded, size: 32),
                                onPressed: () {},
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
