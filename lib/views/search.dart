import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  search() {
    print(_controller.text);
    primaryFocus?.unfocus(disposition: UnfocusDisposition.scope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TextField(
            autofocus: true,
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search",
              contentPadding:
                  EdgeInsets.only(left: 8, right: 0, top: 8, bottom: 8),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (_) => search,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: search,
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(top: 8),
        child: Text("Search results would display here"),
      ),
    );
  }
}
