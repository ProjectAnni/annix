import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text("Music"),
          centerTitle: true,
          expandedHeight: 200,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
            Container(
              height: 100,
              child: Text("2333"),
            ),
          ]),
        )
      ],
    );
  }
}
