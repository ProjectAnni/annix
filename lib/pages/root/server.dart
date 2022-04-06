import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';

class ServerView extends StatelessWidget {
  const ServerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text("Server"),
            primary: false,
            pinned: true,
            centerTitle: true,
          ),
        ];
      },
      body: Container(),
    );
  }
}
