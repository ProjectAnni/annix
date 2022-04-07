import 'package:annix/app.dart';
import 'package:annix/pages/playing.dart';
import 'package:annix/pages/root.dart';
import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text("Annix"),
            primary: false,
            snap: true,
            floating: true,
            centerTitle: true,
          ),
        ];
      },
      body: Column(
        children: [
          Card(
            child: TextButton(
              child: Text("Now Playing"),
              onPressed: () {
                Get.toNamed('/playing');
              },
            ),
          ),
        ],
      ),
    );
  }
}
