import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_getting_start/libs/network/HttpResult.dart';
import 'package:flutter_getting_start/libs/network/network.dart';
import 'package:flutter_getting_start/libs/pull_to_refresh/_CupertinoSliverRefresh.dart';
import '../pull_to_refresh/list_loader.dart';

class PullToRrFreshApi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PullToRrFresh api Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _PullToRefreshWidget(),
    );
  }
}

class SourceListData extends DataRes implements ListDataOwner {
  List list;

  @override
  List getList() {
    return list;
  }

  @override
  void fromJson(Map<String, dynamic> map) {
    list = map["list"];
    print("SourceListData_list: \n$list");
  }
}

class _PullToRefreshWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    PageManager _pm = PageManager(_respository, _interceptor);
    HttpRequestContext context = HttpRequestContext("v1/source/list",
        HttpRequestContext.TYPE_POST_BODY, new SourceListData());
    ListHelper _helper = new ListHelper()
      ..pageManager = _pm
      ..callback = new ListCallback()
      ..context = context
      ..uiCallback = null; //default

    return PullToRefreshState(_helper, _buildEmpty, _buildError, _buildContent,
        _buildItem, _buildLoadMore, iosStyle: true);
  }

  void _respository(Object context, Map<String, dynamic> params, bool refresh,
      OnResult result,
      {OnException e}) {
    HttpRequestContext hrc = context as HttpRequestContext;
    Map<String, dynamic> header = {
      /*"Accept": "application/json",
      "sys_platform": "android",
      "sys_version": "29",
      "sys_deviceid": "unknown",
      "app_channel": "wl_good_owner",
      "app_versionname": "1.0.0",*/
      "app_token": "quick_login_620605cca0854eabb5694c1933b499f3"
    };
    NetworkComponent(data: hrc.dataType)
        .postBody(hrc.url, params, extraHeaders: header)
        .then((value) {
      ResultData rd = value;
      if (rd.isSuccess()) {
        result.call(context, params, refresh, rd.data);
      } else {
        //exception ignored
        e.call(context, params, refresh, null);
      }
    });
  }

  Map _interceptor(Map map) {
    map.putIfAbsent("label", () => "全部");
    return map;
  }

  Widget _buildLoadMore(
      BuildContext context, bool isPerformingRequest, FooterState fs) {
    return _buildProgressIndicator(isPerformingRequest);
  }

  Widget _buildItem(BuildContext context, int index, dynamic item) {
    //return ListTile(title: new Text("Number $index"));
    return new Container(
      margin: EdgeInsets.all(15.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            "标题: \n$index",
            textAlign: TextAlign.start,
          ),
          new Text(
            "内容: \n$index",
            textAlign: TextAlign.start,
          ),
          new Container(
            margin: EdgeInsets.only(top: 10.0),
            child: new Divider(
              height: 2.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Widget refreshIndicator, bool iosStyle) {
    return Scaffold(
      body: Container(padding: EdgeInsets.all(2.0), child: refreshIndicator),
    );
  }

  Widget _buildEmpty(BuildContext context, bool reset, VoidCallback refresh) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(2.0),
        alignment: Alignment.center,
        child: RefreshIndicator(
          onRefresh: refresh,
          backgroundColor: Colors.white70,
          color: Colors.pinkAccent,
          child: _buildEmptyWidget2(context),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, bool reset, VoidCallback refresh) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(2.0),
      child: _buildErrorWidget(context, refresh),
    ));
  }

  //--------------------------------------------------------
  Widget _buildProgressIndicator(bool isPerformingRequest) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          //opacity: 1.0 ,
          child: new CircularProgressIndicator(
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation(Colors.amber),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget2(BuildContext context) {
    return ListView(
      children: <Widget>[
        Image.network(
          "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
          scale: 2,
        ),
        Text("暂无数据",
            textAlign: TextAlign.center,
            style: TextStyle(
              backgroundColor: Colors.blue,
              color: Colors.white,
            ))
      ],
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _buildErrorWidget(BuildContext context, VoidCallback refresh) {
    return Column(
      children: <Widget>[
        Image.network(
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
            scale: 2),
        GestureDetector(
          child: Text(
            "重新加载",
            style: TextStyle(
              backgroundColor: Colors.blue,
              color: Colors.white,
            ),
          ),
          onTap: refresh,
        )
      ],
    );
  }
}

class SimpleUiCallback extends UiCallback {
  final PullToRefreshState _state;
  final UiCallback _base;

  SimpleUiCallback(this._state, this._base);

  @override
  void markRefreshing() {
    _state.update(() {
      _state._showRefresh();
      if (_base != null) {
        _base.markRefreshing();
      }
    });
  }

  @override
  void setRequesting(bool requesting,
      {bool clearItems, bool resetError, bool resetEmpty}) {
    _state.update(() {
      if (clearItems) {
        _state.items.clear();
      }
      _state._resetEmpty = resetEmpty;
      _state._resetError = resetError;
      _state._isPerformingRequest = requesting;
      if (_base != null) {
        _base.setRequesting(requesting,
            clearItems: clearItems,
            resetError: resetError,
            resetEmpty: resetEmpty);
      }
    });
  }

  @override
  void showContent(List data, FooterState state) {
    _state.update(() {
      _state.items.addAll(data);
      _state._isPerformingRequest = false;
      _state._footerState = state;
      if (_base != null) {
        _base.showContent(data, state);
      }
    });
  }

  @override
  void showEmpty(data) {
    _state.update(() {
      _state._showState = RefreshState.STATE_EMPTY;
      _state._isPerformingRequest = false;
      if (_base != null) {
        _base.showEmpty(data);
      }
    });
  }

  @override
  void showError(Exception e, bool clearItems) {
    _state.update(() {
      if (clearItems) {
        _state.items.clear();
      }
      _state._showState = RefreshState.STATE_ERROR;
      _state._isPerformingRequest = false;
      if (_base != null) {
        _base.showError(e, clearItems);
      }
    });
  }
}

typedef WidgetBuilder = Widget Function(
    BuildContext context, bool reset, VoidCallback refresh);
typedef ContentWidgetBuilder = Widget Function(
    BuildContext context, Widget refreshIndicator, bool iosStyle);
typedef LoadMoreBuilder = Widget Function(
    BuildContext context, bool isPerformingRequest, FooterState fs);
typedef ItemBuilder = Widget Function(
    BuildContext context, int index, dynamic item);
typedef ShowLoadMore = void Function(ScrollController sc);

enum RefreshState {
  STATE_ERROR,
  STATE_EMPTY,
  STATE_NORMAL,
}

class PullToRefreshState extends State<StatefulWidget> {
  ListHelper _helper;
  final List items = List();
  final ScrollController _scrollController = new ScrollController();
  bool _isPerformingRequest = false;
  RefreshState _showState = RefreshState.STATE_NORMAL;
  FooterState _footerState = FooterState.STATE_NORMAL;

  ///keys for drive show-refresh state
  GlobalKey<CupertinoSliverRefreshControlState> _refreshKeyIos;
  GlobalKey<RefreshIndicatorState> _refreshKey;

  WidgetBuilder _empty;
  WidgetBuilder _error;
  ContentWidgetBuilder _contentWidgetBuilder;
  LoadMoreBuilder _loadMoreBuilder;
  ItemBuilder _itemBuilder;
  ShowLoadMore _showLoadMore;

  Color _indicatorBg;
  Color _indicatorValue;

  bool _resetError;
  bool _iosStyle;

  PullToRefreshState(
      ListHelper helper,
      WidgetBuilder empty,
      WidgetBuilder error,
      ContentWidgetBuilder contentBuilder,
      ItemBuilder itemBuilder,
      LoadMoreBuilder loadMoreBuilder,
      {Color indicatorBg,
      Color indicatorValue,
      ShowLoadMore showLoadMore,
      bool iosStyle}) {
    //wrap
    helper.uiCallback = new SimpleUiCallback(this, helper.uiCallback);
    this._helper = helper;
    _empty = empty;
    _error = error;
    _contentWidgetBuilder = contentBuilder;
    _loadMoreBuilder = loadMoreBuilder;
    _itemBuilder = itemBuilder;
    this._indicatorBg = indicatorBg ??= Colors.white70;
    this._indicatorValue = indicatorValue ??= Colors.pinkAccent;
    this._showLoadMore = showLoadMore ??= _showLoadMore0;
    this._iosStyle = iosStyle;
    if(iosStyle){
      _refreshKeyIos = new GlobalKey<CupertinoSliverRefreshControlState>();
    }else{
      _refreshKey = new GlobalKey<RefreshIndicatorState>();
    }
  }

  bool _resetEmpty;

  void update(VoidCallback vc) {
    setState(vc);
  }

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 10) {
        _getMoreData();
      }
    });
    //trigger refresh
    Future.delayed(new Duration(milliseconds: 30))
        .then((value) => _helper.refresh());
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_showState) {
      case RefreshState.STATE_EMPTY:
        return _empty.call(context, _resetEmpty, () {
          _setShowState(RefreshState.STATE_NORMAL);
          _refresh();
        });

      case RefreshState.STATE_ERROR:
        return _error.call(context, _resetError, () {
          _setShowState(RefreshState.STATE_NORMAL);
          _refresh();
        });

      case RefreshState.STATE_NORMAL:
      default:
      IndexedWidgetBuilder indexBuilder = (context, index) {
        if (index > 0 && index == items.length) {
          return _loadMoreBuilder.call(
              context, _isPerformingRequest, _footerState);
        }
        return _itemBuilder.call(context, index, items[index]);
      };
        if(_iosStyle){
          Widget scrollView = CustomScrollView(
            controller: _scrollController,
            // If left unspecified, the [CustomScrollView] appends an
            // [AlwaysScrollableScrollPhysics]. Behind the scene, the ScrollableState
            // will attach that [AlwaysScrollableScrollPhysics] to the output of
            // [ScrollConfiguration.of] which will be a [ClampingScrollPhysics]
            // on Android.
            // To demonstrate the iOS behavior in this demo and to ensure that the list
            // always scrolls, we specifically use a [BouncingScrollPhysics] combined
            // with a [AlwaysScrollableScrollPhysics]
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              CupertinoSliverRefreshControl2(
                key: _refreshKeyIos,
                onRefresh: () async {
                  _refresh();
                },
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((content, index) {
                  return indexBuilder.call(context, index);
                }, childCount: items.length > 0 ? items.length + 1 : 0),
              )
            ],
          );
          return _contentWidgetBuilder.call(context, scrollView, true);
        }
        RefreshIndicator indicator = RefreshIndicator(
          key: _refreshKey,
          onRefresh: () async {
            _refresh();
          },
          backgroundColor: _indicatorBg,
          color: _indicatorValue,
          child: ListView.builder(
            itemCount: items.length > 0 ? items.length + 1 : 0,
            itemBuilder: indexBuilder,
            controller: _scrollController,
            //resolve data so less cause can't refresh
            physics: AlwaysScrollableScrollPhysics(),
          ),
        );
        return _contentWidgetBuilder.call(context, indicator, false);
    }
  }

  void _refresh() {
    print("refresh");
    if (!_isPerformingRequest) {
      _helper.requestData(true);
    }
  }

  void _setShowState(RefreshState state) {
    setState(() {
      _showState = state;
    });
  }

  void _getMoreData() {
    print("_getMoreData");
    if (_footerState != FooterState.STATE_THE_END && !_isPerformingRequest) {
      /*setState(() {
        _footerState = FooterState.STATE_LOADING;
      });*/
      _showLoadMore.call(_scrollController);
      _helper.requestData(false);
    }
  }

  void _showLoadMore0(ScrollController sc) {
    print("showLoadMore: maxScroll = ${sc.position.maxScrollExtent}, "
        "minScroll = ${sc.position.minScrollExtent}"
        ", pixels = ${sc.position.pixels}");
    double edge = 50.0;
    //maxScrollExtent often is the content height of whole view, like ListView
    //pixels often is child offset
    double offsetFromBottom = sc.position.maxScrollExtent - sc.position.pixels;
    if (offsetFromBottom < edge) {
      //animate up
      sc.animateTo(sc.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500), curve: Curves.easeOut);
    }
  }

  void _showRefresh() {
     if(_iosStyle){
       _refreshKeyIos.currentState.show();
     }else{
       _refreshKey.currentState.show();
     }
  }
}
