import 'package:annix/views/search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text("Music"),
          centerTitle: true,
          expandedHeight: 200,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Get.toNamed('/search');
              },
            ),
          ],
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
