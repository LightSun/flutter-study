import 'package:flutter/material.dart';

//LinearLayout
class RowExpandedDemo extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}
//left margin can use Container.

class _MyAppState extends State<RowExpandedDemo> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("LinearLayout Example"),
        ),
        body: new Container(
          color: Colors.yellowAccent,
          child: new Row(
            //Column
//            mainAxisSize: MainAxisSize.min,//wrap_content ,不加的话默认为match_parent（MainAxisSize.max）
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //start==left,center==center,end==right ,
            // spaceEvenly==等比例居中，4个间距一样大（weight=1),spaceAround=等比例居中，6个间距一样大,spaceBetween=中间居中，两边顶边
            children: [
              new Expanded(
                child: new Container(
                  child: new Icon(
                    Icons.access_time,
                    size: 50.0,
                  ),
                  color: Colors.red,
                ),
                flex: 2,//flex == android:layout_weight
              ),
              new Expanded(
                child: new Container(
                  child: new Icon(
                    Icons.pie_chart,
                    size: 100.0,
                  ),
                  color: Colors.blue,
                ),
                flex: 4,
              ),
              new Expanded(
                child: new Container(
                  child: new Icon(
                    Icons.email,
                    size: 50.0,
                  ),
                  color: Colors.green,
                ),
                flex: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}