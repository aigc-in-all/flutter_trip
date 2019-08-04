import 'package:flutter/material.dart';
import 'package:flutter_trip/widgets/search_bar.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("title"),
      ),
      body: Column(
        children: <Widget>[
          SearchBar(
            searchBarType: SearchBarType.home,
            hideLeft: true,
            defaultText: '哈哈',
            hint: 'hello',
            leftButtonClick: () {
              print('leftButtonClick');
            },
            onChanged: (text) {
              print('onChange: $text');
            },
          )
        ],
      ),
    );
  }
}
