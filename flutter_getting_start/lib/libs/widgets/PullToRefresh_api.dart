import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../pull_to_refresh/list_loader.dart';

class PullToRrFreshApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PullToRrFreshApp Demo',
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
      home: PullToRefreshWidget(),
    );
  }
}

typedef WidgetBuilder = Widget Function(
    BuildContext context, bool reset, VoidCallback refresh);
typedef ContentWidgetBuilder = Widget Function(
    BuildContext context, Widget child);
typedef LoadMoreBuilder = Widget Function(
    BuildContext context, bool isPerformingRequest);

class PullToRefreshWidget extends StatefulWidget {
  PageManager _pm;
  HttpRequestContext _httpContext; //TODO

  @override
  State<StatefulWidget> createState() {
   //TODO return PullToRefreshState(_httpContext, _pm);
  }
}

class ListCallbackImpl extends ListCallback {
  @override
  List getListData(Object data) {
    // TODO: implement getListData
    throw UnimplementedError();
  }

  @override
  bool handleRefresh() {
    // TODO: implement handleRefresh
    throw UnimplementedError();
  }

  @override
  List map(List data) {
    return data;
  }
}

class UiCallbackImpl extends UiCallback {
  final PullToRefreshState s;

  UiCallbackImpl(this.s);

  @override
  void markRefreshing() {
    // TODO: implement markRefreshing
  }

  @override
  void setRequesting(bool requesting,
      {bool clearItems, bool resetError, bool resetEmpty}) {
    // TODO: implement setRequesting
    s.update(() {
      if (clearItems) {
        s.items.clear();
      }
      s._resetEmpty = resetEmpty;
      s._resetError = resetError;
      s._isPerformingRequest = requesting;
    });
  }

  @override
  void showContent(List data, FooterState state) {
    // TODO: implement showContent\
    s.update(() {
      s.items.addAll(data);
      s._isPerformingRequest = false;
    });
  }

  @override
  void showEmpty(data) {
    // TODO: implement showEmpty
    s.update(() {
      s._showState = RefreshState.STATE_EMPTY;
      s._isPerformingRequest = false;
    });
  }

  @override
  void showError(Exception e, bool clearItems) {
    // TODO: implement showError
    s.update(() {
      if (clearItems) {
        s.items.clear();
      }
      s._showState = RefreshState.STATE_ERROR;
      s._isPerformingRequest = false;
    });
  }
}

enum RefreshState {
  STATE_ERROR,
  STATE_EMPTY,
  STATE_NORMAL,
}

class PullToRefreshState extends State<PullToRefreshWidget> {
  ListHelper _helper;
  final List items = List();
  final ScrollController _scrollController = new ScrollController();
  bool _isPerformingRequest = false;
  RefreshState _showState = RefreshState.STATE_NORMAL;

  WidgetBuilder _empty;
  WidgetBuilder _error;
  ContentWidgetBuilder _contentWidgetBuilder;
  LoadMoreBuilder _loadMoreBuilder;
  IndexedWidgetBuilder _indexedWidgetBuilder;

  Color _indicatorBg;
  Color _indicatorValue;

  bool _resetError;
  bool _resetEmpty;

  PullToRefreshState(
    HttpRequestContext context,
    PageManager pm,
    WidgetBuilder empty,
    WidgetBuilder error,
    ContentWidgetBuilder contentBuilder,
    LoadMoreBuilder loadMoreBuilder,
    IndexedWidgetBuilder indexedWidgetBuilder,
  {Color indicatorBg, Color indicatorValue}
  ) {
    this._helper = new ListHelper()
      ..pageManager = pm
      ..callback = new ListCallbackImpl()
      ..context = context
      ..uiCallback = new UiCallbackImpl(this);
    _empty = empty;
    _error = error;
    _contentWidgetBuilder = contentBuilder;
    _loadMoreBuilder = loadMoreBuilder;
    _indexedWidgetBuilder = indexedWidgetBuilder;
    this._indicatorBg = indicatorBg;
    this._indicatorValue = indicatorValue;
  }

  void update(VoidCallback vc) {
    setState(vc);
  }

  @override
  void didUpdateWidget(PullToRefreshWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
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
        RefreshIndicator indicator = RefreshIndicator(
          onRefresh: _refresh,
          backgroundColor: _indicatorBg,
          color: _indicatorValue,
          child: ListView.builder(
            itemCount: items.length > 0 ? items.length + 1 : 0,
            itemBuilder: (context, index) {
              if (index > 0 && index == items.length) {
                return _loadMoreBuilder.call(context, _isPerformingRequest);
              }
              return _indexedWidgetBuilder.call(context, index);
            },
            controller: _scrollController,
            //resolve data so less cause can't refresh
            physics: AlwaysScrollableScrollPhysics(),
          ),
        );
        return _contentWidgetBuilder.call(context, indicator);
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

  _getMoreData() async {
    print("_getMoreData");
    if (!_isPerformingRequest) {
      showLoadMore();
      _helper.requestData(false);
    }
  }

  void showLoadMore() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      //animate up
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }
}
