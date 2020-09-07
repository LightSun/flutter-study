import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
      home: PullToRefresh(),
    );
  }
}

class PullToRefresh extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PullToRefresh> {
  static const int STATE_ERROR = 1;
  static const int STATE_EMPTY = 2;
  static const int STATE_NORMAL = 0;

  final List<int> items = List.generate(20, (i) => i);
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  int _showState = STATE_NORMAL;

  @override
  void didUpdateWidget(PullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //print("pixels: ${_scrollController.position.pixels}");
      //print("maxScrollExtent: ${_scrollController.position.maxScrollExtent}");
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

  Widget build(BuildContext context) {
    switch (_showState % 3) {
      case STATE_EMPTY:
        return Scaffold(
          body: Container(
            padding: EdgeInsets.all(2.0),
            alignment: Alignment.center,
            child: RefreshIndicator(
              onRefresh: () async {
                print("STATE_EMPTY: onRefresh");
                _setShowState(STATE_NORMAL);
                _refresh();
              },
              backgroundColor: Colors.white70,
              color: Colors.pinkAccent,
              child: _buildEmptyWidget2(context),
            ),
          ),
          floatingActionButton: _buildActionButton(context),
        );

      case STATE_ERROR:
        return Scaffold(
          body: Container(
            padding: EdgeInsets.all(2.0),
            child: _buildErrorWidget(context),
          ),
          floatingActionButton: _buildActionButton(context),
        );
    }
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(2.0),
        child: RefreshIndicator(
          onRefresh: _refresh,
          backgroundColor: Colors.white70,
          color: Colors.pinkAccent,
          child: ListView.builder(
            itemCount: items.length > 0 ? items.length + 1 : 0,
            itemBuilder: (context, index) {
              if (index > 0 && index == items.length) {
                return _buildProgressIndicator();
              }
              return ListTile(title: new Text("Number $index"));
            },
            controller: _scrollController,
            //解决数据太少不能刷新问题
            physics: AlwaysScrollableScrollPhysics(),
          ),
        ),
      ),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildProgressIndicator() {
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

  //刷新
  Future<Null> _refresh() async {
    items.clear();
    await _getMoreData2(c: 20);
  }

  void _setShowState(int state) {
    setState(() {
      _showState = state;
    });
  }

  _getMoreData2({c: 10}) async {
    print("_getMoreData2");
    if (!isPerformingRequest) {
      setState(() => isPerformingRequest = true);
      List<int> newEntries = await fakeRequest(items.length, items.length + c);
      setState(() {
        isPerformingRequest = false;
        items.addAll(newEntries);
      });
    }
  }

  _getMoreData() async {
    print("_getMoreData");
    if (!isPerformingRequest) {
      setState(() => isPerformingRequest = true);
      List<int> newEntries = await fakeRequest(
          items.length, items.length + 10); //returns empty list
      if (newEntries.isEmpty) {
        double edge = 50.0;
        double offsetFromBottom = _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels;
        if (offsetFromBottom < edge) {
          //相当于隐藏 加载更多
          _scrollController.animateTo(
              _scrollController.offset - (edge - offsetFromBottom),
              duration: new Duration(milliseconds: 500),
              curve: Curves.easeOut);
        }
      }
      setState(() {
        isPerformingRequest = false;
        items.addAll(newEntries);
      });
    }
  }

  Future<List<int>> fakeRequest(int from, int to) async {
    return Future.delayed(Duration(seconds: 2), () {
      return List.generate(to - from, (i) => i + from);
    });
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

  Widget _buildEmptyWidget(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        print("headerSliverBuilder");
        return <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            bottom: PreferredSize(
              //preferredSize: 表示吸顶的距离 = expandedHeight - Size;
              preferredSize: Size(double.infinity, 220.0),
              child: Column(
                children: <Widget>[
                  Image.network(
                    "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
                    scale: 2,
                  ),
                  Text(
                    "headerSliverBuilder",
                    style: TextStyle(
                      backgroundColor: Colors.blue,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          )
        ];
      },
      body: Column(
        children: <Widget>[
          Image.network(
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
            scale: 2,
          ),
          Text(
            "暂无相关信息",
            style: TextStyle(
              backgroundColor: Colors.blue,
              color: Colors.white,
            ),
          )
        ],
      ),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
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
          onTap: () {
            setState(() {
              _setShowState(STATE_NORMAL);
              _refresh();
            });
          },
        )
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _setShowState(_showState + 1);
      },
      tooltip: 'Show multi state',
      child: Icon(Icons.add),
    ); // This trailing c
  }
}
