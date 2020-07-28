import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_getting_start/libs/window/BaseWindow.dart';

class BaseWindowDemoApps extends StatelessWidget {
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
        home: HomeDemo()
    );
  }
}
class HomeDemo extends StatefulWidget {
  @override
  State createState() {
     return _HomeState();
  }
}
class _HomeState extends State<HomeDemo> with TickerProviderStateMixin  {

  AnimationController controller;//动画控制器
  Animation<Offset> animation;
 // CurvedAnimation curved;//曲线动画，动画插值，
  double _toastTop = 0;

  Window _toastWindow;
  Window _loadingWindow;
  Window _anchorBottomWindow;

  GlobalKey _anchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _toastWindow = new Window((BuildContext context){
      return BaseWindow.of(context, _buildToastWidget(context),
          top: _toastTop,showCallback: (bool){
              if(bool){
                return controller.forward(from: 0.0);
              }
              return Future.value();
          }, dismissDelegate: () =>
             controller.reverse());
    });
    _loadingWindow = new Window((BuildContext context){
      return BaseWindow.of(context, _buildLoadingWidget(context),
          top: _buildToastPosition(context, Position.center));
    });
    //anim of toast
    controller = new AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    animation = Tween(begin: Offset.zero, end: Offset(0.0, 10)).animate(controller);
//    controller.forward();//放在这里开启动画 ，打开页面就播放动画
  }
  @override
  void dispose() {
    _toastWindow.dispose();
    _loadingWindow.dispose();
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Base window demos"),
        centerTitle: true,
        leading: IconButton(
          //icon: Image.asset("aasets/images/arrow_right.png"),
          icon:  Icon(Icons.add_box),
          onPressed: (){

          },
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        widthFactor: 10,
        child: ListView(
          children: <Widget>[
            ListTile(title: Text("Toast"),
              onTap: () {
                _toastWindow.toggleShow(context, showTimeMsec: 2000);
              }),
            ListTile(title: Text("LoadingDialog"),
                onTap: () {
                  _loadingWindow.toggleShow(context);
                }),
            Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(80),
                child: ListTile(
                    key: _anchorKey,
                    title: Text("Anchor window-bottom"),
                    onTap: () {
                      if(_anchorBottomWindow == null){
                        _anchorBottomWindow = Window.ofAnchor(context, _anchorKey,
                            _buildToastImpl(context));
                      }
                      _anchorBottomWindow.toggleShow(context);
                    })
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildToastWidget(BuildContext context) {
    return SlideTransition(
        position: animation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: _buildToastImpl(context),
        )
    );
  }
}

Widget _buildLoadingWidget(BuildContext context) {
   return Center(
     child: Column(
       children: <Widget>[
         CircularProgressIndicator()
       ],
     ),
   );
}

Widget _buildToastImpl(BuildContext context) {
  return Center(
    child: Card(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          "test show toast by BaseWindow",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}
enum Position{
  top,
  center,
  bottom,
}
double _buildToastPosition(BuildContext context, Position _position) {
  var backResult;
  if (_position == Position.top) {
    backResult = MediaQuery.of(context).size.height * 1 / 4;
  } else if (_position == Position.center) {
    backResult = MediaQuery.of(context).size.height * 2 / 5;
  } else {
    backResult = MediaQuery.of(context).size.height * 3 / 4;
  }
  return backResult;
}