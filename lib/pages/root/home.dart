import 'package:annix/pages/root/base.dart';
import 'package:annix/widgets/theme_button.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(
            title: Text("Annix"),
            actions: [ThemeButton()],
          ),
        ];
      },
      body: Column(
        children: [],
      ),
    );
  }
}
