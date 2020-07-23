import 'package:flutter/material.dart';
import 'package:flutter_getting_start/libs/network/network.dart';

import 'package:flutter_getting_start/libs/toast.dart';
import 'package:flutter_getting_start/libs/widgets/PullToRefresh_demo.dart';
import 'package:flutter_getting_start/main.dart';

import '../UserInfo.dart';

void main() {
  runApp(_App());
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: ActPage(),
    );
  }
}

class ActPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ActState();
  }
}

class ActState extends State<ActPage> with SingleTickerProviderStateMixin {
  List<Choice> tabs = [];
  TabController mTabController;
  int mCurrentPosition = 0;

  //list items
  List<Choice> items = new List<Choice>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            //滑动停靠
            new SliverAppBar(
              pinned: true,
              expandedHeight: 220.0,
              bottom: PreferredSize(
                  child: new Container(
                    color: Colors.white,
                    child: new TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Colors.green,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black45,
                      tabs: tabs.map((Choice choice) {
                        return new Tab(
                          text: choice.title,
                          icon: new Icon(
                            choice.icon,
                          ),
                        );
                      }).toList(),
                      controller: mTabController,
                    ),
                  ),
                  preferredSize: new Size(double.infinity, 18.0)),
              flexibleSpace: new Container(
                child: new Column(
                  children: <Widget>[
                    new Expanded(
                      child: new Container(
                        child: Image.asset(
                          "assets/images/arrow_right.png",
                          fit: BoxFit.cover,
                        ),
                        width: double.infinity,
                      ),
                    )
                  ],
                ),
              ),
            )
          ];
        },
        body: new TabBarView(
          children: tabs.map((Choice choice) {
            return new Padding(
                padding: const EdgeInsets.all(15.0),
                child: _createTabWidget(choice.position));
          }).toList(),
          controller: mTabController,
        ),
      ),
    );
  }

  Widget _buildListWidget(BuildContext context, int index) {
    return GestureDetector(
      child: _buildItemWidget(context, index),
      onTap: () {
        //Widget Function(BuildContext context)
        if (index == 0) {
          print("start test post".runtimeType.toString());
          Navigator.push(
              context, MaterialPageRoute(builder: (BuildContext context) {
            return new MyApp();
          })
          );
        } else if (index == 1) {
          //network
          print("start test Get");
          NetworkComponent().get("http://www.baidu.com", {}).then((value) =>
          {
          });
        }else if (index == 2) {
          //network
          print("start test post");
          Map<String, dynamic> map = Map();
          map["deviceId"] = "unknown";
          map["deviceType"] = "android";
          map["phone"] = "12011111116";
          map["loginType"] = 0; // o is code . 1 is pwd
          map["smsCode"] = '0408';

          NetworkComponent().postBody("v1/user/login", map).then((value)
          {
            print(value.data);
            print(value.getCodeString());
          });
        }else if(index == 3){
          print("start PullToRrFreshApp");
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
            return new PullToRrFreshApp();
          }));
        }
      },
    );
  }

  Widget _createTabWidget(int pos) {
    switch (pos) {
      case 0:
        return new Container(
            child: new ListView(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.map),
                  title: new Text('Map'),
                ),
                new ListTile(
                  leading: new Icon(Icons.photo),
                  title: new Text('Album'),
                ),
                new ListTile(
                  leading: new Icon(Icons.phone),
                  title: new Text('Phone'),
                ),
                new ListTile(
                  leading: new Icon(Icons.map),
                  title: new Text('Map'),
                ),
                new ListTile(
                  leading: new Icon(Icons.photo),
                  title: new Text('Album'),
                ),
                new ListTile(
                  leading: new Icon(Icons.phone),
                  title: new Text('Phone'),
                ),
              ],
            ));

      case 1:
        return Container(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.phone),
                title: GestureDetector(
                  child: Text("test bases"),
                  onTap: () {

                  },
                ),
              )
            ],
          ),
        );

      case 2:
        return Container(
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: _buildListWidget),
        );

      default:
        return new Container(
          child: new Text("ahhhhhhhhhhhhh"),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    tabs.add(Choice(title: '热门', icon: Icons.hot_tub, position: 0));
    tabs.add(Choice(title: '最新', icon: Icons.fiber_new, position: 1));
    tabs.add(Choice(title: '测试1', icon: Icons.fiber_new, position: 2));
    tabs.add(Choice(title: '测试2', icon: Icons.fiber_new, position: 3));
    tabs.add(Choice(title: '测试3', icon: Icons.fiber_new, position: 4));

    items.add(Choice(title: 'test bases', icon: Icons.hot_tub, position: 0));
    items.add(Choice(title: 'test network get', icon: Icons.network_cell, position: 1));
    items.add(Choice(title: 'test network post', icon: Icons.network_cell, position: 2));
    items.add(Choice(title: 'test pullToRefresh', icon: Icons.headset_off, position: 3));
    items.add(Choice(title: 'wait 4', icon: Icons.hearing, position: 4));

    mTabController = new TabController(vsync: this, length: tabs.length);
    //判断TabBar是否切换
    mTabController.addListener(() {
      if (mTabController.indexIsChanging) {
        print(
            "mTabController.indexIsChanging ${mTabController.indexIsChanging}");
        setState(() {
          mCurrentPosition = mTabController.index;
        });
      }
    });
  }

  Widget _buildItemWidget(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Column(
          children: <Widget>[
            Text(
                items[index].title
            ),
            Image.network(
              "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
              scale: 2,)
          ],
        );

      case 1:
        return Column(
          children: <Widget>[
            TextField( //like android ->editText
              onChanged: (String str) {
                Toast.toast(context, "TextField changed: $str");
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                icon: Icon(Icons.text_fields),
                labelText: '请输入你的姓名)',
                helperText: '请输入你的真实姓名',
              ),
            ),
            Image.network(
              "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
              scale: 2,)
          ],
        );

      default:
        return Column(
          children: <Widget>[
            Text(
            items[index].title
            ),
            Image.network(
              "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1946244045,749707381&fm=26&gp=0.jpg",
              scale: 2,)
          ],
        );
        return Text(
            items[index].title
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    mTabController.dispose();
  }
}

class Choice {
  const Choice({this.title, this.icon, this.position});

  final String title;
  final int position;
  final IconData icon;
}
