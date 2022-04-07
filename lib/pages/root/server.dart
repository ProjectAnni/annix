import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnivLoginCard extends StatelessWidget {
  const AnnivLoginCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(24.0).copyWith(bottom: 12, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Not logged in to Anniv",
              style: context.textTheme.titleLarge,
            ),
            Text(
              // TODO: some description about anniv’s functions
              "TODO: some description about anniv’s functions",
              style: context.textTheme.bodyMedium,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: Text("Login"),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      body: Column(children: [AnnivLoginCard()]),
    );
  }
}
