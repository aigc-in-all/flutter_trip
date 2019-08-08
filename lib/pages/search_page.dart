import 'package:flutter/material.dart';
import 'package:flutter_trip/dao/search_dao.dart';
import 'package:flutter_trip/model/search_model.dart';
import 'package:flutter_trip/pages/speak_page.dart';
import 'package:flutter_trip/util/navigator_util.dart';
import 'package:flutter_trip/widgets/search_bar.dart';
import 'package:flutter_trip/widgets/webview.dart';

const URL =
    'https://m.ctrip.com/restapi/h5api/searchapp/search?source=mobileweb&action=autocomplete&contentType=json&keyword=';

class SearchPage extends StatefulWidget {
  final bool hideLeft;
  final String searchUrl;
  final String keyword;
  final String hint;

  const SearchPage(
      {Key key, this.hideLeft, this.searchUrl = URL, this.keyword, this.hint})
      : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchModel searchModel;
  String keyword;

  @override
  void initState() {
    if (widget.keyword != null) {
      _onTextChanged(widget.keyword);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _appBar(),
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: searchModel?.data?.length ?? 0,
                itemBuilder: (context, index) {
                  return _item(index);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  _onTextChanged(String text) {
    keyword = text;
    if (text.length == 0) {
      setState(() {
        searchModel = null;
      });
      return;
    }

    String url = widget.searchUrl + text;
    SearchDao.fetch(url, text).then((SearchModel model) {
      if (model.keyword == keyword) {
        setState(() {
          searchModel = model;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  _appBar() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            // AppBar渐变遮罩背景
              gradient: LinearGradient(
                  colors: [Color(0x66000000), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80.0,
            decoration: BoxDecoration(color: Colors.white),
            child: SearchBar(
              searchBarType: SearchBarType.normal,
              hideLeft: widget.hideLeft,
              defaultText: widget.keyword,
              hint: widget.hint,
              leftButtonClick: () {
                NavigatorUtil.pop(context);
              },
              speakClick: _jumpToSpeak,
              onChanged: _onTextChanged,
            ),
          ),
        )
      ],
    );
  }

  _jumpToSpeak() {
    NavigatorUtil.push(context, SpeakPage());
  }

  _item(int index) {
    if (searchModel == null || searchModel.data == null) {
      return null;
    }
    SearchItem item = searchModel.data[index];
    return GestureDetector(
      onTap: () {
        NavigatorUtil.push(context, WebView(url: item.url, title: '详情'));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.3, color: Colors.grey),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(1),
              child: Icon(
                Icons.location_on,
                size: 26,
                color: Colors.blue,
              ), // Image(width: 26, height: 26, image: AssetImage('xxx'))
            ),
            Column(
              children: <Widget>[
                Container(width: 300, child: _title(item)),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 5),
                  child: _subTitle(item),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _title(SearchItem item) {
    if (item == null) {
      return null;
    }
    List<TextSpan> spans = [];
    spans.addAll(_keywordTextSpans(item.word, searchModel.keyword));
    spans.add(TextSpan(
        text: ' ${item.districtname ?? ''} ${item.zonename ?? ''}',
        style: TextStyle(fontSize: 16, color: Colors.grey)));
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  _subTitle(SearchItem item) {
    if (item == null) {
      return null;
    }
    return RichText(
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: '${item.price ?? ''}',
          style: TextStyle(fontSize: 16, color: Colors.orange),
        ),
        TextSpan(
          text: '  ${item.star ?? ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ]),
    );
  }

  _keywordTextSpans(String word, String keyword) {
    List<TextSpan> spans = [];
    if (word == null || word.length == 0) {
      return spans;
    }
    List<String> arr = word.split(keyword);
    TextStyle normalStyle = TextStyle(fontSize: 16, color: Colors.black87);
    TextStyle keywordStyle = TextStyle(fontSize: 16, color: Colors.orange);
    for (int i = 0; i < arr.length; i++) {
      if ((i + 1) % 2 == 0) {
        spans.add(TextSpan(text: keyword, style: keywordStyle));
      }
      String val = arr[i];
      if (val != null && val.length > 0) {
        spans.add(TextSpan(text: val, style: normalStyle));
      }
    }
    return spans;
  }
}
