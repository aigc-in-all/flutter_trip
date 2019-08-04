import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/widgets/grid_nav.dart';
import 'package:flutter_trip/widgets/local_nav.dart';
import 'package:flutter_trip/widgets/sub_nav.dart';

const APPBAR_SCROLL_OFFSET = 100;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _imageUrls = [
    'http://pages.ctrip.com/commerce/promote/20180718/yxzy/img/640sygd.jpg',
    'https://dimg04.c-ctrip.com/images/700u0r000000gxvb93E54_810_235_85.jpg',
    'https://dimg04.c-ctrip.com/images/700c10000000pdili7D8B_780_235_57.jpg'
  ];

  double _appBarAlpha = 0;
  List<CommonModel> localNavList = [];
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool _onScroll(offset) {
    double alpha = offset / APPBAR_SCROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      _appBarAlpha = alpha;
    });
    return true;
  }

  loadData() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: Stack(
        children: <Widget>[
          MediaQuery.removePadding(
            // 移除ListView距离屏幕顶部的边距
              removeTop: true,
              context: context,
              child: NotificationListener(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification &&
                      notification.depth ==
                          0 /*只有ListView滚动的时候才处理，否则swiper滚动也会调用*/) {
                    return _onScroll(notification.metrics.pixels);
                  }
                  return false;
                },
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: 160,
                      child: Swiper(
                        itemCount: 3,
                        autoplay: true,
                        itemBuilder: (context, index) {
                          return Image.network(_imageUrls[index],
                              fit: BoxFit.fill);
                        },
                        pagination: SwiperPagination(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                      child: LocalNav(localNavList: localNavList),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
                      child: GridNav(gridNavModel: gridNavModel),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
                      child: SubNav(subNavList: subNavList),
                    ),

                    Container(
                      height: 800,
                      child: ListTile(
                        title: Text("haha"),
                      ),
                    )
                  ],
                ),
              )),
          Opacity(
            opacity: _appBarAlpha,
            child: Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('首页'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
