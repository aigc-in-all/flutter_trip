import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_trip/dao/home_dao.dart';
import 'package:flutter_trip/model/common_model.dart';
import 'package:flutter_trip/model/grid_nav_model.dart';
import 'package:flutter_trip/model/home_model.dart';
import 'package:flutter_trip/model/sales_box_model.dart';
import 'package:flutter_trip/widgets/grid_nav.dart';
import 'package:flutter_trip/widgets/loading_container.dart';
import 'package:flutter_trip/widgets/local_nav.dart';
import 'package:flutter_trip/widgets/sales_box.dart';
import 'package:flutter_trip/widgets/sub_nav.dart';
import 'package:flutter_trip/widgets/webview.dart';

const APPBAR_SCROLL_OFFSET = 100;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _appBarAlpha = 0;
  List<CommonModel> bannerList = [];
  List<CommonModel> localNavList = [];
  GridNavModel gridNavModel;
  List<CommonModel> subNavList = [];
  SalesBoxModel salesBoxModel;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
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

  Future<Null> _handleRefresh() async {
    print('refresh');
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        bannerList = model.bannerList;
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
        subNavList = model.subNavList;
        salesBoxModel = model.salesBox;
        _loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body: LoadingContainer(
          isLoading: _loading,
          child: Stack(
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
                  child: _listView,
                ),
              ),
              _appBar,
            ],
          )),
    );
  }

  Widget get _appBar {
    return Opacity(
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
    );
  }

  Widget get _listView {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          children: <Widget>[
            _banner,
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
            Padding(
              padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
              child: SalesBox(salesBox: salesBoxModel),
            )
          ],
        ));
  }

  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    CommonModel model = bannerList[index];
                    return WebView(
                      url: model.url,
                      statusBarColor: model.statusBarColor,
                      hideAppBar: model.hideAppBar,
                    );
                  },
                ),
              );
            },
            child: Image.network(
              bannerList[index].icon,
              fit: BoxFit.fill,
            ),
          );
        },
        pagination: SwiperPagination(),
      ),
    );
  }
}
