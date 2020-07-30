import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PositionedDemo extends StatelessWidget {
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
        home: Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text("Base window demos"),
              centerTitle: true,
              leading: IconButton(
                //icon: Image.asset("aasets/images/arrow_right.png"),
                icon: Icon(Icons.add_box),
                onPressed: () {},
              ),
            ),
            body: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              widthFactor: 10,
              child: PositionedDemoWidget(),
            )));
  }
}

class PositionedDemoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<PositionedDemoWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      //TODO
    );
  }
}
